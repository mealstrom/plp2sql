#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  sql.pl
#
#        USAGE:  ./sql.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Aleksander Mischenko (mealstrom), aleksander.mischenko@gmail.com
#      COMPANY:  Liberty Lan
#      VERSION:  1.0
#      CREATED:  05/11/2011 10:31:00 AM
#     REVISION:  ---
#===============================================================================

package MMSql;
use strict;
use warnings;
use DBI;
use Try::Tiny;
use MMConfig; #DB parameters and server name
BEGIN {
	use base 'Exporter';
	our @ISA = qw(Exporter);
	our @EXPORT=qw(
							&reconnect
							&updatetables
						);
}
my $dbh = DBI->connect(
										$config->{sql}->{DBI},
										$config->{sql}->{user},
										$config->{sql}->{pass}
);
unless (defined($dbh) && $dbh) {
	print STDERR "[exilog_sql] Can't open exilog database.\n";
 	exit(255);
};


sub reconnect {
	my $conditional = shift || 0;
	if ($conditional) {return 1 if ($dbh->ping); };
  eval {$dbh->disconnect() if (defined($dbh)); };
  $dbh = 0;
  $dbh = DBI->connect($config->{sql}->{DBI}, $config->{sql}->{user}, $config->{sql}->{pass});
  unless (defined($dbh) && $dbh) {
		 print STDERR "[exilog_sql] Can't open exilog database.\n";
  	 return 0;
  };
  return 1;
};

#clean db.arrival. only for testing  purposes;
sub delete_data{
	reconnect();
	$dbh->do("delete from arrival  where 1=1");
	$dbh->do("delete from messages where 1=1");
	$dbh->do("delete from delivery where 1=1");
	$dbh->do("delete from error where 1=1");
}
# $dbh->do($queue) or die("Can't execute $queue: $dbh->errstr\n");
sub updatetables{
	reconnect();
	my $mmexim = shift;
	$mmexim->{server}=$config->{server}->{name};
# Future improvement: try {if ()	....}
	if ($mmexim->{action} =~ /arrival/){
			my $queue="INSERT INTO messages values (
								'$mmexim->{server}',
								'$mmexim->{mailid}',
								'$mmexim->{timestamp}',
								'$mmexim->{status}',
								'0') ON DUPLICATE KEY UPDATE timestamp='$mmexim->{timestamp}'
								";
			try{$dbh->do($queue) or die ("Can't execute $queue: $dbh->errstr\n")}	
			catch{warn "\nError: $_"};
			$queue="INSERT INTO arrival values (
										'$mmexim->{server}',
										'$mmexim->{mailid}',
										'$mmexim->{timestamp}',
										'$mmexim->{messageid}',
										'$mmexim->{envelope_from}',
										'$mmexim->{message_from}',
										'$mmexim->{message_for}',
										'$mmexim->{subject}',
										'$mmexim->{size}',
										'$mmexim->{host}->{name}',
										'$mmexim->{host}->{ip}',
										'$mmexim->{host}->{port}',
										'$mmexim->{protocol}',
										'$mmexim->{localuser}'
								) ON DUPLICATE KEY UPDATE timestamp='$mmexim->{timestamp}'";
			try{$dbh->do($queue) or die("Can't execute $queue: $dbh->errstr\n");}
			catch{warn "\nError: $_";};
	}
	if ($mmexim->{action} =~ /delivery/){
			my $queue="INSERT INTO messages values (
								'$mmexim->{server}',
								'$mmexim->{mailid}',
								'$mmexim->{timestamp}',
								'$mmexim->{status}',
								'0') ON DUPLICATE KEY UPDATE status='$mmexim->{status}'
								";
			try{$dbh->do($queue) or die ("Can't execute $queue: $dbh->errstr\n")}	
			catch{warn "\nError: $_"};
			$queue="INSERT INTO delivery
						values (
										'$mmexim->{server}',
										'$mmexim->{mailid}',
										'$mmexim->{timestamp}',
										'$mmexim->{envelope_to}',
										'$mmexim->{senders_address}',
										'$mmexim->{return_path}',
										'$mmexim->{size}',
										'$mmexim->{host}->{name}',
										'$mmexim->{host}->{ip}',
										'$mmexim->{host}->{port}',
										'$mmexim->{transport}',
										'$mmexim->{router}'
						) ON DUPLICATE KEY UPDATE timestamp='$mmexim->{timestamp}'
						";
			try{$dbh->do($queue) or die("Can't execute $queue: $dbh->errstr\n")}
			catch{warn "\nError: $_";};
			$queue="update arrival
							set status='$mmexim->{status}'
							where mailid='$mmexim->{mailid}' and server='$mmexim->{server}'";
			#try{$dbh->do($queue) or die("Can't execute $queue: $dbh->errstr\n");}
			#catch{warn "\nError: $_";};
	}
	if ($mmexim->{action} =~ /complete/){
		my $queue="INSERT INTO messages
					values (
										'$mmexim->{server}',
										'$mmexim->{mailid}',
										'$mmexim->{timestamp}',
										'',
										'1'						
					) ON DUPLICATE KEY UPDATE completed=1";
		try{$dbh->do($queue) or die("Can't execute $queue: $dbh->errstr\n");}
		catch{warn "\nError: $_";};
	}
	if ($mmexim->{action} =~ /error/){
		$mmexim->{error_msg}=$dbh->quote( $mmexim->{error_msg} );
		my $queue="INSERT INTO messages values (
								'$mmexim->{server}',
								'$mmexim->{mailid}',
								'$mmexim->{timestamp}',
								'$mmexim->{status}',
								'0') ON DUPLICATE KEY UPDATE status='$mmexim->{status}'
								";
		try{$dbh->do($queue) or die ("Can't execute $queue: $dbh->errstr\n")}	
		catch{warn "\nError: $_"};
		$queue="INSERT INTO error
			 values (
							'$mmexim->{server}',
							'$mmexim->{mailid}',
							'$mmexim->{timestamp}',
							'$mmexim->{envelope_to}',
							'$mmexim->{return_path}',
							'$mmexim->{router}',
							'$mmexim->{transport}',
							$mmexim->{error_msg}
			)  ON DUPLICATE KEY UPDATE timestamp='$mmexim->{timestamp}'";
		try{$dbh->do($queue) or die("Can't execute $queue: $dbh->errstr\n");}
		catch{warn "\nError: $_";};
	}		
}
1;

