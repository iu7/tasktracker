package Front::Controller::Projects;
use Mojo::Base 'Mojolicious::Controller';

sub projects {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->get("$base_url/projects", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	});

	my $json = {
		msg => $self->flash('msg'),
		projects => ($tx->res()->json() || []),
	};

	if (not $tx->success()) {
		my $err = $tx->error();

		$self->app->log->error($err->{message});
		$json->{msg} = $err->{message};
	}

	return $self->render(args => $json);
}

sub update_description {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $project_id = $self->stash('project_id');
	my $tx = $ua->put("$base_url/projects/$project_id/updateDescription", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	}, json => {
		description => $self->req()->param('description'),
	});

	if ($tx->success()) {
		$self->flash(msg => 'Описание проекта успешно обновлено');
		return $self->redirect_to("/projects/$project_id");
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});
	$self->flash(msg => "Неизвестная ошибка: $err->{message} ($err->{code})");

	return $self->redirect_to("/projects/$project_id");
}

sub project {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $project_id = $self->stash('project_id');
	my $tx = $ua->get("$base_url/projects/$project_id", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	});

	my $json = $tx->res()->json() || {};
	$json->{msg} = $self->flash('msg');

	if (not $tx->success()) {
		my $err = $tx->error();

		$self->app->log->error($err->{message});
		$json->{msg} = $err->{message};
	}

	return $self->render(template => 'projects/projects-edit', args => $json);
}

sub register {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	return $self->render(msg => $self->flash('msg'))
		if $self->req()->method() eq 'GET';

	my $name = $self->req()->param('name');
	my $prefix = $self->req()->param('prefix') || q{};
	my $description = $self->req()->param('description') || q{};

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->post("$base_url/projects", {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	}, json => {
		name => $name,
		managerId => $login,
		taskPrefix => $prefix,
		description => $description,

		lastTaskId => 0,
		lastRoleId => 0,
		lastGroupId => 0,
		lastStateId => 0,
		lastPriorityId => 0,
		lastIssueTypeId => 0
	});

	if ($tx->success()) {
		$self->flash(msg => 'Регистрация проекта успешно завершена');
		$self->app->log->info('project registration success');

		return $self->redirect_to('projects');
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	my $err_str = $err->{code} == 500
		    ? 'Проект с таким названием уже существует'
		    : "Неизвестная ошибка: $err->{message} ($err->{code})";

	return $self->render(msg => $err_str);
}

1;
