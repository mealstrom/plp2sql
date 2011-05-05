#!/usr/bin/perl -w
#===============================================================================
#
#	  FILE:  eximlog.pl
#
#	  USAGE:  ./eximlog.pl  
#
#	DESCRIPTION:  Exim log parser test
#
#	  OPTIONS:  ---
# REQUIREMENTS:	---
#	  BUGS:  ---
#	  NOTES:  check new opt
#	  AUTHOR:  Aleksander Mischenko (mealstrom), aleksander.mischenko@gmail.com
#	  COMPANY:  Liberty Lan
#	  VERSION:  1.0
#	  CREATED:  04/21/2011 01:50:03 PM
#	  REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;
use File::Tail;
use Switch;
print "#===============================================================================";
#
my $filename='/home/mealstrom/scripts/test/data.log';
open( FILE, "< $filename" ) or die "Can't open $filename : $!";
sub logparse {
	my $exim={
	type => '',
	host => {name => '',ip=>'',port=>'',},
	timestamp => '',
	mailid => '',
	messageid => '',
	return_path => '',
	senders_address => '',
	subject => '',
	envelope_from => '',
	envelope_to => '',
	message_from => '',
	message_for => '',
	localuser => '',
	size => '',
	protocol => '',
	router => '',
	transport => '',
	cmd => '', #$1=cmd  $2=envto
	cwd => '',
	args => '',
	};
	my $exim_re={
	type => '((\<\=)|(\=\>)|(\*\*)|(\=\=)|(\-\>)|(\*\>)|(\<\>)|(Completed)|(no immediate delivery))',
	timestamp => '(\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2})\W',
	mailid => '(\w{6}-\w{6}-\w{2})\W',
	messageid => 'id=(.+?)\@',
	return_path => 'P=\<(.+?)\>',
	senders_address => 'F=\<(.+?)\>',
	host => 'H=(.+?)\s\[(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})\]:(\d{1,5})',#$1=hostname; $2=hostip; $3=hostport
	subject => 'T="(.+?)"\W',
	envelope_from => '\<\=\W(.+?)\s',
	envelope_to => '\=\> (w]{1,64}@[\w]{1,64}\.[\w]{2,6})',
	message_from => 'from\W\<(.+?)\>\W',
	message_for => 'for\W(.+?)$',
	localuser => 'U=(.+?)\W',
	size => 'S=(\d+)',
	protocol => 'P=(.+?)\W',
	router => 'R=(.+?)\W',
	transport => 'T=(.+?)\W',
	cmd => '\=\>\W(.+?)\s\<(.+?)\>', #$1=cmd  $2=envto
	cwdargs => 'cwd=(.+?)\W\d\Wargs:\W(.*)',
	};
	my ($line) = @_;
#print line
	print "\n$line\n";
	if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}$exim_re->{type}/){
		$exim->{timestamp}=$1;
		$exim->{mailid}=$2;
		$exim->{type}=$3
	}
	switch ($exim->{type}) {
		case '<=' {#arrival	
			if($line =~ /$exim_re->{host}/){
				$exim->{host}->{name}=$1;
				$exim->{host}->{ip}=$2;
				$exim->{host}->{port}=$3;
			}
			if($line =~ /$exim_re->{subject}/){$exim->{subject}=$1}
			if($line =~ /$exim_re->{messageid}/){$exim->{messageid}=$1}
			if($line =~ /$exim_re->{envelope_from}/){$exim->{envelope_from}=$1}
			if($line =~ /$exim_re->{message_from}/){$exim->{message_from}=$1}
			if($line =~ /$exim_re->{message_for}/){$exim->{message_for}=$1}
			if($line =~ /$exim_re->{protocol}/){
				$exim->{protocol}=$1;
				if($exim->{protocol} =~ /local/){
					$exim->{host}->{ip}="127.0.0.1";
					$exim->{host}->{port}="0";
					$exim->{host}->{name}="localhost";
				}
				if($line =~ /$exim_re->{localuser}/x){$exim->{localuser}=$1}
			}
			if($line =~ /$exim_re->{size}/){$exim->{size}=$1}
		}
		case '=>' {# normal message delivery
			if($line =~ /$exim_re->{host}/){
				$exim->{host}->{name}=$1;
				$exim->{host}->{ip}=$2;
				$exim->{host}->{port}=$3
			}
			if($line =~ /$exim_re->{senders_address}/){$exim->{senders_address}=$1}
			if($line =~ /$exim_re->{return_path}/){$exim->{return_path}=$1}
			if($line =~ /$exim_re->{router}/){$exim->{router}=$1}
			if($line =~ /$exim_re->{transport}/){$exim->{transport}=$1}
			if($line =~ /$exim_re->{cmd}/){
				$exim->{cmd}=$1;
				$exim->{envelope_to}=$2;
				if($exim->{router} =~ /mail4root/){
					$exim->{host}->{ip}="127.0.0.1";
					$exim->{host}->{port}="0";
					$exim->{host}->{name}="localhost";
				}
			}
			elsif ($line =~ /$exim_re->{envelope_to}/){$exim->{envelope_to}=$1}
			if($line =~ /$exim_re->{size}/){$exim->{size}=$1}
		}
		case '**' {# delivery failed; address bounced
			if($line =~ /P=\<(.+?)\>/){$exim->{return_path}=$1}
		}
		case 'no immediate delivery'{
			$exim->{type}='error';
			if($line =~ /no immediate delivery:(.*)/){
				$exim->{error}->{type}="no immediate delivery";
				$exim->{error}->{msg}=$1;
			}
			if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}/){$exim->{timestamp}=$1;$exim->{mailid}=$2}
		}
	
#		case '->' {	print "$timestamp $type $mailid \n" } # additional address in same delivery
#		case '*>' {	print "$timestamp $type $mailid \n" }	# delivery suppressed by -N
#		case '<>' {	print "$timestamp $type $mailid \n" } # bounce message
		case 'Completed' {
		}  
}
	if($line =~ /incomplete transaction/){
		if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}/){
			$exim->{timestamp}=$1;
			$exim->{mailid}=$2
		}
		$exim->{type}='error';
		$exim->{error}->{type}="smtp_incomplete_transaction";
		$exim->{error}->{msg}="incomplete transaction (QUIT)";
		if($line =~ /$exim_re->{message_for}/){$exim->{message_for}=$1}
		if($line =~ /$exim_re->{message_from}/){$exim->{message_from}=$1}
		if($line =~ /$exim_re->{host}/){$exim->{host}->{name}=$1;$exim->{host}->{ip}=$2;$exim->{host}->{port}=$3;}
	}
	if($line =~ /$exim_re->{timestamp}$exim_re->{cwdargs}/){
		$exim->{timestamp}=$1;
		$exim->{cwd}=$2;
		$exim->{args}=$3;
	}

#print results
print Dumper($exim);
}

while (<FILE>) {
	logparse($_);
}
