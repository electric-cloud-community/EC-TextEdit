##########################
# extract.pl
##########################
use warnings;
use strict;
use Encode;
use utf8;
use open IO => ':encoding(utf8)';

## Create ElectricCommander instance
my $ec = new ElectricCommander();
$ec->abortOnError(0);

my $opts;

$opts->{file_path}      = ($ec->getProperty("file_path"))->findvalue('//value')->string_value;
$opts->{regex}          = ($ec->getProperty("regex"))->findvalue('//value')->string_value;
$opts->{matches_outpsp} = ($ec->getProperty("matches_outpsp"))->findvalue('//value')->string_value;

$[/myProject/procedure_helpers/preamble]

$textedit->extractText();
exit($opts->{exitcode});
