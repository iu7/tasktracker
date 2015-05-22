use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use LWP::UserAgent;

use Logic qw(:all);

use lib qw(..);
use Wrappers::Response qw(send_response);

use feature qw(switch);

sub read_req_body
{
	my ($req, $buf, $len) = shift;

	$len = $req->headers()->header('Content-Length');
	$req->body()->read($buf, $len);

	return $buf;
}

sub get_session_info
{
	my $req = shift;

	return {
		id	=> $req->header('X-Session-Id'),
		token	=> $req->header('X-Session-Token'),
	};
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
my $projects = sub {
	my $env = shift;

	return send_response(500, [], [ 'not implemented yet' ]);
};

my $tasks = sub {
	my $env = shift;

	return send_response(500, [], [ 'not implemented yet' ]);
};

# /users
# /users/{login}/updateName
# /users/{login}/updateEmail
# /users/{login}/resetPassword
# /users/{login}
# /users
my $users = sub {
	my $env = shift;

	return send_response(500, [], [ 'not implemented yet' ]);
};

my $session = sub {
	my $req = Plack::Request->new(shift);

	my $path = $req->path();
	if ($path =~ m{^ /login  $}msx) {
		return send_response(405 , [], [])
			if $req->method() ne 'POST';

		return send_response(session_login(read_req_body($req), get_session_info($req)));
	}

	if ($path =~ m{^ /logout $}msx) {
		return send_response(405 , [], [])
			if $req->method() ne 'PUT';

		return send_response(session_logout(read_req_body($req), get_session_info($req)));
	}

	return send_response(404, [], ['session: unknown request: ' . $path]);
};

my $not_found = sub {
	return send_response(404, [], []);
};

my $app = builder {
	enable 'Plack::Middleware::AccessLog';
	mount '/users'		=> builder { $users     };
	mount '/tasks'		=> builder { $tasks     };
	mount '/session'	=> builder { $session   };
	mount '/projects'	=> builder { $projects  };
	mount '/'		=> builder { $not_found };
};
