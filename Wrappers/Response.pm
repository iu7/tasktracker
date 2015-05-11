package Wrappers::Response;

use strict;
use warnings;

use Net::Graphite;

use base qw(Exporter);
our @EXPORT_OK = qw(
	response_wrapper_initialize
	send_response
);
our %EXPORT_TAGS = (
	all => [ @EXPORT_OK ],
);

my %__monitoring_info;
sub response_wrapper_initialize
{
	my %args = @_;

	$__monitoring_info{host} = $args{host};
	$__monitoring_info{port} = $args{port};
	$__monitoring_info{service} = $args{service};

	$__monitoring_info{client} = __reconnect();
}

sub __reconnect
{
	my $client = eval { Net::Graphite->new(
		host => $__monitoring_info{host},
		port => $__monitoring_info{port},
	)};
	$__monitoring_info{client} = $client;

	return $client;
}

sub send_response
{
	my ($status, $headers, $body) = @_;

	my $status_folder = $status - $status % 100; # 100, 200, 300, 400, 500
	my $path = join(q{.}, 'servers', $__monitoring_info{service}, $status_folder);

	my $client = $__monitoring_info{client};
	if (not $client) {
		$client = __reconnect();
	}
	if ($client) {
		my $ok = eval { $client->send(path => $path, value => 1); 1 };
		if (not $ok) {
			__reconnect();
		}
	}

	return [ $status, $headers, $body ];
}

1;
