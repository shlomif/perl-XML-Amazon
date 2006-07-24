use ExtUtils::MakeMaker;
WriteMakefile
(
          'NAME' => 'XML::Amazon',
          'VERSION_FROM' => 'lib/XML/Amazon.pm',
          'PREREQ_PM' => {
                           'LWP::Simple' => '0',
						   'XML::Simple' => '0',
						   'Data::Dumper' => '0',
						   'URI::Escape' => '0'
                         },
          'INSTALLDIRS' => 'site',
          'PL_FILES' => {}
        )
;
