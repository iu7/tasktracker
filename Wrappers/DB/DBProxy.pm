package DB::DBProxy;

use strict;
use warnings;

use DBI;
use Carp;
use Config::Std;

use base qw(Exporter);

our @EXPORT_OK = qw(
	db_proxy_initialize
	db_proxy_table_exists

	db_proxy_select_row
	db_proxy_select_array
	db_proxy_execute_query
	db_proxy_execute_query_noreturn
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

my %__connect_options;
sub __get_dbh
{
	my %args = @_;

	my $dbname = $__connect_options{dbname};
	my $login  = $__connect_options{login};
	my $pass   = $__connect_options{pass};

	if (not $args{rw}) {
		foreach my $ro (@{ $__connect_options{slaves} }) {
			my $dbh = eval { DBI->connect_cached(
				"dbi:Pg:dbname=$dbname;host=$ro->{host};port=$ro->{port}",
				$login, $pass, { AutoCommit => 1, RaiseError => 1 }
			)};

			return $dbh if $dbh;
		}
	}

	my $rw = $__connect_options{master};
	my $dbh = eval { DBI->connect_cached(
		"dbi:Pg:dbname=$dbname;host=$rw->{host};port=$rw->{port}",
		$login, $pass, { AutoCommit => 1, RaiseError => 1 }
	)} or croak "can't connect to `$dbname' database: " . DBI::errstr();

	return $dbh;
}

sub __ro_dbh
{
	return __get_dbh(rw => 0);
}

sub __rw_dbh
{
	return __get_dbh(rw => 1);
}

sub db_proxy_initialize
{
	my $args_ref = shift;

	$__connect_options{dbname} = $args_ref->{dbname};
	$__connect_options{login}  = $args_ref->{login};
	$__connect_options{pass}   = $args_ref->{pass};

	my ($host, $port) = split /\s+/, $args_ref->{master_addr};
	$__connect_options{master} = {
		host => $host,
		port => $port,
	};

	my $ref = ref ($args_ref->{slave_addr}) // q{};
	if ($ref ne 'ARRAY') {
		$args_ref->{slave_addr} = [ $args_ref->{slave_addr} ];
	}

	$__connect_options{slaves} = [];
	foreach my $slave (@{ $args_ref->{slave_addr} }) {
		next unless $slave;

		my ($host, $port) = split /\s+/, $slave;
		push @{ $__connect_options{slaves} }, {
			host => $host,
			port => $port
		};
	}
}

sub db_proxy_select_row
{
	my ($query, @args) = @_;

	my $dbh = __ro_dbh();
	my $sth = $dbh->prepare($query);
	$sth->execute(@args)
		or croak $dbh->errstr();

	return $sth->fetchrow_hashref();
}

sub db_proxy_select_array
{
	my ($query, $use_array_of_hashes, @args) = @_;

	my $dbh = __ro_dbh();
	my $response_type = $use_array_of_hashes ? { Slice => {} } : undef;
	my $res = $dbh->selectall_arrayref($query, $response_type, @args)
		or croak $dbh->errstr();

	return $res;
}

sub db_proxy_execute_query
{
	my ($query, @args) = @_;

	my $dbh = __rw_dbh();
	my $sth = $dbh->prepare($query);
	$sth->execute(@args);

	return $sth->fetchall_arrayref({});
}

sub db_proxy_execute_query_noreturn
{
	my ($query, @args) = @_;

	my $dbh = __rw_dbh();
	my $sth = $dbh->prepare($query);
	$sth->execute(@args);

	return 1;
}

sub db_proxy_table_exists
{
	my $table = shift;

	return db_proxy_select_row(q{
		SELECT 1
		FROM pg_tables
		WHERE schemaname='public' AND tablename=?
	}, $table);
}

1;
