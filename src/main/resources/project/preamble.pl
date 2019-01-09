use ElectricCommander;
use File::Basename;
use ElectricCommander::PropDB;
use ElectricCommander::PropMod;
use Encode;
use utf8;

binmode STDOUT, ':encoding(utf8)';
binmode STDIN,  ':encoding(utf8)';
binmode STDERR, ':encoding(utf8)';

$| = 1;

use constant {
               SUCCESS => 0,
               ERROR   => 1,
             };

my $pluginKey  = 'EC-TextEdit';
my $xpath      = $ec->getPlugin($pluginKey);
my $pluginName = $xpath->findvalue('//pluginVersion')->value;
print "Using plugin $pluginKey version $pluginName\n";
$opts->{pluginVer} = $pluginName;


$opts->{JobStepId} = "$[/myJobStep/jobStepId]";

## Load the actual code into this process
if (!ElectricCommander::PropMod::loadPerlCodeFromProperty($ec, '/myProject/driver/TextEditDriver')) {
    print qq{Could not load TextEditDriver.pm\n};
    exit ERROR;
}

## Make an instance of the object, passing in options as a hash
my $textedit = new TextEditDriver($ec, $opts);
