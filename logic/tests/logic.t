use strict;
use warnings;

use JSON;
use Test::More;

use Plack::Test;
use Plack::Util;

use HTTP::Status qw(:constants);
use HTTP::Request;
use HTTP::Request::Common qw(PUT POST GET DELETE);

my $app = Plack::Util::load_psgi 'app.psgi';
my $test = Plack::Test->create($app);

# users, TODO: make it more pretty (use delete)
if (0) {
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

# TODO: udpate password

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
if (0) {
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

# projects
if (1) {
	my $content = to_json({
		name		=> 'test',
		description	=> 'Test description of our project',
		managerId	=> 'spectre',
		taskPrefix	=> 'TT',
		lastTaskId	=> 1,
		lastGroupId	=> 0,
		lastRoleId	=> 0,
		lastStateId	=> 0,
		lastPriorityId	=> 0,
		lastIssueTypeId	=> 0,
	});
# create project
	my $res = $test->request(POST '/projects', Content => $content);
	is $res->code(), HTTP_CREATED;

# check project exists
	$res = $test->request(GET '/projects/test/exist');
	is $res->code(), HTTP_OK;

	$res = $test->request(GET '/projects/non_exists_test/exist');
	is $res->code(), HTTP_NOT_FOUND;

# update manager id
	$content = to_json({ managerId => 'spectre2' });
	$res = $test->request(PUT '/projects/test/updateManager', Content => $content);
	is $res->code(), HTTP_OK;

# update description
	$content = to_json({ description => 'Another description' });
	$res = $test->request(PUT '/projects/test/updateDescription', Content => $content);
	is $res->code(), HTTP_OK;

# create new priority
	$content = to_json({ name => 'Normal', description => 'Priority of issue' });
	$res = $test->request(POST '/projects/test/issuepriorities', Content => $content);
	is $res->code(), HTTP_CREATED;

# select all priorities
	$res = $test->request(GET '/projects/test/issuepriorities');
	is $res->code(), HTTP_OK;

# select priority by id
	$res = $test->request(GET '/projects/test/issuepriorities/1');
	is $res->code(), HTTP_OK;

# delete priority
	$res = $test->request(DELETE '/projects/test/issuepriorities/1');
	is $res->code(), HTTP_OK;

# select deleted priority by id
	$res = $test->request(GET '/projects/test/issuepriorities/1');
	is $res->code(), HTTP_NOT_FOUND;


# create new state
	$content = to_json({ name => 'Done', description => 'Issue state' });
	$res = $test->request(POST '/projects/test/issuestates', Content => $content);
	is $res->code(), HTTP_CREATED;

# select all states
	$res = $test->request(GET '/projects/test/issuestates');
	is $res->code(), HTTP_OK;

# select state by id
	$res = $test->request(GET '/projects/test/issuestates/1');
	is $res->code(), HTTP_OK;

# delete state
	$res = $test->request(DELETE '/projects/test/issuestates/1');
	is $res->code(), HTTP_OK;

# select deleted state by id
	$res = $test->request(GET '/projects/test/issuestates/1');
	is $res->code(), HTTP_NOT_FOUND;


# create new types
	$content = to_json({ name => 'Bug', description => 'Issue type' });
	$res = $test->request(POST '/projects/test/issuetypes', Content => $content);
	is $res->code(), HTTP_CREATED;

# select all types
	$res = $test->request(GET '/projects/test/issuetypes');
	is $res->code(), HTTP_OK;

# select types by id
	$res = $test->request(GET '/projects/test/issuetypes/1');
	is $res->code(), HTTP_OK;

# delete type
	$res = $test->request(DELETE '/projects/test/issuetypes/1');
	is $res->code(), HTTP_OK;

# select deleted type by id
	$res = $test->request(GET '/projects/test/issuetypes/1');
	is $res->code(), HTTP_NOT_FOUND;


# create new role
	$content = to_json({ name => 'test role', description => 'role for test' });
	$res = $test->request(POST '/projects/test/roles', Content => $content);
	is $res->code(), HTTP_CREATED;

# update role name
	$content = to_json({ name => 'upd test role' });
	$res = $test->request(PUT '/projects/test/roles/1/updateName', Content => $content);
	is $res->code(), HTTP_OK;

# update role description
	$content = to_json({ description => 'upd role for test' });
	$res = $test->request(PUT '/projects/test/roles/1/updateDescription', Content => $content);
	is $res->code(), HTTP_OK;

# set permission
	$content = to_json({ name => 'Read Issue', value => 'true' });
	$res = $test->request(PUT '/projects/test/roles/1/permissions', Content => $content);
	is $res->code(), HTTP_OK;

# check permission
	$res = $test->request(GET '/projects/test/roles/1/permissions/Read Issue');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->{value}, 'true';

# unset permission
	$content = to_json({ name => 'Read Issue', value => 'false' });
	$res = $test->request(PUT '/projects/test/roles/1/permissions', Content => $content);
	is $res->code(), HTTP_OK;

# check permission
	$res = $test->request(GET '/projects/test/roles/1/permissions/Read Issue');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->{value}, 'false';

# select all roles
	$res = $test->request(GET '/projects/test/roles');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->[0]{description}, 'upd role for test';
	is $content->[0]{name}, 'upd test role';

# select role by id
	$res = $test->request(GET '/projects/test/roles/1');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->{description}, 'upd role for test';
	is $content->{name}, 'upd test role';

# delete role
	$res = $test->request(DELETE '/projects/test/roles/1');
	is $res->code(), HTTP_OK;

# select role by id (after delete)
	$res = $test->request(GET '/projects/test/roles/1');
	is $res->code(), HTTP_NOT_FOUND;


# TODO: other tests for group
# create new group
	$content = to_json({ name => 'test group', description => 'group for test' });
	$res = $test->request(POST '/projects/test/groups', Content => $content);
	is $res->code(), HTTP_CREATED;

# delete groups
	$res = $test->request(DELETE '/projects/test/groups/1');
	is $res->code(), HTTP_OK;

# select group by id (after delete)
	$res = $test->request(GET '/projects/test/groups/1');
	is $res->code(), HTTP_NOT_FOUND;


	print STDERR $res->content(), "\n";
}

# tasks: FIXME
if (1) {
}

done_testing();
