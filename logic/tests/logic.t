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

# users, TODO: make it more pretty (use delete)
if (1) {
# create user
	my $content = to_json({
		name		=> 'name',
		login		=> 'spectre',
		email		=> 'spectre@mail.ru',
		password	=> '827ccb0eea8a706c4c34a16891f84e7b',
	});
	my $res = $test->request(POST '/users', Content => $content);
	is $res->code(), HTTP_CREATED;

# create user (one more time)
	$content = to_json({
		name		=> 'name2',
		login		=> 'spectre2',
		email		=> 'spectre2@mail.ru',
		password	=> '827ccb0eea8a706c4c34a16891f84e7b',
	});
	$res = $test->request(POST '/users', Content => $content);
	is $res->code(), HTTP_CREATED;

# update self name
	$content = to_json({ name => 'new name' });
	$res = $test->request(PUT '/users/spectre/updateName', Content => $content);
	is $res->code(), HTTP_OK;

# update self email
	$content = to_json({ email => 'new email' });
	$res = $test->request(PUT '/users/spectre/updateEmail', Content => $content);
	is $res->code(), HTTP_OK;

# select self
	$res = $test->request(GET '/users/spectre');

	is $res->code(), HTTP_OK;
	my $json = from_json($res->content());
	is $json->{login}, 'spectre';
	is $json->{email}, 'new email';
	is $json->{name},  'new name';

# select multiple users
	$res = $test->request(GET '/users?logins=spectre,spectre2');
	is $res->code(), HTTP_OK;

# TODO: update non self user, select non self (with access and without)
}

# session
if (1) {
# login
	my $content = '{"login":"spectre","password":"827ccb0eea8a706c4c34a16891f84e7b"}';
	my $res = $test->request(POST '/session/login', Content => $content);
	is $res->code(), HTTP_CREATED;

	my $json = from_json($res->content());
	ok $json->{token};
	ok $json->{id};

# logout
	my $session_info = $res->content();
	$res = $test->request(PUT '/session/logout', Content => $session_info);
	is $res->code(), HTTP_OK;

# one more time
	$res = $test->request(PUT '/session/logout', Content => $session_info);
	is $res->code(), HTTP_UNAUTHORIZED;

# invalid login
	$content = '{"login":"spectre","password":"ccb0eea8a706c4c34a16891f84e7b"}';
	$res = $test->request(POST '/session/login', Content => $content);
	is $res->code(), HTTP_UNAUTHORIZED;
}

done_testing();
