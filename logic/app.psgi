use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use LWP::UserAgent;
use HTTP::Status qw(:constants);

use Logic qw(:all);

use lib qw(..);
use Wrappers::Response qw(send_response);

sub get_session_info
{
	my $req = shift;

	return {
		id	=> $req->header('X-Session-Id'),
		token	=> $req->header('X-Session-Token'),
	};
}

my $projects = sub {
	return send_response(HTTP_NOT_IMPLEMENTED, [], []);
};

my $tasks = sub {
	return send_response(HTTP_NOT_IMPLEMENTED, [], []);
};

my $users = sub {
	my $req = Plack::Request->new(shift);

	my $params;
	if ($req->method() eq 'POST' or $req->method() eq 'PUT') {
		$params = $req->content();
	} else {
		$params = $req->query_parameters();
	}

	my $req_info = users_validate_request($req, $params);
	return send_response($req_info->{status}, [], [ $req_info->{error} ])
		if $req_info->{error};

	return send_response($req_info->{status}, [], [])
		if users_access_denied($req_info);

	return send_response(users_process_request($req_info));
};

my $session = sub {
	my $req = Plack::Request->new(shift);

	my $path = $req->path();
	if ($path =~ m{^ /login  $}msx) {
		return send_response(HTTP_METHOD_NOT_ALLOWED, [], [])
			if $req->method() ne 'POST';

		return send_response(session_login($req->content(), get_session_info($req)));
	}

	if ($path =~ m{^ /logout $}msx) {
		return send_response(HTTP_METHOD_NOT_ALLOWED, [], [])
			if $req->method() ne 'PUT';

		return send_response(session_logout($req->content(), get_session_info($req)));
	}

	return send_response(HTTP_NOT_FOUND, [], ['session: unknown request: ' . $path]);
};

my $not_found = sub {
	return send_response(HTTP_NOT_FOUND, [], []);
};

my $app = builder {
	enable 'Plack::Middleware::AccessLog';
	mount '/users'		=> builder { $users     };
	mount '/tasks'		=> builder { $tasks     };
	mount '/session'	=> builder { $session   };
	mount '/projects'	=> builder { $projects  };
	mount '/'		=> builder { $not_found };
};
