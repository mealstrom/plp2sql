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
use MMConfig; #DB parameters and server name
BEGIN {
	use base 'Exporter';
	our @ISA = qw(Exporter);
	our @EXPORT=qw(
							&reconnect
							&postparse
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
sub delete_arrival{
	$dbh->do("delete from arrival where 1=1");
	printf("deleted from arrival");
}

sub postparse{
	my $mmexim = shift;
	$mmexim->{server}=$config->{server}->{name};	
	$dbh->do("insert into $mmexim->{table}  
				values (
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
								'$mmexim->{localuser}',
								'$mmexim->{protocol}',
								'$mmexim->{status}'
						)
					");
	}

1;

