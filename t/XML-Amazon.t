use Test::Simple tests => 3;
use XML::Amazon;  # What you're testing.
	my $amazon = XML::Amazon->new(token => '1VJJYMBJGWQPFCG64282', locale => 'uk');
	my $item = $amazon->asin('0596101058');
	ok($amazon->is_success eq '1', 'Get information from Amazon by ASIN.');
	ok($item->title eq 'Learning Perl (Learning)', 'Check if the information is correct.');
	my $items;
	$items = $amazon->search(keywords => 'Perl');
	ok($items, 'Get information from Amazon by searching.');

