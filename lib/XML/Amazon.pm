package XML::Amazon;

use strict;

use LWP::Simple qw ();
use XML::Simple;
use XML::Amazon::Item;
use XML::Amazon::Collection;
use Data::Dumper qw ();
use URI::Escape qw();

use utf8;
binmode(STDOUT, ":utf8");

our $VERSION = '0.02';

sub new{
	my($pkg, %options) = @_;
	
	my $locale = $options{'locale'};
	$locale ||= "us";
	die "Invalid locale" unless $locale eq "jp" || $locale eq "uk" || $locale eq "fr" || $locale eq "us" || $locale eq "de"|| $locale eq "ca";
	my $associate = $options{'associate'};
	$associate ||= 'webservices-20';
	bless{
		token => $options{'token'},
		associate => $associate,
		locale => $locale,
		data => undef,
		success => '0'
	}, $pkg;
}

sub get{
	my $self = shift;
	my $type = shift;
	my $query = shift;
	my $field = shift;
	$self->asin($query) if $type eq "asin";
	$self->search($query,$field) if $type eq "search";
}

sub asin{
	my $self = shift;
	my $asin = shift;
	my $url;
	my $ITEM = XML::Amazon::Item->new();
	
	warn 'Apparently not an appropriate ASIN' if $asin =~ /[^a-zA-Z0-9]/;
	
	$url = 'http://webservices.amazon.co.jp/onca/xml' if $self->{locale} eq "jp";
	$url = 'http://webservices.amazon.co.uk/onca/xml' if $self->{locale} eq "uk";
	$url = 'http://webservices.amazon.fr/onca/xml' if $self->{locale} eq "fr";
	$url = 'http://webservices.amazon.de/onca/xml' if $self->{locale} eq "de";
	$url = 'http://webservices.amazon.ca/onca/xml' if $self->{locale} eq "ca";
	$url = 'http://webservices.amazon.com/onca/xml' if $self->{locale} eq "us";
	$url .= '?Service=AWSECommerceService';
	$url .= '&AWSAccessKeyId=' . $self->{token};
	$url .= '&AssociateTag=' . $self->{associate};
	$url .= '&Operation=ItemLookup';
	$url .= '&ResponseGroup=Images,ItemAttributes';
	$url .= '&ItemId=' . $asin;
	$url .= '&ContentType=text/xml';
	$url .= '&Version=2006-06-07';
	
	my $data = LWP::Simple::get($url)
		or warn 'Couldn\'t get the XML';
	
	my $xs = new XML::Simple(SuppressEmpty => undef, ForceArray => ['Creator', 'Author', 'Artist', 'Director', 'Actor']);
	my $pl = $xs->XMLin($data);
	$self->{data} = $pl;
	
	if ($pl->{Items}->{Item}->{ASIN}){
	$ITEM->{asin} = $pl->{Items}->{Item}->{ASIN};
	$ITEM->{title} = $pl->{Items}->{Item}->{ItemAttributes}->{Title};
	$ITEM->{type} = $pl->{Items}->{Item}->{ItemAttributes}->{ProductGroup};
	

	if ($pl->{Items}->{Item}->{ItemAttributes}->{Author}->[0]){
		for (my $i = 0; $pl->{Items}->{Item}->{ItemAttributes}->{Author}->[$i]; $i++){
			$ITEM->{authors}->[$i] = $pl->{Items}->{Item}->{ItemAttributes}->{Author}->[$i];
		}
	}
	
	if ($pl->{Items}->{Item}->{ItemAttributes}->{Artist}->[0]){
		for (my $i = 0; $pl->{Items}->{Item}->{ItemAttributes}->{Artist}->[$i]; $i++){
			$ITEM->{artists}->[$i] = $pl->{Items}->{Item}->{ItemAttributes}->{Artist}->[$i];
		}
	}
	if ($pl->{Items}->{Item}->{ItemAttributes}->{Actor}->[0]){
		for (my $i = 0; $pl->{Items}->{Item}->{ItemAttributes}->{Actor}->[$i]; $i++){
			$ITEM->{actors}->[$i] = $pl->{Items}->{Item}->{ItemAttributes}->{Actor}->[$i];
		}
	}
	
	if ($pl->{Items}->{Item}->{ItemAttributes}->{Director}->[0]){
		for (my $i = 0; $pl->{Items}->{Item}->{ItemAttributes}->{Director}->[$i]; $i++){
			$ITEM->{directors}->[$i] = $pl->{Items}->{Item}->{ItemAttributes}->{Director}->[$i];
		}
	}

	
	if ($pl->{Items}->{Item}->{ItemAttributes}->{Creator}->[0]->{content}){
		for (my $i = 0; $pl->{Items}->{Item}->{ItemAttributes}->{Creator}->[$i]->{content}; $i++){
			$ITEM->{creators}->[$i] = $pl->{Items}->{Item}->{ItemAttributes}->{Creator}->[$i]->{content};
		}
	}

	
	$ITEM->{price} = $pl->{Items}->{Item}->{ItemAttributes}->{ListPrice}->{FormattedPrice};
	$ITEM->{author} = $ITEM->{authors}->[0];
	$ITEM->{url} = $pl->{Items}->{Item}->{DetailPageURL};
	$ITEM->{publisher} = $pl->{Items}->{Item}->{ItemAttributes}->{Publisher};
	$ITEM->{smallimage} = $pl->{Items}->{Item}->{SmallImage}->{URL};
	$ITEM->{mediumimage} = $pl->{Items}->{Item}->{MediumImage}->{URL};
	$ITEM->{mediumimage} = $ITEM->{smallimage} unless $ITEM->{mediumimage};
	$ITEM->{largeimage} = $pl->{Items}->{Item}->{LargeImage}->{URL};
	$ITEM->{largeimage} = $ITEM->{mediumimage} unless $ITEM->{largeimage};
	
	$self->{success} = '1';
	return $ITEM;
	}
	else{
	$self->{success} = '0';
	warn 'No item found';
	return '';
	}
}

sub search{
	my($self, %options) = @_;
	my $keywords = URI::Escape::uri_escape($options{'keywords'});
	my $type = $options{'type'};
	$type ||= "Blended";
	my $page = $options{'page'};
	$page ||= 1;
	
	my $url;
	
	$url = 'http://webservices.amazon.co.jp/onca/xml' if $self->{locale} eq "jp";
	$url = 'http://webservices.amazon.co.uk/onca/xml' if $self->{locale} eq "uk";
	$url = 'http://webservices.amazon.fr/onca/xml' if $self->{locale} eq "fr";
	$url = 'http://webservices.amazon.de/onca/xml' if $self->{locale} eq "de";
	$url = 'http://webservices.amazon.ca/onca/xml' if $self->{locale} eq "ca";
	$url = 'http://webservices.amazon.com/onca/xml' if $self->{locale} eq "us";
	$url .= '?Service=AWSECommerceService';
	$url .= '&AWSAccessKeyId=' . $self->{token};
	$url .= '&AssociateTag=' . $self->{associate};
	$url .= '&Operation=ItemSearch';
	$url .= '&ResponseGroup=Images,ItemAttributes';
	$url .= '&Keywords=' . $keywords;
	$url .= '&ItemPage=' . $page;
	$url .= '&ContentType=text/xml';
	$url .= '&SearchIndex=' . $type;
	$url .= '&Version=2006-06-07';
	my $data = LWP::Simple::get($url)
		or return 'Couldn\'t get the XML.';
	
	my $xs = new XML::Simple(SuppressEmpty => undef, ForceArray => ['Item', 'Creator', 'Author', 'Artist', 'Actor', 'Director']);
	my $pl = $xs->XMLin($data);
	$self->{data} = $pl;
	
	my $collection = XML::Amazon::Collection->new();
	if ($pl->{Items}->{Item}->[0]->{ASIN}){
		for (my $i = 0; $pl->{Items}->{Item}->[$i]; $i++){

			my $new_item = XML::Amazon::Item->new();
			
			$new_item->{asin} = $pl->{Items}->{Item}->[$i]->{ASIN};
			$new_item->{title} = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Title};
			$new_item->{publisher} = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Publisher};
			$new_item->{url} = $pl->{Items}->{Item}->[$i]->{DetailPageURL};
			$new_item->{type} = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{ProductGroup};

			if ($pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Author}->[0]){
				for (my $j = 0; $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Author}->[$j]; $j++){
					$new_item->{authors}->[$j] = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Author}->[$j];
				}
			}
			
			if ($pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Artist}->[0]){
				for (my $j = 0; $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Artist}->[$j]; $j++){
					$new_item->{artists}->[$j] = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Artist}->[$j];
				}
			}
			
			if ($pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Creator}->[0]->{content}){
				for (my $j = 0; $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Creator}->[$j]->{content}; $j++){
					$new_item->{creators}->[$j] = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Creator}->[$j]->{content};
				}
			}
			
			if ($pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Director}->[0]){
				for (my $j = 0; $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Director}->[$j]; $j++){
					$new_item->{directors}->[$j] = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Director}->[$j];
				}
			}
			
			
			if ($pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Actor}->[0]){
				for (my $j = 0; $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Actor}->[$j]; $j++){
					$new_item->{actors}->[$j] = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{Actor}->[$j];
				}
			}


			
			$new_item->{price} = $pl->{Items}->{Item}->[$i]->{ItemAttributes}->{ListPrice}->{FormattedPrice};
			$new_item->{smallimage} = $pl->{Items}->{Item}->[$i]->{SmallImage}->{URL};
			$new_item->{mediumimage} = $pl->{Items}->{Item}->[$i]->{MediumImage}->{URL};
			$new_item->{mediumimage} = $new_item->{smallimage} unless $new_item->{mediumimage};
			$new_item->{largeimage} = $pl->{Items}->{Item}->[$i]->{LargeImage}->{URL};
			$new_item->{largeimage} = $new_item->{mediumimage} unless $new_item->{largeimage};
		
			$collection->add_Amazon($new_item);
		}
		$self->{success} = '1';
		return $collection;

	}

	else{
		$self->{success} = '0';
		warn 'No item found';
		return '';
	}
}

sub is_success{
	my $self = shift;
	return $self->{success};
	
}

sub Dumper{
	my $self = shift;
	print Data::Dumper::Dumper($self->{data});
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

XML::Amazon - Perl extension for getting information from Amazon

=head1 SYNOPSIS

	use XML::Amazon;
	
	my $amazon = XML::Amazon->new(token => AMAZON-ID, locale => 'uk');
	
	$item->asin('0596101058');## ASIN access
	
	if ($amazon->is_success){
		print $item->title;
	}
	
	my $items;
	$items = $amazon->search(keywords => 'Perl');## Search by 'Perl'
	
	foreach my $item ($items){
	print $item->title . '\n';
	}

=head1 DESCRIPTION

XML::Amazon provides a simple way to get information from Amazon. I<XML::Amazon> can
connect to US, JP, UK, FR, DE and CA.

=head1 USAGE

=head2 XML::Amazon->new(token => AMAZON-ID, associate => ASSOCIATE-ID, locale => UK)

Creates a new empty XML::Amazon object. You should specify your Amazon Web Service ID
(which can be obteined thorough 
http://www.amazon.com/gp/aws/registration/registration-form.html). You can also specify
your locale (defalut: US; you can choose us, uk, jp, fr, de, ca) and your Amazon
associate ID (default: webservices-20, which is Amazon default).

=head2 $XML_Amazon->asin(ASIN)

Returns an XML::Amazon::Item object whose ASIN is as given.


=head2 $XML_Amazon->search(keywords => 'Perl', page => '2', type => 'Books')

Returns an XML::Amazon::Collection object. i<type> can be Blended, Books, Music, DVD, etc.

=head2 $XML_Amazon->is_success

Returns 1 when successful, otherwise 0. 

=head2 $XML_Amazon_Collection->collection

Returns a list of XML::Amazon::Item objects.

=head2 $XML_Amazon_Item->title

=head2 $XML_Amazon_Item->made_by

Returns authors when the item is a book, and likewise.

=head2 $XML_Amazon_Item->publisher

=head2 $XML_Amazon_Item->url

=head2 $XML_Amazon_Item->image(size)

Returns the URL of the cover image. I<size> can be s, m, or l.

=head2 $XML_Amazon_Item->price

=head1 SEE ALSO

=head1 AUTHOR

Yusuke Sugiyama, E<lt>ally@blinkingstar.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Yusuke Sugiyama

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut