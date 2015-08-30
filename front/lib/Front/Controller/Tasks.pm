package Front::Controller::Tasks;
use Mojo::Base 'Mojolicious::Controller';

sub tasks {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $filter = $self->req()->param('filter') || q{};

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->get("$base_url/tasks?$filter", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	});

	my $json = {
		msg => $self->flash('msg'),
		tasks => ($tx->res()->json() || []),
		names => $self->task_args(),
	};

	if (not $tx->success()) {
		my $err = $tx->error();

		$self->app->log->error($err->{message});
		$json->{msg} = $err->{message};
	}

	return $self->render(args => $json);
}

sub update_task
{
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $task_id = $self->stash('task_id');
	my $project_id = $self->stash('project_id');

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->put("$base_url/tasks/$task_id", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	}, json => {
		name		=> $self->req()->param('subject'),
		type_id		=> $self->req()->param('type_id'),
		state_id	=> $self->req()->param('state_id'),
		project_id	=> $project_id,
		assignee_id	=> $self->req()->param('assignee_id'),
		priority_id	=> $self->req()->param('priority_id'),
		description	=> $self->req()->param('description'),
	});

	if ($tx->success()) {
		$self->flash(msg => 'Задача успешно обновленa');
		return $self->redirect_to("/projects/$project_id/task/$task_id");
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});
	$self->flash(msg => "Неизвестная ошибка: $err->{message} ($err->{code})");

	return $self->redirect_to("/projects/$project_id/task/$task_id");
}

sub task {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $task_id = $self->stash('task_id');
	my $project_id = $self->stash('project_id');

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->get("$base_url/tasks?id=$task_id&project_id=$project_id", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	});

	my $resp = $tx->res()->json() || [{}];
	my $json = $resp->[0];
	$json->{msg} = $self->flash('msg');

	if (not $tx->success()) {
		my $err = $tx->error();

		$self->app->log->error($err->{message});
		$json->{msg} = $err->{message};
	}

	return $self->render(
		template => 'tasks/task-edit',
		args => $self->task_args(),
		info => $json,
	);
}

sub register {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	return $self->render(msg => $self->flash('msg'), args => $self->task_args())
		if $self->req()->method() eq 'GET';

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->post("$base_url/tasks", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	}, json => {
		name		=> $self->req()->param('subject'),
		type_id		=> $self->req()->param('type_id'),
		state_id	=> $self->req()->param('state_id'),
		project_id	=> $self->req()->param('project_id'),
		creator_id	=> $login,
		priority_id	=> $self->req()->param('priority_id'),
		assignee_id	=> $self->req()->param('assignee_id'),
		description	=> ($self->req()->param('description') || q{}),
	});

	if ($tx->success()) {
		$self->flash(msg => 'Новая задача успешно создана');
		$self->app->log->info('task registration success');

		return $self->redirect_to('tasks');
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	return $self->render(
		msg => "Неизвестная ошибка: $err->{message} ($err->{code})",
		args => $self->task_args(),
	);
}

1;
