use strict;
use warnings;

use Plack;
use Plack::Builder;
use Plack::Request;
use Plack::Response;

use LWP::UserAgent;

# /users
# /users/{login}/updateName
# /users/{login}/updateEmail
# /users/{login}/resetPassword
# /users/{login}
# /users
my $users = sub {
	my $env = shift;

	return [ 500, [], [ 'not implemented yet' ] ];
};

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

	return [ 500, [], [ 'not implemented yet' ] ];
};

my $tasks = sub {
	my $env = shift;

	return [ 500, [], [ 'not implemented yet' ] ];
};

# /session/login
# /session/logout
# /session/check
my $session = sub {
	my $req = Plack::Request->new(shift);

	my $ua = LWP::UserAgent->new(
		timeout => 10, # seconds
	);

	return [ 500, [], [ 'not implemented yet' ] ];
};

my $not_found = sub {
	return [ 404, [], [] ];
};

my $app = builder {
	mount '/users'		=> builder { $users     };
	mount '/tasks'		=> builder { $tasks     };
	mount '/session'	=> builder { $session   };
	mount '/projects'	=> builder { $projects  };
	mount '/'		=> builder { $not_found };
};
