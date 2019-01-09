use ElectricCommander;

push(
    @::gMatchers,
    {
       id      => "total_occurrences",
       pattern => q{Found\s(\d+)\soccurrence},
       action  => q{
        
        
        	                  incValue("occurrences", $1);
        	                  if ($1){
                                incValue("files");
                              }
        	                
        	                  my $totalOccurrences=$::gProperties{"occurrences"};
        	                  my $totalFiles=$::gProperties{"files"};

        	                  my $findDesc = "Found $totalOccurrences occurrence(s) in $totalFiles files";
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               setProperty("summary", $findDesc . "\n");

                                    
                              diagnostic("", "info", 0);
                             },
    },

    {
       id      => "total_replaces",
       pattern => q{Replaced\s(\d+)\soccurrence},
       action  => q{
        	                  incValue("occurrences", $1);
        	                  if ($1){
                                incValue("files");
                              }
        	                
        	                  my $totalOccurrences=$::gProperties{"occurrences"};
        	                  my $totalFiles=$::gProperties{"files"};

        	                  my $findDesc = "Replaced $totalOccurrences occurrence(s) in $totalFiles files";
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               setProperty("summary", $findDesc . "\n");

                                    
                              diagnostic("", "info", 0);
                             },
    },

    {
       id      => "file",
       pattern => q{^File:\s(.+)},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "File: $1";
                               setProperty("summary", $desc . "\n");

                             },
    },
    {
       id      => "regex",
       pattern => q{^Regular\sExpression:\s(.+)},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "Regular Expression: $1";
                               setProperty("summary", $desc . "\n");

                             },
    },

    {
       id      => "total_extracted",
       pattern => q{^\$(\d+):\s},
       action  => q{
        	                  incValue("matches");
        	                
        	                  my $totalMatches=$::gProperties{"matches"};

        	                  my $findDesc = "Extracted $totalMatches match(es), Saved in properties.";
                              
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                              if($desc =~ m/Extracted (\d+) match/)
                              {
                                $desc =~ s/Extracted (\d+) match/Extracted $totalMatches match/; 
                              }
                              else
                              {
                               $desc .= "Extracted $totalMatches match(es), Saved in properties.";
                              }
                               setProperty("summary", $desc . "\n");
                             },
    },
    
    {
       id      => "insert",
       pattern => q{^Insertion\spoint:\s(.+)},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "Insertion point: $1";
                               setProperty("summary", $desc . "\n");

                             },
    },
    {
       id      => "regex",
       pattern => q{^Text\sto\sAdd:\s(.+)},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "Text to Add: $1";
                               setProperty("summary", $desc . "\n");

                             },
    },
    {
       id      => "notfound",
       pattern => q{(.+)\snot\sfound!},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "Search '$1' not found!";
                               setProperty("summary", $desc . "\n");

                             },
    },
    {
       id      => "found",
       pattern => q{^Found\s(.+)\sText\sadded!},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "Found '$1', text added.";
                               setProperty("summary", $desc . "\n");

                             },
    },
    {
       id      => "nofiles",
       pattern => q{No\sfiles\sprovided},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "ERROR: No files provided.";
                               setProperty("summary", $desc . "\n");
                               setProperty("/myJobStep/outcome", 'error');

                             },
    },
    {
       id      => "unable",
       pattern => q{Unable\sto\sopen\s(.+)},
       action  => q{    
                               my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');
                               $desc .= "ERROR: Unable to open file.";
                               setProperty("summary", $desc . "\n");
                               setProperty("/myJobStep/outcome", 'error');

                             },
    },
    

);

