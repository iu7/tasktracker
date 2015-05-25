use strict;
use warnings;

use JSON;
use Test::More;

use Plack::Test;
use Plack::Util;

use HTTP::Status qw(:constants);
use HTTP::Request;
use HTTP::Request::Common;

my $app = Plack::Util::load_psgi 'app.psgi';
my $test = Plack::Test->create($app);

# TODO: create user at first (spectre)

{ # session
# login
my $content = '{"login":"spectre","password":"827ccb0eea8a706c4c34a16891f84e7b"}';
my $res = $test->request(POST '/session/login', Content => $content);
is $res->code(), HTTP_CREATED;

# logout
my $session_info = $res->content();
$res = $test->request(PUT '/session/logout', Content => $session_info);
is $res->code(), HTTP_OK;

# one more time
$res = $test->request(PUT '/session/logout', Content => $session_info);
is $res->code(), HTTP_UNAUTHORIZED;
}

done_testing();
