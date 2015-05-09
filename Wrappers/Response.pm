package Wrappers::Response;

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT_OK = qw(
	response_wrapper_initialize
	send_response
);
our %EXPORT_TAGS = (
	all => [ @EXPORT_OK ],
);

# FIXME: set monitoring system info
sub response_wrapper_initialize
{
}

sub send_response
{
	my ($status, $headers, $body) = @_;

	# TODO: send into monitoring (make it async -- anyevent)

	return [ $status, $headers, $body ];
}
