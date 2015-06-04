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
	$req_info->{property} = $property;

	return $req_info;
}

sub projects_access_denied
{
	my $req_info = shift;

	# FIXME + authorized + has permissions

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

	die 'not implemented yet';
}

sub tasks_access_denied
{
	my $req_info = shift;

	# FIXME

	return 0;
}

sub tasks_process_request
{
	my $req_info = shift;
	die 'not implemented yet';
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
