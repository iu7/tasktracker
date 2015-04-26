use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::Request;
use Plack::Response;

use Session qw(:all);

sub read_req_body
{
	my ($req, $buf, $len) = shift;

	$len = $req->headers()->header('Content-Length');
	$req->body()->read($buf, $len);

	return $buf;
}

my $login = sub {
	my $req = Plack::Request->new(shift);

	return [ 405 , [], [] ]
		if $req->method() ne 'PUT';

	my ($status, $body) = session_login(read_req_body($req));

	return [ $status, [ 'Content-Length' => length $body ], [ $body ] ];
};

my $check = sub {
	my $req = Plack::Request->new(shift);

	return [ 405 , [], [] ]
		if $req->method() ne 'GET';

	my ($status, $body) = session_check({
		id	=> $req->param('id'),
		token	=> $req->param('token'),
	});

	return [ $status, [ 'Content-Length' => length $body ], [ $body ] ];
};

my $logout = sub {
	my $req = Plack::Request->new(shift);

	return [ 405 , [], [] ]
		if $req->method() ne 'PUT';

	my ($status, $body) = session_logout(read_req_body($req));

	return [ $status, [], [ $body ] ];
};

my $not_found = sub {
	return Plack::Response->new(404)->finalize();
};

my $main_app = builder {
	mount '/login'  => builder { $login     };
	mount '/check'  => builder { $check     };
	mount '/logout' => builder { $logout    };
	mount '/'       => builder { $not_found };
};
