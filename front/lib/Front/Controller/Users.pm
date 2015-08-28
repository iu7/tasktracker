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

1;
