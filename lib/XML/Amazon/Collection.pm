package XML::Amazon::Collection;

use strict;
use XML::Amazon;
use LWP::Simple;
use XML::Simple;

binmode STDOUT => ":bytes";

sub new{
	my $pkg = shift;
	my $data = {
	total_results => undef,
	total_pages => undef,
	current_page => undef,
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

sub total_results {
	my $self = shift;
	return $self->{total_results};
}

sub total_pages {
	my $self = shift;
	return $self->{total_pages};
}

sub current_page {
	my $self = shift;
	return $self->{current_page};
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
