package Logic;

use strict;
use warnings;

use JSON;
use Config::Std;
use HTTP::Status qw(:constants);

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

my %__config;

BEGIN {
	my $path2config = "$ENV{ETC_DIRECTORY}/logic.conf";

	read_config($path2config, %__config);
	response_wrapper_initialize(
		service => 'session',
		host    => $__config{MONITORING}{host},
		port    => $__config{MONITORING}{port},
	);
}

sub __base_path_for
{
	my $service = uc shift;

	my $host = $__config{$service}{host};
	my $port = $__config{$service}{port};

	return "http://$host:$port/" . lc $service;
}

sub __base_path_for_session
{
	return __base_path_for('session');
}

sub __base_path_for_projects
{
	return __base_path_for('projects');
}

sub __base_path_for_users
{
	return __base_path_for('users');
}

sub __base_path_for_tasks
{
	return __base_path_for('tasks');
}


# /projects
# /projects/{projectName}/exist
# /projects/{projectName}/updateManager
# /projects/{projectName}/updateDescription
# /projects
#
# /projects/{projectName}/groups
# /projects/{projectName}/groups/{id}
# /projects/{projectName}/groups
# /projects/{projectName}/groups/{id}
# /projects/{projectName}/groups/{id}/updateName
# /projects/{projectName}/groups/{id}/updateDescription
# /projects/{projectName}/groups/{id}/users
# /projects/{projectName}/groups/{id}/users/{userId}
# /projects/{projectName}/groups/{id}/users
# /projects/{projectName}/roles
# /projects/{projectName}/roles/{id}
# /projects/{projectName}/roles/{id}/updateName
# /projects/{projectName}/roles/{id}/updateDescription
# /projects/{projectName}/roles/{id}
# /projects/{projectName}/roles
#
# /projects/{projectName}/roles/{id}/permissions
# /projects/{projectName}/roles/{id}/permissions/{name}
# /projects/{projectName}/groups/{id}/roles
# /projects/{projectName}/groups/{id}/roles/{roleId}
# /projects/{projectName}/groups/{id}/roles
# /projects/{projectName}/issuetypes
# /projects/{projectName}/issuetypes
# /projects/{projectName}/issuetypes/{id}
# /projects/{projectName}/issuetypes/{id}
# /projects/{projectName}/issuestates
# /projects/{projectName}/issuestates
# /projects/{projectName}/issuestates/{id}
# /projects/{projectName}/issuestates/{id}
# /projects/{projectName}/issuepriorities
# /projects/{projectName}/issuepriorities
# /projects/{projectName}/issuepriorities/{id}
# /projects/{projectName}/issuepriorities/{id}
# /projects/{projectName}/incAndGetLastTaskId






# POST /users
# GET  /users ? logins=const.gulyy,mylogin,eroshka

# GET  /users/{login}

# PUT  /users/{login}/updateName
# PUT  /users/{login}/updateEmail
# POST /users/{login}/resetPassword

# TODO: set `error' if there is one
sub users_check_request
{
	my $req = shift;

#	return send_response(HTTP_METHOD_NOT_ALLOWED, [], [])
#		if $req->method() eq 'DELETE';

	return {
		status	=> HTTP_NOT_IMPLEMENTED,
		error	=> 'not implemented yet';
	};
}

sub users_access_denied
{
	my $req_info = shift;
	die 'not implemented';
}

sub users_process_request
{
	my $req_info = shift;
	die 'not implemented';
}

sub session_check
{
	my $session_info_ref = shift;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_session();

	my @args_pairs;
	foreach my $key (keys %{ $session_info_ref }) {
		push @args_pairs, "$key=$session_info_ref->{$key}";
	}

	my $resp = $ua->get("$base_url/check?" . join '&', @args_pairs);
	my $content = $resp->content();
	my $json = eval { from_json($content) } || {};

	return $json->{login};
}

sub session_login
{
	my ($data, $session_info_ref) = @_;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_session();

	my $resp = $ua->post("$base_url/login", Content => $data);
	my $content_ref = [ $resp->decoded_content() ];

	return ($resp->code(), [], $content_ref);
}

sub session_logout
{
	my ($data, $session_info_ref) = @_;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_session();

	my $resp = $ua->put("$base_url/logout", Content => $data);
	my $content_ref = [ $resp->decoded_content() ];

	return ($resp->code(), [], $content_ref);
}
