# -------------------------------------------------------------------------
# Package
#    TextEditDriver
#
# Dependencies
#    None
#
# Purpose
#    A perl library that encapsulates the logic to execute Text Edition actions on files
#
# Plugin Version
#    1.0.1
#
# Date
#    06/08/2012
#
# Engineer
#    Andres Arias
#
# Copyright (c) 2012 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

package TextEditDriver;

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use strict;
use warnings;
use XML::XPath;
use ElectricCommander;
use lib $ENV{COMMANDER_PLUGINS} . '/@PLUGIN_NAME@/agent/lib';
use Encode;
use utf8;
use Carp;
use open IO => ':encoding(utf8)';
use Readonly;
use File::Find;
use File::Copy::Recursive qw(dircopy);
use File::Path qw(mkpath rmtree);

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------

Readonly my $DEFAULT_DEBUG    => 1;
Readonly my $DEFAULT_LOCATION => "/myJob/TextEdit/";
Readonly my $DEFAULT_FILTER   => '*.*';
Readonly my $ERROR            => 1;
Readonly my $SUCCESS          => 0;

# -------------------------------------------------------------------------
# Main functions
# -------------------------------------------------------------------------

###########################################################################

=head2 new
 
  Title    : new
  Usage    : new($ec, $opts);
  Function : Object constructor for TextEditDriver.
  Returns  : TextEditDriver instance
  Args     : named arguments:
           : -_cmdr => ElectricCommander instance
           : -_opts => hash of parameters from procedures
           :
=cut

###########################################################################
sub new {
    my $class = shift;
    my $self = {
                 _cmdr => shift,
                 _opts => shift,
               };
    bless $self, $class;
    return $self;
}

###########################################################################

=head2 replaceText
 
  Title    : replaceText
  Usage    : $self->replaceText();
  Function : Read and write files, replacing text.
  Returns  : none
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub replaceText {
    my $self = shift;

    $self->initialize();
    $self->debug_msg(1, '---------------------------------------------------------------------');

    # $self->initializePropPrefix;
    if ($self->opts->{exitcode}) { return; }

    $self->debug_msg(1, 'Search Mode: ' . $self->opts->{search_mode});
    $self->debug_msg(1, 'Searching In: ' . $self->opts->{search_in});
    $self->debug_msg(1, 'Filter: ' . $self->opts->{filters}) if $self->opts->{search_in} eq 'folder';
    $self->debug_msg(1, 'Looking for: ' . $self->opts->{find});
    $self->debug_msg(1, 'Replacement: ' . $self->opts->{replace});
    $self->debug_msg(1, '---------------------------------------------------------------------');

    my @input_files = $self->list_files();

    if (!@input_files) {
        print "ERROR: No files provided.\n";
        $self->myCmdr->setProperty("/myJobStep/outcome", 'error');
    }

    #Replacements
    foreach my $file (@input_files) {

        my @outLines;    #Data we are going to output
        my $line;        #Data we are reading line by line
        my $line_count = 1;

        open my $FILE, "<", $file or croak "Unable to open $file $!";

        #Read File
        while ($line = <$FILE>) {
            push(@outLines, $line);
        }

        #Close File
        close $FILE;
        $self->debug_msg(1, "Processing file: $file ");
        $self->opts->{count} = 0;

        #Replace
        foreach my $line (@outLines) {
            $line = $self->replace($line);
        }

        #Save
        open my $OUTFILE, ">", $file or croak "Unable to open $file $!";

        print $OUTFILE @outLines;
        close $OUTFILE;

        undef(@outLines);

        $self->debug_msg(1, 'DONE! - Replaced ' . $self->opts->{count} . " occurrence(s) of '" . $self->opts->{find} . "'");
        $self->debug_msg(1, '---------------------------------------------------------------------');

    }

    return;
}

###########################################################################

=head2 replace
 
  Title    : replace
  Usage    : $self->replace($line);
  Function : Replace text.
  Returns  : line => line after processing.
  Args     : named arguments:
           : -line => a line read from a file.
           :
=cut

###########################################################################
sub replace {
    my ($self, $line) = @_;

    my $find    = $self->opts->{find};
    my $replace = $self->opts->{replace};
    my $count   = 0;

    if ($self->opts->{search_mode} eq qq{normal}) {

        if (!$self->opts->{match_case}) {
            $count = $line =~ s/\Q$find/$replace/gxsi;
        }
        else {
            $count = $line =~ s/\Q$find/$replace/gxs;
        }

    }
    else {

        if (!$self->opts->{match_case}) {
            $count = $line =~ s/$find/$replace/gxsi;
        }
        else {
            $count = $line =~ s/$find/$replace/gxs;
        }

    }

    $self->opts->{count} += $count;

    return $line;
}

###########################################################################

=head2 findText
 
  Title    : findText
  Usage    : $self->findText();
  Function : Read files, searching for text.
  Returns  : none
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub findText {
    my $self = shift;

    $self->initialize();
    $self->debug_msg(1, '---------------------------------------------------------------------');

    # $self->initializePropPrefix;
    if ($self->opts->{exitcode}) { return; }

    $self->debug_msg(1, 'Search Mode: ' . $self->opts->{search_mode});
    $self->debug_msg(1, 'Searching In: ' . $self->opts->{search_in});
    $self->debug_msg(1, 'Filter: ' . $self->opts->{filters}) if $self->opts->{search_in} eq 'folder';
    $self->debug_msg(1, 'Looking for: ' . $self->opts->{find});
    $self->debug_msg(1, '---------------------------------------------------------------------');

    my @input_files = $self->list_files();

    if (!@input_files) {
        print "ERROR: No files provided.\n";
        $self->myCmdr->setProperty("/myJobStep/outcome", 'error');
    }

    #Find
    foreach my $file (@input_files) {

        my @outLines;    #Data we are going to use
        my $line;        #Data we are reading line by line
        my $line_count = 1;

        open my $FILE, "<", $file or croak "Unable to open $file $!";

        #Read File
        while ($line = <$FILE>) {
            push(@outLines, $line);
        }

        #Close File
        close $FILE;

        $self->debug_msg(1, "Processing file: $file ");
        $self->opts->{count} = 0;

        #Find
        foreach my $line (@outLines) {
            $self->finder($line, $line_count);
            $line_count++;
        }

        undef(@outLines);

        $self->debug_msg(1, 'DONE! - Found ' . $self->opts->{count} . " occurrence(s) of '" . $self->opts->{find} . "'");
        $self->debug_msg(1, '---------------------------------------------------------------------');

    }

    return;
}

###########################################################################

=head2 finder
 
  Title    : finder
  Usage    : $self->finder($line, $line_count);
  Function : Look for specific text in a line.
  Returns  : none
  Args     : named arguments:
           : -line => a line read from a file.
           : -line_count => number of the line in a file.
           :
=cut

###########################################################################
sub finder {
    my ($self, $line, $line_count) = @_;

    my $find  = $self->opts->{find};
    my $count = 0;

    if ($self->opts->{search_mode} eq qq{normal}) {

        if (!$self->opts->{match_case}) {
            $count = $line =~ m/\Q$find/gxsi;
        }
        else {
            $count = $line =~ m/\Q$find/gxs;
        }

    }
    else {

        if (!$self->opts->{match_case}) {
            $count = $line =~ m/$find/gxsi;
        }
        else {
            $count = $line =~ m/$find/gxs;

        }

    }

    $line =~ s/\n//xsi;
    print "Match found: $line, at line $line_count\n" if $count;
    $self->opts->{count} += $count;

    return;
}

###########################################################################

=head2 extractText
 
  Title    : extractText
  Usage    : $self->extractText();
  Function : Read files, searching for text and saving matches on property sheet
  Returns  : none
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub extractText {
    my $self = shift;

    $self->initialize();
    $self->debug_msg(1, '---------------------------------------------------------------------');

    $self->initializePropPrefix;
    if ($self->opts->{exitcode}) { return; }
    $self->opts->{search_in} = 'single';

    $self->debug_msg(1, 'File: ' . $self->opts->{file_path});
    $self->debug_msg(1, 'Regular Expression: ' . $self->opts->{regex});
    $self->debug_msg(1, '---------------------------------------------------------------------');

    my @input_files = $self->list_files();

    if (!@input_files) {
        print "ERROR: No files provided.\n";
        $self->myCmdr->setProperty("/myJobStep/outcome", 'error');
    }

    #Find
    foreach my $file (@input_files) {

        my @outLines;    #Data we are going to use
        my $line;        #Data we are reading line by line

        $self->opts->{count} = 0;
        open my $FILE, "<", $file or croak "Unable to open $file $!";

        #Read File
        while ($line = <$FILE>) {
            push(@outLines, $line);
        }

        #Close File
        close $FILE;

        #Find
        $file = join('', @outLines);

        $self->extract($file);

        undef(@outLines);

        $self->debug_msg(1, 'DONE!');
        $self->debug_msg(1, '---------------------------------------------------------------------');

    }

    return;
}

###########################################################################

=head2 extract
 
  Title    : extract
  Usage    : $self->extract($file);
  Function : Look for specific text in a line and save it on a property.
  Returns  : none
  Args     : named arguments:
           : -file => content read from a file.
           :
=cut

###########################################################################
sub extract {
    my ($self, $file) = @_;

    my $find = $self->opts->{regex};
    my @matches = ($file =~ m/$find/gxsi);

    if (scalar(@matches)) {
        my $index = 1;

        map {
            do { $self->setProp('$' . "$index", $_); print '$' . "$index: $_\n"; $index++ }
        } @matches;

    }
    return;
}

###########################################################################

=head2 addText
 
  Title    : addText
  Usage    : $self->addText();
  Function : Write files, adding specific text.
  Returns  : none
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub addText {
    my $self = shift;

    $self->initialize();
    $self->debug_msg(1, '---------------------------------------------------------------------');

    # $self->initializePropPrefix;
    if ($self->opts->{exitcode}) { return; }
    $self->opts->{search_in} = 'single';

    $self->debug_msg(1, 'File: ' . $self->opts->{file_path});
    $self->debug_msg(1, 'Insertion point: ' . $self->opts->{insertion_point});
    $self->debug_msg(1, 'Search: ' . $self->opts->{search}) if $self->opts->{insertion_point} eq 'search';
    $self->debug_msg(1, 'Text to Add: ' . $self->opts->{text});
    $self->debug_msg(1, '---------------------------------------------------------------------');

    my @input_files = $self->list_files();

    if (!@input_files) {
        print "ERROR: No files provided.\n";
        $self->myCmdr->setProperty("/myJobStep/outcome", 'error');
    }

    #Find
    foreach my $file (@input_files) {

        my @outLines;    #Data we are going to use
        my $line;        #Data we are reading line by line

        $self->opts->{count} = 0;

        open my $FILE, "<", $file or croak "Unable to open $file $!";

        #Read File
        while ($line = <$FILE>) {
            push(@outLines, $line);
        }

        #Close File
        close $FILE;

        if ($self->opts->{insertion_point} eq 'end') {

            open my $OUTFILE, ">", $file or croak "Unable to open $file $!";

            #Insert Bottom
            print $OUTFILE @outLines;
            print $OUTFILE $self->opts->{text};
            close $OUTFILE;
            undef(@outLines);
        }
        else {

            #Insert Top
            if ($self->opts->{insertion_point} eq 'beginning') {
                unshift(@outLines, $self->opts->{text});

                #Save
                open my $OUTFILE, ">", $file or croak "Unable to open $file $!";
                print $OUTFILE @outLines;
                close $OUTFILE;
                undef(@outLines);

            }
            else {

                # Insert by search
                my $doc = join('', @outLines);
                $doc = $self->add($doc);
                if ($self->opts->{exitcode}) {
                    $self->debug_msg(1, '---------------------------------------------------------------------');
                    return;
                }

                #Save
                open my $OUTFILE, ">", $file or croak "Unable to open $file $!";
                print $OUTFILE $doc;
                close $OUTFILE;
                undef(@outLines);
            }

        }

        $self->debug_msg(1, 'DONE! - Text added successfully');
        $self->debug_msg(1, '---------------------------------------------------------------------');

    }

    return;
}

###########################################################################

=head2 add
 
  Title    : add
  Usage    : $self->add($file);
  Function : Insert text in a file.
  Returns  : file => processed file with new text.
  Args     : named arguments:
           : -file => content read from a file.
           :
=cut

###########################################################################
sub add {
    my ($self, $file) = @_;

    my $find = $self->opts->{search};
    my $text = $self->opts->{text};
    if ($self->opts->{regex} eq '0') {

        if ($file =~ s/\Q$find/$&$text/xsi) {
            $self->debug_msg(1, "Found '$&'.  Text added!");
        }
        else {
            $self->debug_msg(1, "$find not found!");
            $self->opts->{exitcode} = $ERROR;
            return;
        }

    }
    else {
        if ($file =~ s/$find/$&$text/xmi) {
            $self->debug_msg(1, "Found '$&'.  Text added!");
        }
        else {
            $self->debug_msg(1, "$find not found!");
            $self->opts->{exitcode} = $ERROR;
            return;
        }

    }
    return $file;
}

# -------------------------------------------------------------------------
# Helper functions
# -------------------------------------------------------------------------

###########################################################################

=head2 myCmdr
 
  Title    : myCmdr
  Usage    : $self->myCmdr();
  Function : Get ElectricCommander instance.
  Returns  : ElectricCommander instance asociated to TextEditDriver
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub myCmdr {
    my ($self) = @_;
    return $self->{_cmdr};
}

###########################################################################

=head2 opts
 
  Title    : opts
  Usage    : $self->opts();
  Function : Get opts hash.
  Returns  : opts hash
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub opts {
    my ($self) = @_;
    return $self->{_opts};
}

###########################################################################

=head2 initialize
 
  Title    : initialize
  Usage    : $self->initialize();
  Function : Set initial values.
  Returns  : none
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub initialize {
    my ($self) = @_;

    binmode STDOUT, ':encoding(utf8)';
    binmode STDIN,  ':encoding(utf8)';
    binmode STDERR, ':encoding(utf8)';

    $self->{_props} = ElectricCommander::PropDB->new($self->myCmdr(), "");

    # Set defaults

    if (!defined($self->opts->{debug})) {
        $self->opts->{debug} = $DEFAULT_DEBUG;
    }

    if (!defined($self->opts->{filters}) && defined($self->opts->{search_in}) && $self->opts->{search_in} eq 'folder') {
        $self->opts->{filters} = $DEFAULT_FILTER;
    }

    $self->opts->{exitcode} = $SUCCESS;
    $self->opts->{JobId}    = $ENV{COMMANDER_JOBID};

    return;
}

###########################################################################

=head2 initializePropPrefix
 
  Title    : initializePropPrefix
  Usage    : $self->initializePropPrefix();
  Function : Initialize PropPrefix value and check valid location.
  Returns  : none
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub initializePropPrefix {
    my ($self) = @_;

    # setup the property sheet where information will be exchanged
    if (!defined($self->opts->{matches_outpsp}) || $self->opts->{matches_outpsp} eq "") {
        if ($self->opts->{JobStepId} ne "1") {
            $self->opts->{matches_outpsp} = $DEFAULT_LOCATION;    # default location to save properties
            $self->opts->{matches_outpsp} .= "/" . $self->opts->{JobStepId};
            $self->debug_msg(5, "Using default location for results");
        }
        else {
            $self->debug_msg(0, "Must specify property sheet location when not running in job");
            $self->opts->{exitcode} = $ERROR;
            return;
        }
    }
    $self->opts->{PropPrefix} = $self->opts->{matches_outpsp};

    $self->debug_msg(5, "results will be in:" . $self->opts->{PropPrefix});

    # test that the location is valid
    if ($self->check_valid_location) {
        $self->opts->{exitcode} = $ERROR;
        return;
    }
}

###########################################################################

=head2 check_valid_location
 
  Title    : check_valid_location
  Usage    : $self->check_valid_location();
  Function : Check if location specified in PropPrefix is valid.
  Returns  : 1 => ERROR
           : ) => SUCCESS
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub check_valid_location {
    my ($self) = @_;
    my $location = "/test-" . $self->opts->{JobStepId};

    # Test set property in location
    my $result = $self->setProp($location, "Test property");
    if (!defined($result) || $result eq "") {
        $self->debug_msg(0, "Invalid location: " . $self->opts->{PropPrefix});
        return $ERROR;
    }

    # Test get property in location
    $result = $self->getProp($location);
    if (!defined($result) || $result eq "") {
        $self->debug_msg(0, "Invalid location: " . $self->opts->{PropPrefix});
        return $ERROR;
    }

    # Delete property
    $result = $self->deleteProp($location);
    return $SUCCESS;
}

###########################################################################

=head2 myProp
 
  Title    : myProp
  Usage    : $self->myProp();
  Function : Get PropDB.
  Returns  : PropDB
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub myProp {
    my ($self) = @_;
    return $self->{_props};
}

###########################################################################

=head2 setProp
 
  Title    : setProp
  Usage    : $self->setProp();
  Function : Use stored property prefix and PropDB to set a property.
  Returns  : setResult => result returned by PropDB->setProp
  Args     : named arguments:
           : -location => relative location to set the property
           : -value    => value of the property
           :
=cut

###########################################################################
sub setProp {
    my ($self, $location, $value) = @_;
    my $setResult = $self->myProp->setProp($self->opts->{PropPrefix} . $location, $value);
    return $setResult;
}

###########################################################################

=head2 getProp
 
  Title    : getProp
  Usage    : $self->getProp($location);
  Function : Use stored property prefix and PropDB to get a property.
  Returns  : getResult => property value
  Args     : named arguments:
           : -location => relative location to get the property
           :
=cut

###########################################################################
sub getProp {
    my ($self, $location) = @_;
    my $getResult = $self->myProp->getProp($self->opts->{PropPrefix} . $location);
    return $getResult;
}

###########################################################################

=head2 deleteProp
 
  Title    : deleteProp
  Usage    : $self->deleteProp($location);
  Function : Use stored property prefix and PropDB to delete a property.
  Returns  : delResult => result returned by PropDB->deleteProp
  Args     : named arguments:
           : -location => relative location of the property to delete
           :
=cut

###########################################################################
sub deleteProp {
    my ($self, $location) = @_;
    my $delResult = $self->myProp->deleteProp($self->opts->{PropPrefix} . $location);
    return $delResult;
}

###########################################################################

=head2 debug_msg
 
  Title    : debug_msg
  Usage    : $self->debug_msg();
  Function : Print a debug message.
  Returns  : none
  Args     : named arguments:
           : -errorlevel => number compared to $self->opts->{debug}
           : -msg        => string message
           :
=cut

###########################################################################
sub debug_msg {
    my ($self, $errlev, $msg) = @_;
    if ($self->opts->{debug} >= $errlev) { print "$msg\n"; }
    return;
}

###########################################################################

=head2 list_files
 
  Title    : list_files
  Usage    : $self->list_files();
  Function : Used with Find, will create an array with all the files in the source.
  Returns  : files => An array containing the path of all the files.
  Args     : named arguments:
           : none
           :
=cut

###########################################################################
sub list_files {
    my ($self) = @_;

    my @files    = ();
    my $filter   = q{\.*};
    my $filepath = $self->opts->{file_path};

    #Search In: Single
    if ($self->opts->{search_in} eq qq{single}) {
        push @files, $self->opts->{file_path};
    }

    #Search In: Multiple
    elsif ($self->opts->{search_in} eq qq{multiple}) {
        @files = split(';', $filepath);
    }

    #Search In: Folder
    else {

        #Filter
        if (defined($self->opts->{filters}) && $self->opts->{filters} ne qq{}) {
            $filter = $self->opts->{filters};

            #change ; for | and add ^ for every pattern
            $filter =~ s/\;/\|\^/g;

            #add slash before .
            $filter =~ s/\./\\./g;

            #change * for .*
            $filter =~ s/\*/\.\*/g;

            $filter = '^' . $filter;

        }
        find(sub { push @files, $File::Find::name if (-f and /$filter$/i) }, $self->opts->{file_path});
    }
    return @files;
}

1;
