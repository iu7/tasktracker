package Tasks;

use strict;
use warnings;

use JSON;
use Config::Std;

use lib qw(../Wrappers);
use DB::DBProxy qw(:all);

use lib qw(..);
use Wrappers::Response qw(response_wrapper_initialize);

use base qw(Exporter);
our @EXPORT_OK = qw(
	tasks_get
	tasks_create
	tasks_update

	tasks_comments_get
	tasks_comments_create
	tasks_comments_update

	tasks_files_get
	tasks_files_append
	tasks_files_remove
);
our %EXPORT_TAGS = (
	all => [ @EXPORT_OK ],
);

sub TABLE_NAME_TASKS()		{ 'tasks' }
sub TABLE_NAME_FILES()		{ 'files' }
sub TABLE_NAME_COMMENTS()	{ 'comments' }

BEGIN {
	my $path2config = "$ENV{ETC_DIRECTORY}/tasks.conf";
	my %__config;

	read_config($path2config, %__config);
	db_proxy_initialize($__config{DATABASE});
	response_wrapper_initialize(
		service => 'tasks',
		host    => $__config{MONITORING}{host},
		port    => $__config{MONITORING}{port},
	);

	# Check for tables
	foreach my $table (TABLE_NAME_TASKS(), TABLE_NAME_COMMENTS(), TABLE_NAME_FILES()) {
		die "Table `$table' not exists"
			unless db_proxy_table_exists($table);
	}
}

sub tasks_get
{
	my $args_ref = shift;

	my $limit  = $args_ref->{limit}  // 'ALL';
	my $offset = $args_ref->{offset} // 0;

	my @possible_keys = qw(id name description project_id
			       priority_id type_id state_id assignee_id
			       creator_id creation_date modification_date);
	my @specified_keys = grep { exists $args_ref->{$_} } @possible_keys;
	my @pairs = map { "$_=?" } @specified_keys;
	my $where = (join ' and ', @pairs) || '1 = 1';

	my $table = TABLE_NAME_TASKS();
	my $ret = eval { db_proxy_select_array(qq{
		SELECT *
		FROM $table
		WHERE $where
		LIMIT $limit
		OFFSET $offset
	}, 'use_hashes', @{$args_ref}{@specified_keys})};
	return 500, [], [ $@ ] if $@;

	return 200, [], [ to_json($ret) ];
}

sub tasks_create
{
	my $json = shift;

	my $table = TABLE_NAME_TASKS();
	my $ret = eval { db_proxy_execute_query(qq{
		INSERT INTO $table (id, name, description, project_id,
				    priority_id, type_id, state_id, assignee_id,
				    creator_id, creation_date, modification_date)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, now(), now())
		RETURNING *
	}, $json->{id}, $json->{name}, $json->{description}, $json->{project_id},
	   $json->{priority_id}, $json->{type_id}, $json->{state_id},
	   $json->{assignee_id}, $json->{creator_id})};
	return 500, [], [ $@ ] if $@;

	return 201, [], [ to_json($ret->[0]) ];
}

sub tasks_update
{
	my ($task_id, $json) = @_;

	my @valid_keys;
	my @pairs = ('modification_date=now()');

	my @keys = qw(name description priority_id type_id state_id assignee_id);
	foreach my $key (@keys) {
		next unless exists $json->{$key};

		push @pairs, "$key=?";
		push @valid_keys, $key;
	}

	my $set = join q{,}, @pairs;
	my $table = TABLE_NAME_TASKS();
	my $ret = eval { db_proxy_execute_query(qq{
		UPDATE $table
		SET $set
		WHERE id=? and project_id=?
		RETURNING *
	}, @{$json}{@valid_keys}, $task_id, $json->{project_id})};
	return 500, [], [ $@ ] if $@;

	return 200, [], [ to_json($ret->[0]) ];
}

sub tasks_comments_get
{
	my ($task_id, $args_ref) = @_;

	my $table = TABLE_NAME_COMMENTS();
	my $ret = eval { db_proxy_select_array(qq{
		SELECT *
		FROM $table
		WHERE task_id=? and project_id=?
	}, 'hash', $task_id, $args_ref->{project_id})};
	return 500, [], [ $@ ] if $@;

	return 200, [], [ to_json($ret) ];
}

sub tasks_comments_create
{
	my ($task_id, $json) = @_;

	my $table = TABLE_NAME_TASKS();
	my $ret = eval { db_proxy_execute_query(qq{
		UPDATE $table
		SET last_comment_id=last_comment_id+1,modification_date=now()
		WHERE id=? and project_id=?
		RETURNING last_comment_id
	}, $task_id, $json->{project_id})};
	return 500, [], [ $@ ] if $@;

	$table = TABLE_NAME_COMMENTS();
	my $id = $ret->[0]{last_comment_id};
	$ret = eval { db_proxy_execute_query(qq{
		INSERT INTO $table
		VALUES (?, ?, ?, ?, ?, now())
		RETURNING *
	}, $id, $json->{user_id}, $task_id, $json->{project_id}, $json->{comment})};
	return 500, [], [ $@ ] if $@;

	return 201, [], [ to_json($ret->[0]) ];
}

sub tasks_comments_update
{
	my ($task_id, $comment_id, $json) = @_;

	my $table = TABLE_NAME_COMMENTS();
	my $ret = eval { db_proxy_execute_query_noreturn(qq{
		UPDATE $table
		SET comment=?, date=now()
		WHERE id=? and task_id=? and project_id=?
	}, $json->{comment}, $comment_id, $task_id, $json->{project_id})};
	return 500, [], [ $@ ] if $@;

	return tasks_update($task_id, { project_id => $json->{project_id} });
}

sub tasks_files_get
{
	my ($task_id, $args_ref) = @_;

	my $table = TABLE_NAME_FILES();
	my $ret = eval { db_proxy_select_array(qq{
		SELECT *
		FROM $table
		WHERE task_id=? and project_id=?
	}, 'hash', $task_id, $args_ref->{project_id})};
	return 500, [], [ $@ ] if $@;

	return 200, [], [ to_json($ret) ];
}

sub tasks_files_append
{
	my ($task_id, $json) = @_;

	my $table = TABLE_NAME_TASKS();
	my $ret = eval { db_proxy_execute_query(qq{
		UPDATE $table
		SET last_file_id=last_file_id+1,modification_date=now()
		WHERE id=? and project_id=?
		RETURNING last_file_id
	}, $task_id, $json->{project_id})};
	return 500, [], [ $@ ] if $@;

	$table = TABLE_NAME_FILES();
	my $id = $ret->[0]{last_file_id};
	$ret = eval { db_proxy_execute_query(qq{
		INSERT INTO $table
		VALUES (?, ?, ?, ?, ?)
		RETURNING *
	}, $id, $json->{user_id}, $task_id, $json->{project_id}, $json->{path})};
	return 500, [], [ $@ ] if $@;

	return 201, [], [ to_json($ret->[0]) ];
}

sub tasks_files_remove
{
	my ($task_id, $file_id, $args_ref) = @_;

	my $table = TABLE_NAME_FILES();
	my $ret = eval { db_proxy_execute_query_noreturn(qq{
		DELETE FROM $table
		WHERE id=? and task_id=? and project_id=?
	}, $file_id, $task_id, $args_ref->{project_id})};
	return 500, [], [ $@ ] if $@;

	return tasks_update($task_id, { project_id => $args_ref->{project_id} });
}

1;
