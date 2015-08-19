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

	my $payload_ref = $event->payload();
	my $project_id = substr $req->path(), 1;
	my $info_ref = {
		project_id	=> $project_id,
		commit_url	=> $payload_ref->{head_commit}{url},
		commit_message	=> $payload_ref->{head_commit}{message},
	};

	print "Received new push event, append to queue\n";
	$__chain->publish(
		exchange	=> '',
		routing_key	=> 'push_events_queue',
		body		=> to_json($info_ref),
	);
});

my $app = $receiver->to_app();

END {
	$__conn->close();
}
