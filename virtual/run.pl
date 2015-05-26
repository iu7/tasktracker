use strict;
use warnings;

use autodie qw(:all);
use Getopt::Long;

my ($share_path, $share_tag, $vde_switch, $mac, $from_to_pair, $memory);

$memory = 256;
GetOptions(
	'mem=s'		=> \$memory,
	'tag=s'		=> \$share_tag,
	'path=s'	=> \$share_path,

	'switch=s'	=> \$vde_switch,
	'mac=s'		=> \$mac,

	'from_to=s'	=> \$from_to_pair,
) or die usage();
my $image = shift or die usage();

my @share_folder_options;
if ($share_path) {
	die usage() unless $share_tag;
	push @share_folder_options,
		qq(-virtfs local,id=${share_tag}__id,path=$share_path,security_model=passthrough,mount_tag=$share_tag);
}

my @network_options;
if ($vde_switch) {
	die usage() unless $mac;
	push @network_options, "-net nic,vlan=0,macaddr=$mac";
	push @network_options, "-net vde,sock=$vde_switch,vlan=0";
}
if ($from_to_pair) {
	push @network_options, "-net user,net=10.0.0.0/8,host=10.0.0.1,hostfwd=tcp:$from_to_pair";
#	push @network_options, "-net user,vlan=1,hostfwd=tcp:$from_to_pair";
}

my @common_options = qw(-enable-kvm -daemonize);
push @common_options, "-m $memory";
system("qemu-system-x86_64 -hda $image @common_options @share_folder_options @network_options");

sub usage
{
	return "Usage: $0 [OPTIONS] <IMAGE>\n" .
	       "  Options:\n" .
	       "    --path            specify path to shared folder (tag and id also must be set)\n" .
	       "    --tag             specify `tag name' to mount inside guest os\n\n" .

	       "    --switch          specify path to `vde' socket\n" .
	       "    --mac             specify mac address for vm\n\n" .

	       "    --from_to       specify host address to redirect from ([ip]:port-[ip]:port)\n";
}
