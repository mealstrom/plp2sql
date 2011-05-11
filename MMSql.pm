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

use strict;
use warnings;
use DBD::mysql;
use Data::Dumper;
package MMSql;
#my $exim123 = {
#		  'server' => 'dreamguard',
#          'protocol' => 'esmtpsa',
#          'subject' => 'SssSS :D',
#          'table' => 'arrival',
#          'size' => '763',
#          'messageid' => '1303985782.4db93e7671daa',
#          'host' => {
#                      'ip' => '127.0.0.1',
#                      'name' => 'localhost (spam.mealstrom.org.ua)',
#                      'port' => '51127'
#                    },
#          'envelope_from' => 'spam@mail.mealstrom.org.ua',
#          'mailid' => '1QFOGk-0005nQ-F8',
#          'timestamp' => '2011-04-28 13:16:22',
#          'message_from' => 'spam@mail.mealstrom.org.ua',
#          'message_for' => 'spam547@newway.com.ua',
#          'type' => '<=',
#		  'localuser' => 'mealstrom'
#        };
my $dbh = DBI->connect('DBI:mysql:test', 'perluser', 'LWFcPtdG3s4uuCMU') || die "Could not connect to database: $DBI::errstr";
sub insert_arrival{
	my $exim = shift;
	$dbh->do("INSERT INTO $exim->{table}  
				VALUES (		'$exim->{server}',
								'$exim->{mailid}',
								'$exim->{timestamp}',
								'$exim->{messageid}',
								'$exim->{envelope_from}',
								'$exim->{message_from}',
								'$exim->{message_for}',
								'$exim->{subject}',
								'$exim->{size}',
								'$exim->{host}->{name}',
								'$exim->{host}->{ip}',
								'$exim->{host}->{port}',
								'$exim->{localuser}',
								'$exim->{protocol}',
								'$exim->{status}'
						)
					");
}

$dbh->disconnect();
1;
#my $dbh = DBI->connect('DBI:mysql:test', 'perluser', 'LWFcPtdG3s4uuCMU'
#               ) || die "Could not connect to database: $DBI::errstr";
#$dbh->do('DROP TABLE exmpl_tbl');
#$dbh->do('CREATE TABLE exmpl_tbl (id INT, val VARCHAR(100))');
#$dbh->do('INSERT INTO exmpl_tbl VALUES(1, ?)', undef, 'Hello');
#$dbh->do('INSERT INTO exmpl_tbl VALUES(2, ?)', undef, 'World');
#$dbh->disconnect();

