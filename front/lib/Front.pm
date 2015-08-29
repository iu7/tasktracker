package Front;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	$self->helper(logic_base_url => sub { 'http://127.0.0.1:5010' } );

	# Router
	my $r = $self->routes();

	# main page
	$r->get('/index.html')->name('index');

	# Session
	$r->any([qw(GET POST)] => '/login')->to('session#login')->name('login');
	$r->get('/logout')->to('session#logout');

	# Users
	$r->any([qw(GET POST)] => '/signup')->to('users#signup')->name('signup');

	# Tasks

	# Projects
}

1;
