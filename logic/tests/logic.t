use strict;
use warnings;

use JSON;
use Test::More;

use Plack::Test;
use Plack::Util;

use HTTP::Status qw(:constants);
use HTTP::Request;
use HTTP::Request::Common qw(PUT POST GET DELETE);

use Data::Dumper;
my $app = Plack::Util::load_psgi 'app.psgi';
my $test = Plack::Test->create($app);

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
	print Dumper $res->as_string();

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
	$res = $test->request(PUT '/users/spectre/updateName?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# update self email
	$content = to_json({ email => 'new email' });
	$res = $test->request(PUT '/users/spectre/updateEmail?nocheck=1', Content => $content);
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
	my $res = $test->request(POST '/projects?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;
	print Dumper $res->as_string();

# check project exists
	$res = $test->request(GET '/projects/test/exist?nocheck=1');
	is $res->code(), HTTP_OK;

	$res = $test->request(GET '/projects/non_exists_test/exist?nocheck=1');
	is $res->code(), HTTP_NOT_FOUND;

# update manager id
	$content = to_json({ managerId => 'spectre2' });
	$res = $test->request(PUT '/projects/test/updateManager?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# update description
	$content = to_json({ description => 'Another description' });
	$res = $test->request(PUT '/projects/test/updateDescription?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# select projects
	$res = $test->request(GET '/projects?names=test&nocheck=1');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->[0]{description}, 'Another description';
	is $content->[0]{managerId}, 'spectre2';
	is $content->[0]{name}, 'test';

# create new priority
	$content = to_json({ name => 'Normal', description => 'Priority of issue' });
	$res = $test->request(POST '/projects/test/issuepriorities?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;

# select all priorities
	$res = $test->request(GET '/projects/test/issuepriorities?nocheck=1');
	is $res->code(), HTTP_OK;

# select priority by id
	$res = $test->request(GET '/projects/test/issuepriorities/1?nocheck=1');
	is $res->code(), HTTP_OK;

# create new state
	$content = to_json({ name => 'Done', description => 'Issue state' });
	$res = $test->request(POST '/projects/test/issuestates?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;

# select all states
	$res = $test->request(GET '/projects/test/issuestates?nocheck=1');
	is $res->code(), HTTP_OK;

# select state by id
	$res = $test->request(GET '/projects/test/issuestates/1?nocheck=1');
	is $res->code(), HTTP_OK;

# create new types
	$content = to_json({ name => 'Bug', description => 'Issue type' });
	$res = $test->request(POST '/projects/test/issuetypes?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;

# select all types
	$res = $test->request(GET '/projects/test/issuetypes?nocheck=1');
	is $res->code(), HTTP_OK;

# select types by id
	$res = $test->request(GET '/projects/test/issuetypes/1?nocheck=1');
	is $res->code(), HTTP_OK;

# create new role
	$content = to_json({ name => 'test role', description => 'role for test' });
	$res = $test->request(POST '/projects/test/roles?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;

# update role name
	$content = to_json({ name => 'upd test role' });
	$res = $test->request(PUT '/projects/test/roles/1/updateName?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# update role description
	$content = to_json({ description => 'upd role for test' });
	$res = $test->request(PUT '/projects/test/roles/1/updateDescription?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# set permission
	$content = to_json({ name => 'Read Issue', value => 'true' });
	$res = $test->request(PUT '/projects/test/roles/1/permissions?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# unset permission
	#$content = to_json({ name => 'Read Issue', value => 'false' });
	#$res = $test->request(PUT '/projects/test/roles/1/permissions?nocheck=1', Content => $content);
	#is $res->code(), HTTP_OK;

# select all roles
	$res = $test->request(GET '/projects/test/roles?nocheck=1');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->[0]{description}, 'upd role for test';
	is $content->[0]{name}, 'upd test role';

# select role by id
	$res = $test->request(GET '/projects/test/roles/1?nocheck=1');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->{description}, 'upd role for test';
	is $content->{name}, 'upd test role';

# create new group
	$content = to_json({ name => 'test group', description => 'group for test' });
	$res = $test->request(POST '/projects/test/groups?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;

# update group name
	$content = to_json({ name => 'upd test group' });
	$res = $test->request(PUT '/projects/test/groups/1/updateName?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# update group description
	$content = to_json({ description => 'upd group for test' });
	$res = $test->request(PUT '/projects/test/groups/1/updateDescription?nocheck=1', Content => $content);
	is $res->code(), HTTP_OK;

# select all groups
	$res = $test->request(GET '/projects/test/groups/1?nocheck=1');
	is $res->code(), HTTP_OK;

# select group by id
	$res = $test->request(GET '/projects/test/groups/1?nocheck=1');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->{description}, 'upd group for test';
	is $content->{name}, 'upd test group';

# add user to group
	$content = to_json({ userId => 'spectre' });
	$res = $test->request(POST '/projects/test/groups/1/users?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;

# select group users
	$res = $test->request(GET '/projects/test/groups/1/users?nocheck=1');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->[0]{userId}, 'spectre';

# select group users
	$res = $test->request(GET '/projects/test/groups/1/users?nocheck=1');
	is $res->code(), HTTP_OK;

# add role to group
	$content = to_json({ roleId => 1 });
	$res = $test->request(POST '/projects/test/groups/1/roles?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;

# select group roles
	$res = $test->request(GET '/projects/test/groups/1/roles?nocheck=1');
	is $res->code(), HTTP_OK;
	$content = from_json($res->content());
	is $content->[0]{roleId}, 1;

# # select group roles
	$res = $test->request(GET '/projects/test/groups/1/roles?nocheck=1');
	is $res->code(), HTTP_OK;
}

if (0) {
	# create task
	my $content = to_json({
		name		=> 'tsk_name',
		description	=> 'descr',
		project_id	=> 'test',
		priority_id	=> 2,
		type_id		=> 3,
		state_id	=> 4,
		assignee_id	=> 5,
		creator_id	=> 6
	});
	my $res = $test->request(POST '/tasks?nocheck=1', Content => $content);
	is $res->code(), HTTP_CREATED;
	my $json = from_json($res->content());

	# update task
	my $task_id = $json->{id};
	$content = to_json({
		name		=> 'tsk_name_upd',
		description	=> 'descr_upd',
		project_id	=> 'test',
		priority_id	=> 10,
		type_id		=> 11,
		state_id	=> 12,
		assignee_id	=> 13,
	});
	$res = $test->request(PUT "/tasks/$task_id?nocheck=1", Content => $content);
	is $res->code(), HTTP_OK;

	$json = from_json($res->content());
	is $json->{name}, 'tsk_name_upd';
	is $json->{description}, 'descr_upd';
	is $json->{priority_id}, 10;
	is $json->{type_id}, 11;
	is $json->{state_id}, 12;
	is $json->{assignee_id}, 13;

	# add comment
	$content = '{"user_id":"spectre", "project_id":"test", "comment":"comment1"}';
	$res = $test->request(POST "/tasks/$task_id/comments?nocheck=1", Content => $content);
	is $res->code(), HTTP_CREATED;

	$content = '{"user_id":"spectre", "project_id":"test", "comment":"comment2"}';
	$res = $test->request(POST "/tasks/$task_id/comments?nocheck=1", Content => $content);
	is $res->code(), HTTP_CREATED;
	my $last_comment_id = from_json($res->content())->{id};

	# update comment
	$content = '{"project_id":"test", "comment":"comment3"}';
	$res = $test->request(PUT "/tasks/$task_id/comments/$last_comment_id?nocheck=1", Content => $content);
	is $res->code(), HTTP_OK;

	# get comments
	$res = $test->request(GET "/tasks/$task_id/comments?nocheck=1&project_id=test");
	is $res->code(), HTTP_OK;

	$json = from_json($res->content());
	is scalar(@{$json}), 2;

	# add file
	$content = '{"user_id":"spectre", "project_id":"test", "path":"/var/lib/mock"}';
	$res = $test->request(POST "/tasks/$task_id/files?nocheck=1", Content => $content);
	is $res->code(), HTTP_CREATED;

	$content = '{"user_id":"spectre", "project_id":"test", "path":"/var/lib/mock2"}';
	$res = $test->request(POST "/tasks/$task_id/files?nocheck=1", Content => $content);
	is $res->code(), HTTP_CREATED;
	my $last_file_id = from_json($res->content())->{id};

	# XXX: this framework send `GET' instead of delete
	# delete file
	#$res = $test->request(DELETE "/tasks/$task_id/files/$last_file_id?nocheck=1&project_id=test");
	#is $res->code(), HTTP_OK;

	# get files
	$res = $test->request(GET "/tasks/$task_id/files?nocheck=1&project_id=test");
	is $res->code(), HTTP_OK;

	$json = from_json($res->content());
	is scalar(@{$json}), 2;
}

done_testing();
