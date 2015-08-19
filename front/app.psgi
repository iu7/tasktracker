use strict;
use warnings;

use Plack;
use Template;
use File::Basename;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use HTTP::Status qw(:constants);

sub TEMPLATE_LOGIN() { 'auth.html' }
sub TEMPLATE_INDEX() { 'index.html' }

my $template = Template->new({
	RELATIVE	=> 1,
	INCLUDE_PATH	=> ['template'],
});

sub render
{
	my ($file, $vars_hash_ref) = @_;

	my $body = eval {
		my $body = q{};

		print "D Request `$file'\n";
		$template->process($file, $vars_hash_ref, \$body)
			or die 'Template process failed: ', $template->error(), "\n";

		return $body;
	};

	if ($@) {
		print {*STDERR} "Template process failed: `$@'";
		return [ HTTP_INTERNAL_SERVER_ERROR, [], [ $@ ] ];
	}

	return [ HTTP_OK, [], [ $body ] ];
}

sub redirect_to
{
	my ($req, $path) = @_;

	my $res = $req->new_response();
	$res->redirect($path);

	return $res->finalize();
}

my $login = sub {
	my $req = Plack::Request->new(shift);

	# TODO: check wether login already, and redirect to main page

	return render(TEMPLATE_LOGIN());
};

my $root = sub {
	my $req = Plack::Request->new(shift);

	my $file = $req->path() eq '/'
		 ? TEMPLATE_INDEX() : basename($req->path());

	return render($file);
};

my $main_app = builder {
	enable 'Plack::Middleware::AccessLog';
	mount '/login'    => builder { $login  };
	mount '/'         => builder { $root   };
};

