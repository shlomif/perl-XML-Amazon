use Test::Simple tests => 3;
use XML::Amazon;  # What you're testing.
	my $amazon = XML::Amazon->new(token => '1VJJYMBJGWQPFCG64282', sak => 'KZneYOoXBTILPRPaRHIVG7Fx0f/VT7F8V4ueyHq7', locale => 'uk');
	my $item = $amazon->asin('0596101058');
	ok($amazon->is_success eq '1', 'Get information from Amazon by ASIN.');
	ok($item->title =~ 'Learning Perl', 'Check if the information is correct. The title is ' . $item->title);
	my $items;
	$items = $amazon->search(keywords => 'Perl');
	ok($items, 'Get information from Amazon by searching.');

