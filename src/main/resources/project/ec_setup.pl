my %replaceText = (
                   label       => "TextEdit - Replace Text",
                   procedure   => "ReplaceText",
                   description => "Find and replace text in one or more files.",
                   category    => "Utility"
                  );

my %findText = (
                   label       => "TextEdit - Find Text",
                   procedure   => "FindText",
                   description => "Find text in one or more files.",
                   category    => "Utility"
                  );
                  
                  
my %extractText = (
                   label       => "TextEdit - Extract Text",
                   procedure   => "ExtractText",
                   description => "Extract Text from a file based on Regular Expression.",
                   category    => "Utility"
                  );
                  
my %addText = (
                   label       => "TextEdit - Add Text",
                   procedure   => "AddText",
                   description => "Insert Text to a File - at given point (by search), at the beginning or at end.",
                   category    => "Utility"
                  );

$batch->deleteProperty("/server/ec_customEditors/pickerStep/TextEdit - Replace Text");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/TextEdit - Find Text");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/TextEdit - Extract Text");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/TextEdit - Add Text");

@::createStepPickerSteps = (\%replaceText, \%findText, \%extractText, \%addText);
