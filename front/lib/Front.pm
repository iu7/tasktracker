package Front;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	$self->helper(logic_base_url		=> sub { 'http://127.0.0.1:5010' } );
	$self->helper(header_session_id		=> sub { 'X-Session-Id' } );
	$self->helper(header_session_token	=> sub { 'X-Session-Token' } );
	$self->helper(task_args			=> sub { return {
		priorities => [
			'prio1',
			'prio2',
			'prio3',
		],
		states => [
			'state1',
			'state2',
			'state3',
		],
		types => [
			'type1',
			'type2',
			'type3',
		],
	}});

	# Router
	my $r = $self->routes();

	# main page
	$r->get('/index.html')->name('index');

	# Session
	$r->any([qw(GET POST)] => '/login')->to('session#login')->name('login');
	$r->get('/logout')->to('session#logout');

	# Users
	$r->any([qw(GET POST)] => '/signup')->to('users#signup')->name('signup');
	$r->get('/profile')->to('users#profile')->name('profile');
	$r->post('/profile/name')->to('users#update_name')->name('users_update_name');
	$r->post('/profile/pass')->to('users#update_pass')->name('users_update_pass');
	$r->post('/profile/email')->to('users#update_email')->name('users_update_email');

	# Projects
	$r->any([qw(GET POST)] => '/projects/register')->to('projects#register')->name('new_project');
	$r->get('/projects')->to('projects#projects')->name('projects');
	$r->post('/projects/:project_id/description')->to('projects#update_description')->name('projects_update_description');
	$r->get('/projects/:project_id')->to('projects#project')->name('project');

	# Tasks
	$r->any([qw(GET POST)] => '/tasks/register')->to('tasks#register')->name('new_task');
	$r->post('/projects/:project_id/task/:task_id')->to('tasks#update_task');
	$r->get('/projects/:project_id/task/:task_id')->to('tasks#task');
	$r->get('/tasks')->to('tasks#tasks')->name('tasks');

	# TODO: files and comments
}

1;
