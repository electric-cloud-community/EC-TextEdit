@files = (

    ['//property[propertyName="preamble"]/value',       'preamble.pl'],
    ['//property[propertyName="TextEditDriver"]/value', 'TextEditDriver.pm'],
    ['//property[propertyName="postp_matchers"]/value', 'postp_matchers.pl'],

    ['//property[propertyName="ec_setup"]/value', 'ec_setup.pl'],

    ['//step[stepName="ReplaceText"]/command', 'procedures/replace.pl'],
    ['//step[stepName="AddText"]/command',     'procedures/add.pl'],
    ['//step[stepName="ExtractText"]/command', 'procedures/extract.pl'],
    ['//step[stepName="FindText"]/command',    'procedures/find.pl'],

    ['//property[propertyName="ec_setup"]/value', 'ec_setup.pl'],

);
