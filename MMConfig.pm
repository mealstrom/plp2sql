#
#===============================================================================
#
#         FILE:  MMConfig.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Aleksander Mischenko (mealstrom), aleksander.mischenko@gmail.com
#      COMPANY:  Liberty Lan
#      VERSION:  1.0
#      CREATED:  05/12/2011 10:20:46 AM
#     REVISION:  ---
#===============================================================================
package MMConfig;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw($config);
our $config = {
	'sql' => {
		'DBI'      => 'DBI:mysql:database=plp2sql',
		'user'     => 'perluser',
		'pass'     => 'LWFcPtdG3s4uuCMU',
	},
	'server' => {
		'name'		=> 'dreamguard',
	}
};
1;






