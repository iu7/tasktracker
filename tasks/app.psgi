use strict;
use warnings;

use JSON;
use Plack;
use Plack::Builder;
use Plack::Request;
use Plack::Response;

use Tasks qw(:all);

use lib qw(..);
use Wrappers::Response qw(send_response);

my %DISPATCH_FOR = (
	GET	=> \&dispatch_get,
	PUT	=> \&dispatch_put,
	POST	=> \&dispatch_post,
	DELETE	=> \&dispatch_delete,
);

sub dispatch_get
{
	my $req = shift;

	my $path = $req->path();
	return send_response(tasks_get($req->parameters()))
		if $path eq '/';

	my ($task_id, $action) = $path =~ m{^/ ([^/]+)/([^/]+) $}msx;
	return send_response(404, [], [])
		unless $task_id and $action;

	return send_response(tasks_comments_get($task_id, $req->parameters()))
		if $action eq 'comments';
	return send_response(tasks_files_get($task_id, $req->parameters()))
		if $action eq 'files';

	return send_response(404, [], []);
}

sub dispatch_put
{
	my $req = shift;

	my $path = $req->path();
	return send_response(404, [], [])
		if $path eq '/';

	my $json = eval { from_json($req->content()) };
	return 400, [], [ $@ ] if $@;

	return send_response(tasks_update($1, $json))
		if $path =~ m{^/ ([^/]+) $}msx;

	return send_response(tasks_comments_update($1, $2, $json))
		if $path =~ m{^/ ([^/]+) / comments / ([^/]+) $}msx;

	return send_response(404, [], []);
}

sub dispatch_post
{
	my $req = shift;

	my $json = eval { from_json($req->content()) };
	return 400, [], [ $@ ] if $@;

	my $path = $req->path();
	return send_response(tasks_create($json))
		if $path eq '/';

	my ($task_id, $action) = $path =~ m{^/ ([^/]+)/([^/]+) $}msx;
	return send_response(404, [], [])
		unless $task_id and $action;

	return send_response(tasks_comments_create($task_id, $json))
		if $action eq 'comments';
	return send_response(tasks_files_append($task_id, $json))
		if $action eq 'files';

	return send_response(404, [], []);
}

sub dispatch_delete
{
	my $req = shift;

	my $path = $req->path();
	return send_response(tasks_files_remove($1, $2, $req->parameters()))
		if $path =~ m{^/ ([^/]+) / files / ([^/]+) $}msx;

	return send_response(404, [], []);
}

my $dispatch = sub {
	my $req = Plack::Request->new(shift);

	my $method = $req->method();
	return send_response(405, [], [])
		unless exists $DISPATCH_FOR{$method};

	return $DISPATCH_FOR{$method}($req);
};

my $not_found = sub {
	return send_response(404, [], []);
};

my $main_app = builder {
	enable 'Plack::Middleware::AccessLog';
	mount '/tasks'	=> $dispatch;
	mount '/'	=> $not_found;
};
