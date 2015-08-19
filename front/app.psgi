use strict;
use warnings;

use Plack;
use Template;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use HTTP::Status qw(:constants);

my $template = Template->new({
	RELATIVE	=> 1,
	INCLUDE_PATH	=> ['../bootstrap', '../bootstrap/templates'],
});

sub BOOTSTRAP_DIR()  { '../bootstrap/' }
sub TEMPLATES_DIR()  { BOOTSTRAP_DIR() . 'templates/' }
sub TEMPLATE_LOGIN() { TEMPLATES_DIR() . 'signin/index.html' }

sub redirect_to
{
	my ($req, $path) = @_;

	my $res = $req->new_response();
	$res->redirect($path);

	return $res->finalize();
}

sub render
{
	my ($file, $vars_hash_ref) = @_;

	my $body = eval {
		my $body = q{};

		$template->process($file, $vars_hash_ref, \$body)
			or die "Template process failed: ", $template->error(), "\n";

		return $body;
	};

	if ($@) {
		print {*STDERR} "Template process failed: `$@'";
		return [ HTTP_INTERNAL_SERVER_ERROR, [], [ $@ ] ];
	}

	return [ HTTP_OK, [], [ $body ] ];
}

my $login = sub {
	my $req = Plack::Request->new(shift);

	# TODO: check wether login already, and redirect to main page

	return render(TEMPLATE_LOGIN());
};

my $root = sub {
	my $req = Plack::Request->new(shift);

	my $prefix = BOOTSTRAP_DIR();
	my $path = substr $req->path(), 1;
	$path =~ s/BOOTSTRAP_DIR/$prefix/;

	return render($path);
};

my $main_app = builder {
	mount '/login'    => builder { $login  };
	mount '/'         => builder { $root   };
};
