#!/usr/bin/perl -w
#===============================================================================
# Something good to know:
# 1. dont forget  use Mail::RFC822::Address qw(valid);
# tnx to http://stackoverflow.com/users/221213/karaszi-istvan
# 2. Current table realization: arrival delivery
#===============================================================================
use strict;
use warnings;
use Data::Dumper;
use Switch;
use MMStructure; #$exim_str and $exim_re
#===============================================================================
#my $filename='./arrival.log';
#my $filename='./complete.log';
my $filename='./data.test';
#my $filename='./error.msg';
#my $filename='./cwd.log';
open( FILE, "< $filename" ) or die "Can't open $filename : $!";
sub logparse {
	my $exim = '';
	$exim= $exim_str;
	my $line='';
	($line) = @_;
	if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}$exim_re->{type}/){
		$exim->{timestamp}=$1;
		$exim->{mailid}=$2;
		$exim->{type}=$3
	}
	switch ($exim->{type}) {
		case '<=' {#arrival	
			$exim->{action}='arrival';
			if($line =~ /$exim_re->{host}/){
				$exim->{host}->{name}=$1;
				$exim->{host}->{ip}=$2;
				$exim->{host}->{port}=$3;
			}
			if($line =~ /$exim_re->{subject}/){$exim->{subject}=$1}
			if($line =~ /$exim_re->{messageid}/){$exim->{messageid}=$1}
			if($line =~ /$exim_re->{envelope_from}/){$exim->{envelope_from}=$1}
			if($line =~ /$exim_re->{message_from}/){$exim->{message_from}=$1}
			if($line =~ /$exim_re->{message_for}/){
				$exim->{message_for}=$1;
				$exim->{msg_rcpt_num}=($exim->{message_for} =~ tr/\@// )
			}
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
			$exim->{action}='delivery';
			if($line =~ /$exim_re->{host}/){
				$exim->{host}->{name}=$1;
				$exim->{host}->{ip}=$2;
				$exim->{host}->{port}=$3
			}
			if($line =~ /$exim_re->{senders_address}/){$exim->{senders_address}=$1}
			if($line =~ /$exim_re->{return_path}/){$exim->{return_path}=$1}
			if($line =~ /$exim_re->{router}/){$exim->{router}=$1}
			if($line =~ /$exim_re->{transport}/){$exim->{transport}=$1}
		#	if($line =~ /$exim_re->{cmd}/){
		#		$exim->{cmd}=$1;
		#		$exim->{envelope_to}=$2;
		#	}
			if($line =~ /$exim_re->{envelope_to}/){$exim->{envelope_to}=$1}
			if($exim->{router} =~ /mail4root/ || $exim->{router} =~ /virt_domains/){
				$exim->{host}->{ip}="127.0.0.1";
				$exim->{host}->{port}="0";
				$exim->{host}->{name}="localhost";
			}
			if($line =~ /$exim_re->{size}/){$exim->{size}=$1}
		}
		case '**' {# delivery failed; address bounced
			if($line =~ /P=\<(.+?)\>/){$exim->{return_path}=$1}
		}
		case 'no immediate delivery'{
			$exim->{action}='error';
			$exim->{type}='error';
			if($line =~ /no immediate delivery:(.*)/){
				$exim->{error}->{type}="no immediate delivery";
				$exim->{error}->{msg}=$1;
			}
			if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}/){$exim->{timestamp}=$1;$exim->{mailid}=$2}
		}
	
#		case '->' {	print "$timestamp $type $mailid \n" } # additional address in same delivery
#		case '*>' {	print "$timestamp $type $mailid \n" }	# delivery suppressed by -N
#		case '<= <>' {	print "$timestamp $type $mailid \n" } # bounce message
		case 'Completed' {
			$exim->{action}='complete';
			$exim->{status}='Delivered';
		}  
}
	if($line =~ /incomplete transaction/){
		if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}/){
			$exim->{timestamp}=$1;
			$exim->{mailid}=$2
		}
		$exim->{action}='error';
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
use MMSql;
updatetables($exim);
#################################
#prints structure
#################################
#print Dumper($exim);
}
################################
#clear tables
###############################
MMSql::delete_data();
#
#
printf("\n###########NEW LIFE#################");
while (<FILE>) {
	logparse($_);
}
