package Wrappers::Response;

use strict;
use warnings;

use Net::Statsd;

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

	$Net::Statsd::HOST = $args{host};
	$Net::Statsd::PORT = $args{port};
	$__monitoring_info{service} = $args{service};
}

sub send_response
{
	my ($status, $headers, $body) = @_;

	my $status_folder = $status - $status % 100; # 100, 200, 300, 400, 500
	my $path = join(q{.}, 'servers', $__monitoring_info{service}, $status_folder);

	Net::Statsd::increment($path);

	return [ $status, $headers, $body ];
}

1;
