package IKAR;

use strict;
use warnings;

use JSON;
use Net::RabbitFoot;
use Github::Hooks::Receiver;

my ($__chain, $__conn);

BEGIN {
	$__conn = Net::RabbitFoot->new()->load_xml_spec()->connect(
		host	=> 'localhost',
		port	=> 5672,

		user	=> 'guest',
		pass	=> 'guest',

		vhost	=> '/',
	);

	$__chain = $__conn->open_channel();
	$__chain->declare_queue(
		queue	=> 'push_events_queue',
		durable	=> 1,
	);
}

my $receiver = Github::Hooks::Receiver->new();
$receiver->on(push => sub {
	my ($event, $req) = @_;

	print "Received new push event, append to queue\n";
	$__chain->publish(
		exchange	=> '',
		routing_key	=> 'push_events_queue',
		body		=> to_json($event->payload()),
	);
});

my $app = $receiver->to_app();

END {
	$__conn->close();
}
