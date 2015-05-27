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

	users_validate_request
	users_access_denied
	users_process_request
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


sub users_validate_request
{
	my ($req, $params) = @_;

	my $path = $req->path();
	my $method = $req->method();

	if ($path eq '/') {
		return {
			path	=> $path,
			method	=> 'GET',
			params	=> $params,
		} if $method eq 'GET';

		return {
			status	=> HTTP_BAD_REQUEST,
			error	=> q{invalid method for `/'},
		} if $method ne 'POST';

		return {
			path	=> $path,
			method	=> 'POST',
			params	=> $params,
		} if $method eq 'POST';
	}

	my ($login, $request) = split qr{/}, substr($path, 1);
	if (not $request) {
		return {
			status	=> HTTP_BAD_REQUEST,
			error	=> q{invalid method for `/login'},
		} if $method ne 'GET';

		return {
			path	=> $path,
			login	=> $login,
			method	=> 'GET',
			params	=> $params,
		};
	}

	return {
		status	=> HTTP_BAD_REQUEST,
		error	=> q{invalid method for `/login/action'},
	} if $method ne 'PUT' and $method ne 'POST';

	return {
		path	=> $path,
		login	=> $login,
		action	=> $request,
		method	=> $method,
		params	=> $params,
	};
}

sub users_access_denied
{
	my $req_info = shift;

	# FIXME

	return 0;
}

sub users_process_request
{
	my $req_info = shift;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_users();
	my $tail = $req_info->{login} ? "$req_info->{path}" : q{};

	my $resp;
	if ($req_info->{method} eq 'GET') {
		my @args_pairs;
		foreach my $key (keys %{ $req_info->{params} }) {
			push @args_pairs, "$key=$req_info->{params}{$key}";
		}

		$resp = $ua->get("${base_url}${tail}?" . join '&', @args_pairs);
	} else {
		my $request = HTTP::Request->new($req_info->{method});

		$request->uri($base_url . $tail);
		$request->content($req_info->{params});
		$request->header('Content-Type' => 'application/json');

		$resp = $ua->request($request);
	}
	my $content = $resp->content();

	return ($resp->code(), [ 'Content-Length' => length $content ], [ $content ]);
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
	my $content = $resp->content();

	return ($resp->code(), [ 'Content-Length' => length $content ], [ $content ]);
}

sub session_logout
{
	my ($data, $session_info_ref) = @_;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_session();

	my $resp = $ua->put("$base_url/logout", Content => $data);
	my $content = $resp->content();

	return ($resp->code(), [ 'Content-Length' => length $content ], [ $content ]);
}
