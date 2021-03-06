#
#===============================================================================
#
#         FILE:  MMStructure.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Aleksander Mischenko (mealstrom), aleksander.mischenko@gmail.com
#      COMPANY:  Liberty Lan
#      VERSION:  1.0
#      CREATED:  05/12/2011 01:46:36 PM
#     REVISION:  ---
#===============================================================================
package MMStructure;
use strict;
use warnings;
	use base 'Exporter';
	our @ISA = qw(Exporter);
	our @EXPORT = qw($exim_str $exim_re);
our $exim_str={
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
#	cmd => '', #$1=cmd  $2=envto
	cwd => '',
	args => '',
	action => '',
	status => '',
	server => '',
	error_msg => '',
};

our $exim_re={
  type => '((\<\= \<\>)|(\=\>)|(\*\*)|(\=\=)|(\-\>)|(\*\>)|(\<\=)|(Completed)|(no immediate delivery)|(removed by)|(SMTP))',
  timestamp => '(\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2})\W',
  mailid => '(\w{6}-\w{6}-\w{2})\W',
  messageid => 'id=(.+?)\@',
  return_path => 'P=\<([^>]*)\>',
  senders_address => 'F=\<([^>]*)\>',#http://stackoverflow.com/users/70105/mark-synowiec
  host => 'H=(.+?)\s\[(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})\]:(\d{1,5})',#$1=hostname; $2=hostip; $3=hostport
  subject => 'T="(.+?)"\W',
  envelope_from => '\<\=\W(.+?)\s',
  envelope_to => '.*?\s+<?(\S+?)>?\s+F=',
  message_from => 'from\W\<(.+?)\>\W',
  message_for => 'for\W(.+?)$',
  localuser => 'U=(.+?)\W',
  size => 'S=(\d+)',
  protocol => 'P=(.+?)\W',
  router => 'R=(.+?)\W',
  transport => 'T=(.+?)\W',
 # cmd => '\=\>\W\/(.+?)\s\<(.+?)\>', #$1=cmd  $2=envto
  cwdargs => 'cwd=(.+?)\W\d\Wargs:\W(.*)',
  error_msg =>'F=.+?\:\W(.*)',
};
1;
