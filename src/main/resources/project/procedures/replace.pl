##########################
# replace.pl
##########################
use warnings;
use strict;
use Encode;
use utf8;
use open IO => ':encoding(utf8)';

## Create ElectricCommander instance
my $ec = ElectricCommander->new();
$ec->abortOnError(0);

my $opts;

$opts->{file_path}   = ($ec->getProperty("file_path"))->findvalue('//value')->string_value;
$opts->{filters}     = ($ec->getProperty("filters"))->findvalue('//value')->string_value;
$opts->{find}        = ($ec->getProperty("find"))->findvalue('//value')->string_value;
$opts->{match_case}  = ($ec->getProperty("match_case"))->findvalue('//value')->string_value;
$opts->{replace}     = ($ec->getProperty("replace"))->findvalue('//value')->string_value;
$opts->{search_in}   = ($ec->getProperty("search_in"))->findvalue('//value')->string_value;
$opts->{search_mode} = ($ec->getProperty("search_mode"))->findvalue('//value')->string_value;

$[/myProject/procedure_helpers/preamble]

$textedit->replaceText();
exit($opts->{exitcode});
