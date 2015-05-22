use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::Request;
use Plack::Response;

use Session qw(:all);

use lib qw(..);
use Wrappers::Response qw(send_response);

sub read_req_body
{
	my ($req, $buf, $len) = shift;

	$len = $req->headers()->header('Content-Length');
	$req->body()->read($buf, $len);

	return $buf;
}

my $login = sub {
	my $req = Plack::Request->new(shift);

	return send_response(405 , [], [])
		if $req->method() ne 'POST';

	my ($status, $body) = session_login(read_req_body($req));

	return send_response($status, [ 'Content-Length' => length $body ], [ $body ]);
};

my $check = sub {
	my $req = Plack::Request->new(shift);

	return send_response(405 , [], [])
		if $req->method() ne 'GET';

	my ($status, $body) = session_check({
		id	=> $req->param('id'),
		token	=> $req->param('token'),
	});

	return send_response($status, [ 'Content-Length' => length $body ], [ $body ]);
};

my $logout = sub {
	my $req = Plack::Request->new(shift);

	return send_response(405 , [], [])
		if $req->method() ne 'PUT';

	my ($status, $body) = session_logout(read_req_body($req));

	return send_response($status, [], [ $body ]);
};

my $not_found = sub {
	return send_response(404, [], []);
};

my $main_app = builder {
	enable 'Plack::Middleware::AccessLog';
	mount '/session/login'  => builder { $login     };
	mount '/session/check'  => builder { $check     };
	mount '/session/logout' => builder { $logout    };
	mount '/'               => builder { $not_found };
};
