##########################
# add.pl
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

$opts->{file_path}       = ($ec->getProperty("file_path"))->findvalue('//value')->string_value;
$opts->{insertion_point} = ($ec->getProperty("insertion_point"))->findvalue('//value')->string_value;
$opts->{regex}           = ($ec->getProperty("regex"))->findvalue('//value')->string_value;
$opts->{search}          = ($ec->getProperty("search"))->findvalue('//value')->string_value;
$opts->{text}            = ($ec->getProperty("text"))->findvalue('//value')->string_value;

$[/myProject/procedure_helpers/preamble]

$textedit->addText();
exit($opts->{exitcode});
