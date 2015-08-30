package Front::Controller::Session;
use Mojo::Base 'Mojolicious::Controller';

use Digest::MD5 qw(md5_hex);
use HTTP::Status qw(:constants);

sub logout {
	my $self = shift;

	my $id = $self->session('id');
	my $token = $self->session('token');
	return $self->redirect_to('login')
		unless $id and $token;

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->put("$base_url/session/logout", json => {
		id	=> $id,
		token	=> $token,
	});

	if (my $res = $tx->success()) {
		$self->app->log->info('logout success');
		$self->session(expires => 1);

		return $self->redirect_to('login');
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	return $self->redirect_to('login');
}

sub login {
	my $self = shift;

	return $self->render(msg => $self->flash('msg'))
		if $self->req()->method() eq 'GET';

	my $ua = Mojo::UserAgent->new();
	my $base_url = $self->logic_base_url();
	my $tx = $ua->post("$base_url/session/login", json => {
		login		=> $self->req()->param('login'),
		password	=> md5_hex($self->req()->param('password')),
	});

	if (my $res = $tx->success()) {
		my $json = $res->json();

		$self->app->log->info('login success');
		$self->session(login => $self->req()->param('login'));
		$self->session($json);

		return $self->redirect_to('index');
	}

	my $err = $tx->error();
	$self->app->log->error($err->{message});

	return $self->render(msg => 'Неверный логин или пароль');
}

1;
