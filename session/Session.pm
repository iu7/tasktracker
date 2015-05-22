package Session;

use strict;
use warnings;

use JSON;
use Config::Std;
use Cache::Memcached;
use Digest::MD5 qw(md5_hex);

use lib qw(../Wrappers);
use DB::DBProxy qw(:all);

use lib qw(..);
use Wrappers::Response qw(response_wrapper_initialize);

use base qw(Exporter);
our @EXPORT_OK = qw(
	session_check
	session_login
	session_logout
);
our %EXPORT_TAGS = (
	all => [ @EXPORT_OK ],
);

sub SESSION_ID_KEY()		{ 'session_id' }

my %__config;
my $__memcached;
my $__session_id_has_been_set;

my $SESSION_EXPIRATION_TIME;

BEGIN {
	my $path2config = "$ENV{ETC_DIRECTORY}/session.conf";

	read_config($path2config, %__config);
	db_proxy_initialize($__config{DATABASE});
	response_wrapper_initialize(
		service => 'session',
		host    => $__config{MONITORING}{host},
		port    => $__config{MONITORING}{port},
	);

	$__memcached = Cache::Memcached->new({
		servers => [ $__config{MEMCACHED}{'server-addr'} ],
	});
	if ($__memcached->add(SESSION_ID_KEY(), 0)) {
		$__session_id_has_been_set = 1;
	}

	$SESSION_EXPIRATION_TIME = $__config{SESSION}{'expiration-period'};
}

sub __memcached_reconnect
{
	$__memcached = Cache::Memcached->new({
		servers => [ $__config{MEMCACHED}{'server-addr'} ],
	});
	if (not $__session_id_has_been_set
	    and $__memcached->add(SESSION_ID_KEY(), 0)) {
		$__session_id_has_been_set = 1;
	}

	# ugly check for connect
	unless (defined $__memcached->get(SESSION_ID_KEY())) {
		undef $__memcached;
		return;
	}

	return 1;
}

sub __session_generate_token
{
	return md5_hex(rand, scalar localtime);
}

sub __session_next_id
{
	my $ret = $__memcached->incr(SESSION_ID_KEY());
	if (not $ret) {
		__memcached_reconnect()
	}

	return $ret;
}

sub __session_login_and_password_are_ok
{
	my ($login, $password) = @_;

	my $query = 'SELECT 1 FROM users WHERE login=? and passwordhash=?';
	return eval { db_proxy_select_row($query, $login, $password) };
}

sub session_login
{
	my $json = shift;

	return (500, q{can't connect to memcached})
		if not $__memcached and not __memcached_reconnect();

	my $data = eval { from_json($json) };
	return (400, q{invalid json}) unless $data;

	my $login = $data->{login};
	my $password = $data->{password};
	return (400, q{missed login or password}) unless $login and $password;
	return (401, q{invalid login or password})
		unless __session_login_and_password_are_ok($login, $password);

	# new session
	my $id = __session_next_id();
	my $token = __session_generate_token();
	return (500, q{can't generate new session id}) unless defined $id;

	unless ($__memcached->set($id . $token, $login, $SESSION_EXPIRATION_TIME)) {
		__memcached_reconnect();
		return (500, q{can't update session info});
	}

	return (201, to_json({ id => $id, token => $token }));
}

sub session_check
{
	my ($json, $check_only) = @_;

	return (500, q{can't connect to memcached})
		if not $__memcached and not __memcached_reconnect();

	my $id = $json->{id};
	my $token = $json->{token};
	return (400, q{`id' or `token' not specified})
		unless defined($id) and $token;

	my $key = $id . $token;
	my $login = $__memcached->get($key);
	return (401, q{session not found})
		unless $login;

	if (not $check_only
	    and not $__memcached->set($key, $login, $SESSION_EXPIRATION_TIME)) {
		__memcached_reconnect();
		return (500, q{can't update session expiration time});
	}

	return (200, to_json({ login => $login }));
}

sub session_logout
{
	my $json = shift;

	return (500, q{can't connect to memcached})
		if not $__memcached and not __memcached_reconnect();

	my $data = eval { from_json($json) };
	return (400, q{invalid json}) unless $data;

	my $id = $data->{id};
	my $token = $data->{token};
	return (400, q{invalid `id' or `token' (empty)})
		unless defined($id) and $token;

	my ($status, $login) = session_check($data, 'check only');
	return (401, q{`session_check' failed}) unless  $status == 200;

	if (not $__memcached->delete($id . $token)) {
		__memcached_reconnect();
		return (500, q{can't delete session});
	}

	return (200, q{});
}

1;
