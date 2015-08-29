package Front;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	$self->helper(logic_base_url		=> sub { 'http://127.0.0.1:5010' } );
	$self->helper(header_session_id		=> sub { 'X-Session-Id' } );
	$self->helper(header_session_token	=> sub { 'X-Session-Token' } );

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

	# Tasks
}

1;
