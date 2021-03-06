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
use File::Tail;
#===============================================================================
printf("start");
my $filename="/home/mealstrom/git-projects/plp2sql/gendata.log";
my $file=File::Tail->new(name=>$filename,interval=>5, maxinterval=>15, adjustafter=>5,ignore_nonexistant=>1,reset_tail=>1,reset_after=>35,tail=>-1);
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
				msg_rcpt_num => '',#dont know if needed
				localuser => '',
				size => '',
				protocol => '',
				router => '',
				transport => '',
		#   cmd => '', #$1=cmd  $2=envto
				cwd => '',
				args => '',
				action => '',
				status => '',
				server => '',
				error_msg => '',
			};
	my $line='';
	($line) = @_;
	$exim->{action}='';
	if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}$exim_re->{type}/){
		$exim->{timestamp}=$1;
		$exim->{mailid}=$2;
		$exim->{type}=$3
	}
	switch ($exim->{type}) {
		case '<=' {#arrival	
			$exim->{action}='arrival';
			$exim->{status}='arrived';
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
			$exim->{status}='delivered';
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
		#** alkesander.mischenko@gmail.com F=<spam@mail.mealstrom.org.ua> P=<spam@mail.mealstrom.org.ua> R=dnslookup T=remote_smtp:
		#** spam@hahaha.com.ua.tw F=<spam@mail.mealstrom.org.ua>: Unrouteable address
			$exim->{action}='error';
			$exim->{status}='bounced';
			if($line =~ /$exim_re->{envelope_to}/){$exim->{envelope_to}=$1}
			if($line =~ /$exim_re->{senders_address}/){$exim->{senders_address}=$1}
			if($line =~ /$exim_re->{return_path}/){$exim->{return_path}=$1}
			if($line =~ /$exim_re->{router}/){$exim->{router}=$1}
			if($line =~ /$exim_re->{transport}/){$exim->{transport}=$1}
			if($line =~ /$exim_re->{error_msg}/){$exim->{error_msg}=$1}
		}
		case 'no immediate delivery'{
#			$exim->{action}='error';
#			$exim->{type}='error';
#			if($line =~ /no immediate delivery:(.*)/){
#				$exim->{error}->{type}="no immediate delivery";
#				$exim->{error}->{msg}=$1;
#			}
#			if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}/){$exim->{timestamp}=$1;$exim->{mailid}=$2}
		}
	
#		case '->' {	print "$timestamp $type $mailid \n" } # additional address in same delivery
#		case '*>' {	print "$timestamp $type $mailid \n" }	# delivery suppressed by -N
#		case '<= <>' {	print "$timestamp $type $mailid \n" } # bounce message
		case 'Completed' {
			$exim->{action}='complete';
			$exim->{status}='Finished';
		}  
		case 'SMTP' {$exim->{action}=''};
	}
#	if($line =~ /incomplete transaction/){
#		if($line =~ /$exim_re->{timestamp}$exim_re->{mailid}/){
#			$exim->{timestamp}=$1;
#			$exim->{mailid}=$2
#		}
#		$exim->{action}='error';
#		$exim->{type}='error';
#		$exim->{error}->{type}="smtp_incomplete_transaction";
#		$exim->{error}->{msg}="incomplete transaction (QUIT)";
#		if($line =~ /$exim_re->{message_for}/){$exim->{message_for}=$1}
#		if($line =~ /$exim_re->{message_from}/){$exim->{message_from}=$1}
#		if($line =~ /$exim_re->{host}/){$exim->{host}->{name}=$1;$exim->{host}->{ip}=$2;$exim->{host}->{port}=$3;}
#	}
#	if($line =~ /$exim_re->{timestamp}$exim_re->{cwdargs}/){
#		$exim->{timestamp}=$1;
#		$exim->{cwd}=$2;
#		$exim->{args}=$3;
#	}
	if($line =~ /\WDKIM:\W/){
		$exim->{action}='dkim'
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
while (defined(my $line1=$file->read)){
printf("$line1");
	logparse($line1);
}
