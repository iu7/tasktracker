package Front::Controller::Users;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::UserAgent;
use Digest::MD5 qw(md5_hex);

sub signup {
	my $self = shift;

	return $self->render(error => q{})
		if $self->req()->method() eq 'GET';

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->post("$base_url/users", json => {
		name		=> $self->req()->param('name'),
		email		=> $self->req()->param('email'),
		login		=> $self->req()->param('login'),
		password	=> md5_hex($self->req()->param('password')),
	});

	if ($tx->success()) {
		$self->flash(msg => 'Регистрация успешно завершена');
		$self->app->log->info('registration success');

		return $self->redirect_to('login');
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	my $err_str = $err->{code} == 500
		    ? 'Пользователь с таким логином уже существует'
		    : "Неизвестная ошибка: $err->{message} ($err->{code})";

	return $self->render(error => $err_str);
}

sub update_name {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->put("$base_url/users/$login/updateName" => {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	}, json => { name => $self->req()->param('name') });

	if ($tx->success()) {
		$self->flash(msg => 'Имя пользователя успешно изменено');
		return $self->redirect_to('profile');
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	$self->flash(msg => "Неизвестная ошибка: $err->{message} ($err->{code})");
	return $self->redirect_to('profile');
}

# email
sub update_email {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->put("$base_url/users/$login/updateEmail" => {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	}, json => { email => $self->req()->param('email') });

	if ($tx->success()) {
		$self->flash(msg => 'Email успешно изменен');
		return $self->redirect_to('profile');
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	$self->flash(msg => "Неизвестная ошибка: $err->{message} ($err->{code})");
	return $self->redirect_to('profile');
}

# pass-old, pass-new
sub update_pass {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $old_pass = md5_hex($self->req()->param('pass-old'));
	my $new_pass = md5_hex($self->req()->param('pass-new'));

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->post("$base_url/users/$login/resetPassword" => {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	}, json => {
		oldPassword	=> $old_pass,
		password	=> $new_pass,
	});

	if ($tx->success()) {
		$self->flash(msg => 'Пароль успешно изменен');
		return $self->redirect_to('profile');
	}

	my $err = $tx->error();
	if ($err->{code} == 400) {
		$self->flash(msg => 'Неверно указан текущий пароль');
		return $self->redirect_to('profile');
	}

	$self->app->log->error($err->{message});
	$self->flash(msg => "Неизвестная ошибка: $err->{message} ($err->{code})");

	return $self->redirect_to('profile');
}

sub profile {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	my $login = $self->session('login');
	return $self->redirect_to('login')
		unless $id and $token and $login;

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->get("$base_url/users/$login" => {
		$self->header_session_id()	=> $id,
		$self->header_session_token()	=> $token,
	});

	if (my $res = $tx->success()) {
		my $json = $res->json();
		return $self->render(msg => $self->flash('msg'), args => $json);
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	return $self->redirect_to('login')
		if $err->{code} == 401;

	return $self->render(msg => "Неизвестная ошибка: $err->{message} ($err->{code})", args => {});
}

1;
