package Session;

use strict;
use warnings;

use JSON;
use Config::Std;
use Cache::Memcached;
use Digest::MD5 qw(md5_hex);

use lib qw(../Wrappers);
use DB::DBProxy qw(:all);

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

my $__memcached;
my $SESSION_EXPIRATION_TIME;
BEGIN {
	my $path2config = "$ENV{ETC_DIRECTORY}/session.conf";

	read_config($path2config, my %config);
	$__memcached = Cache::Memcached->new({
		servers => [ $config{MEMCACHED}{'server-addr'} ],
	});

	$__memcached->add(SESSION_ID_KEY(), 0);
	$SESSION_EXPIRATION_TIME = $config{SESSION}{'expiration-period'};
}

sub __session_generate_token
{
	return md5_hex(rand, scalar localtime);
}

sub __session_next_id
{
	return $__memcached->incr(SESSION_ID_KEY());
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

	my $data = eval { from_json($json) };
	return (400, q{}) unless $data;

	my $login = $data->{login};
	my $password = $data->{password};
	return (400, q{}) unless $login and $password;
	return (401, q{}) unless __session_login_and_password_are_ok($login, $password);

	# new session
	my $id = __session_next_id();
	my $token = __session_generate_token();
	return (500, q{}) unless defined $id;

	return (500, q{})
		unless $__memcached->set($id . $token, $login, $SESSION_EXPIRATION_TIME);

	return (201, to_json({ id => $id, token => $token }));
}

sub session_check
{
	my ($json, $check_only) = @_;

	my $id = $json->{id};
	my $token = $json->{token};
	return (400, q{}) unless defined($id) and $token;

	my $key = $id . $token;
	my $login = $__memcached->get($key);
	return (401, q{}) unless $login;

	return (500, q{}) # update expiration time
		unless $check_only or $__memcached->set($key, $login, $SESSION_EXPIRATION_TIME);

	return (200, to_json({ login => $login }));
}

sub session_logout
{
	my $json = shift;

	my $data = eval { from_json($json) };
	return (400, q{}) unless $data;

	my $id = $data->{id};
	my $token = $data->{token};
	return (400, q{}) unless defined($id) and $token;

	my ($status, $login) = session_check($data, 'check only');
	return (401, q{}) unless  $status == 200;

	$__memcached->delete($login);
	return (500, q{}) unless $__memcached->delete($id . $token);

	return (200, q{});
}

1;
