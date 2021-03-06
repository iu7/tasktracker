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

	users_parse_request
	users_access_denied
	users_process_request

	tasks_parse_request
	tasks_access_denied
	tasks_process_request

	projects_parse_request
	projects_access_denied
	projects_process_request
);
our %EXPORT_TAGS = (
	all => [ @EXPORT_OK ],
);

my %__config;

BEGIN {
	my $path2config = "$ENV{ETC_DIRECTORY}/logic.conf";

	read_config($path2config, %__config);
	response_wrapper_initialize(
		service => 'logic',
		host    => $__config{MONITORING}{host},
		port    => $__config{MONITORING}{port},
	);
}

sub HEADER_SESSION_ID()		{ 'X-Session-Id' }
sub HEADER_SESSION_TOKEN()	{ 'X-Session-Token' }

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

sub request_session_info
{
	my $req = shift;

	my $id = $req->header(HEADER_SESSION_ID());
	my $token = $req->header(HEADER_SESSION_TOKEN());
	return unless $id and $token;

	return session_check({ id => $id, token => $token });
}

sub request_permissions
{
	my ($login, $project) = @_;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_projects();

	my $resp = $ua->get("$base_url/$project/$login/permissions");
	return {} unless $resp->code() == HTTP_OK;

	my $content = $resp->content();
	my $json = eval { from_json($content) };
	return {} if $@;

	my %ret;
	foreach my $perm (@{ $json }) {
		$ret{$perm->{name}} = $perm->{value};
	}

	return \%ret;
}

sub projects_parse_request
{
	my ($req, $params) = @_;

	my $path = $req->path();
	my $method = $req->method();

	my ($project_id, $tail) = split qr{/}, substr($path, 1), 2;
	my $req_info = {
		path		=> $path,
		method		=> $method,
		params		=> $params,
		project_id	=> $project_id,
	};
	return $req_info unless $tail;

	foreach my $end (qw(exist updateManager updateDescription)) {
		next unless $tail eq $end;
		$req_info->{action} = $end;

		return $req_info;
	}

	(my $property, $tail) = split qr{/}, $tail, 2;
	$req_info->{property} = lc $property;

	return $req_info;
}

# for projects
sub PERMISSION_READ_PROJECT()		{ 'Read Project' }
sub PERMISSION_UPDATE_PROJECT()		{ 'Update Project' }

sub PERMISSION_CREATE_ROLE()		{ 'Create Role' }
sub PERMISSION_READ_ROLE()		{ 'Read Role' }
sub PERMISSION_UPDATE_ROLE()		{ 'Update Role' }

sub PERMISSION_CREATE_GROUP()		{ 'Create User Group' }
sub PERMISSION_READ_GROUP()		{ 'Read User Group' }
sub PERMISSION_UPDATE_GROUP()		{ 'Update User Group' }

sub projects_access_denied
{
	my ($req_info, $req) = @_;

	#return 0 if $req->param('nocheck'); # dirty hack for tests

	my $login = request_session_info($req);
	unless ($login) {
		$req_info->{status} = HTTP_UNAUTHORIZED;
		return 1;
	}

	# FIXME: one more simplification

	return 0;
}

sub projects_process_request
{
	my $req_info = shift;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_projects();
	my $tail = $req_info->{project_id} ? "$req_info->{path}" : q{};

	my $resp;
	if ($req_info->{method} eq 'GET' or $req_info->{method} eq 'DELETE') {
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

sub tasks_parse_request
{
	my ($req, $params) = @_;

	my $path = $req->path();
	my $method = $req->method();

	my ($task_id, $tail) = split qr{/}, substr($path, 1), 2;
	my $req_info = {
		path		=> $path,
		method		=> $method,
		params		=> $params,
		task_id		=> $task_id,
	};
	return $req_info unless $tail;

	my ($property, $property_id) = split qr{/}, $tail, 2;
	$req_info->{property} = lc $property;
	$req_info->{property_id} = $property_id;

	return $req_info;
}

# for issues
sub PERMISSION_READ_ISSUE()		{ 'Read Issue' }
sub PERMISSION_CREATE_ISSUE()		{ 'Create Issue' }
sub PERMISSION_UPDATE_ISSUE()		{ 'Update Issue' }

sub PERMISSION_APPEND_ATTACHMENT()	{ 'Add Attachment' }
sub PERMISSION_DELETE_ATTACHMENT()	{ 'Delete Attachment' }

sub PERMISSION_READ_COMMENT()		{ 'Read Comment' }
sub PERMISSION_CREATE_COMMENT()		{ 'Create Comment' }
sub PERMISSION_UPDATE_COMMENT()		{ 'Update Own Comment' }

sub tasks_access_denied
{
	my ($req_info, $req) = @_;

	#return 0 if $req->param('nocheck'); # dirty hack for tests

	my $login = request_session_info($req);
	unless ($login) {
		$req_info->{status} = HTTP_UNAUTHORIZED;
		return 1;
	}

	#FIXME: check for other permissions (i don't want to do it)

	return 0;
}

sub tasks_get_id
{
	my $json = eval { from_json(shift) };
	return unless $json;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_projects();

	my $request = HTTP::Request->new('POST');
	$request->uri("$base_url/$json->{project_id}/incAndGetLastTaskId");

	my $resp = $ua->request($request);
	return unless $resp->code() == HTTP_OK;

	my $resp_content = eval { from_json($resp->content()) };
	return unless $resp_content;

	$json->{id} = $resp_content->{LastTaskId};

	return to_json($json);
}

sub tasks_process_request
{
	my $req_info = shift;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_tasks();
	my $tail = $req_info->{task_id} ? "$req_info->{path}" : q{};

	my $resp;
	if ($req_info->{method} eq 'GET' or $req_info->{method} eq 'DELETE') {
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

		# this is new task creation
		if (not $tail and $req_info->{method} eq 'POST') {
			my $body = tasks_get_id($req_info->{params});
			return 400, [], [ 'tasks_get_id failed' ] unless $body;

			$request->content($body);
		}

		$resp = $ua->request($request);
	}
	my $content = $resp->content();

	return ($resp->code(), [ 'Content-Length' => length $content ], [ $content ]);
}

sub users_parse_request
{
	my ($req, $params) = @_;

	my $path = $req->path();
	my $method = $req->method();
	my ($login, $request) = split qr{/}, substr($path, 1);

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
	my ($req_info, $req) = @_;

	#return 0 if $req->param('nocheck'); # dirty hack for tests

	# registration
	return 0 if $req_info->{method} eq 'POST' and not $req_info->{login};

	my $login = request_session_info($req);
	unless ($login) {
		$req_info->{status} = HTTP_UNAUTHORIZED;
		return 1;
	}
	$req_info->{session_login} = $login;

	# everyone can read others
	return 0 if $req_info->{method} eq 'GET';

	# everyone may update self
	return 0 if $req_info->{login} and $req_info->{login} eq $login;

	# nobody can modify others
	$req_info->{status} = HTTP_FORBIDDEN;

	return 1;
}

sub users_process_request
{
	my $req_info = shift;

	my $ua = LWP::UserAgent->new(timeout => 5);
	my $base_url = __base_path_for_users();
	my $tail = $req_info->{login} ? "$req_info->{path}" : q{};

	my $resp;
	if ($req_info->{method} eq 'GET') {
		# this is self request
		if ($req_info->{path} eq '/' and not @{ $req_info->{params} }) {
			$req_info->{params} = {
				logins => $req_info->{session_login},
			};
		}

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
