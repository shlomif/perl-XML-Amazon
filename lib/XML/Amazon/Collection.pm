package XML::Amazon::Collection;

use strict;
use XML::Amazon;
use LWP::Simple;
use XML::Simple;
use utf8;
binmode(STDOUT, ":utf8");

sub new{
	my $pkg = shift;
	my $data = {
	collection => []
	};
	bless $data, $pkg;
}

sub add_Amazon{
	my $self = shift;
	my $add_data = shift;
	
	if(ref $add_data ne "XML::Amazon::Item") {
		warn "add_Amazon called with type ", ref $add_data;
		return undef;
	}
	push @{$self->{collection}}, $add_data;
}

sub collection{
	my $self = shift;
	my @list;
	for (my $i = 0; $self->{collection}->[$i]; $i++){
		push @list, $self->{collection}->[$i];
	}
	return @list;
}

1;
