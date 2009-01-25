use inc::Module::Install;
name    'XML-Amazon';
all_from       'lib/XML/Amazon.pm';
requires 'LWP::Simple' => '0';
requires 'XML::Simple' => '0';
requires 'Data::Dumper' => '0';
requires 'URI::Escape' => '0';
WriteAll;