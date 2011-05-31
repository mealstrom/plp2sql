#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  generator.pl
#
#        USAGE:  ./generator.pl  
#
#  DESCRIPTION: Generates incoming mail. 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Aleksander Mischenko (mealstrom), aleksander.mischenko@gmail.com
#      COMPANY:  Liberty Lan
#      VERSION:  1.0
#      CREATED:  05/20/2011 04:01:35 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use String::Random;
my $str = new String::Random;
my $numofrec=10;
open (MYFILE, '>>gendata.log');
for (my $i = 0; $i<$numofrec; $i++){
#2011-05-17 09:31:45 1QMDom-0001u8-5Y Completed 
 my $timestamp=$str->randregex('20[0-1][0-9]-[0-3][0-9]-1[0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]');
 my $msgid= $str->randregex('[0-9a-zA-Z]{6}')."-".$str->randregex('[0-9a-zA-Z]{6}')."-".$str->randregex('[0-9a-zA-Z]{2}');
 my $mail="user_$i".$str->randregex('\w{2,6}@\w{4,6}')."\.".$str->randregex('[a-z]{3}');
 print MYFILE $timestamp." ".$msgid." <= ".$mail."\n";
 print MYFILE $timestamp." ".$msgid." =>  ".($i+101).$mail."\n";
 print MYFILE $timestamp." ".$msgid." Completed\n"
}
close (MYFILE);
