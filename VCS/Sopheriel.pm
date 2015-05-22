package Sopheriel;

use strict;
use warnings;

use JSON;
use Net::RabbitFoot;

my $conn = Net::RabbitFoot->new()->load_xml_spec()->connect(
	host	=> 'localhost',
	port	=> 5672,

	user	=> 'guest',
	pass	=> 'guest',

	vhost	=> '/',
);

my $ch = $conn->open_channel();
$ch->declare_queue(
	queue	=> 'push_events_queue',
	durable	=> 1,
);

sub callback {
	my $var = shift;

	my $body = $var->{body}->{payload} || {};
	if (my $payload = eval { from_json($body) }) {
		use Data::Dumper;
		print Dumper $payload;

		# TODO: process it and send to backend
	} else {
		print {*STDERR} "can't decode json: $@\n";
	}

	$ch->ack();
}

$ch->qos(prefetch_count => 1);

$ch->consume(
	on_consume	=> \&callback,
	no_ack		=> 0,
);

AnyEvent->condvar->recv();
