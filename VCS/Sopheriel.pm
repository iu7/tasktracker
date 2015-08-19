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

# TODO: `refs'
sub grep_task_info
{
	my $message = shift;

	return {} if $message !~ /(?: fixes | closes)/msxig;
	my @tasks_list = $message =~ / \# (\d+) /msxg;

	return {
		close_list => [ @tasks_list ],
	};
}

sub process_payload
{
	my $payload_ref = shift;

	my $tasks_ref = grep_task_info($payload_ref->{commit_message});
	foreach my $task (@{ $tasks_ref->{close_list} }) {
		print {*STDERR} "close task `$task'\n"
		# TODO: send request to tasks backend
	}

}

sub callback {
	my $var = shift;

	my $body = $var->{body}->{payload} || {};
	if (my $payload = eval { from_json($body) }) {
		process_payload($payload);
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
