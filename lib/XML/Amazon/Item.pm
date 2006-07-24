package XML::Amazon::Item;

use strict;
use LWP::Simple;
use XML::Simple;
use utf8;
binmode(STDOUT, ":utf8");

sub new{
	my($pkg, %options) = @_;

	bless{
		title => $options{'title'},
		authors => $options{'authors'},
		artists => $options{'artists'},
		creators => $options{'creators'},
		directors => $options{'directors'},
		actors => $options{'actors'},
		type => $options{'type'},
		url => $options{'url'},
		smallimage => $options{'smallimage'},
		mediumimage => $options{'mediumimage'},
		largeimage => $options{'largeimage'},
		publisher => $options{'publisher'},
		price => $options{'price'},
	}, $pkg;
}

sub creators_all{
	my $self = shift;
	my @list;
	for (my $i; $self->{authors}->[$i]; $i++){
		push @list, $self->{authors}->[$i];
	}
	for (my $i; $self->{artists}->[$i]; $i++){
		push @list, $self->{artists}->[$i];
	}
	for (my $i; $self->{creators}->[$i]; $i++){
		push @list, $self->{creators}->[$i];
	}
	return @list;
}

sub made_by{
	my $self = shift;
	my @list;
	for (my $i; $self->{authors}->[$i]; $i++){
		push @list, $self->{authors}->[$i];
	}
	for (my $i; $self->{artists}->[$i]; $i++){
		push @list, $self->{artists}->[$i];
	}
	
	for (my $i; $self->{creators}->[$i]; $i++){
	push @list, $self->{creators}->[$i];
	}
	
	for (my $i; $self->{directors}->[$i]; $i++){
		push @list, $self->{directors}->[$i];
	}
	
	for (my $i; $self->{actors}->[$i]; $i++){
		push @list, $self->{actors}->[$i];
	}
	
	
	my %tmp;
	@list = grep(  !$tmp{$_}++, @list );
	
	return @list;
}

sub authors{
	my $self = shift;
	my @list;
	for (my $i; $self->{authors}->[$i]; $i++){
		push @list, $self->{authors}->[$i];
	}
	return @list;
}

sub artists{
	my $self = shift;
	my @list;
	for (my $i; $self->{artists}->[$i]; $i++){
		push @list, $self->{artists}->[$i];
	}
	return @list;
}

sub creators{
	my $self = shift;
	my @list;
	for (my $i; $self->{creators}->[$i]; $i++){
		push @list, $self->{creators}->[$i];
	}
	return @list;
}

sub publisher{
	my $self = shift;
	return $self->{publisher};
}

sub asin{
	my $self = shift;
	return $self->{asin};
}

sub title{
	my $self = shift;
	return $self->{title};
}

sub author{
	my $self = shift;
	return @{$self->authors}[0];
}

sub image{
	my $self = shift;
	my $size = shift;
	
	return $self->{smallimage} if $size eq 's';
	return $self->{mediumimage} if $size eq 'm';
	return $self->{largeimage} if $size eq 'l';
	
}

sub url{
	my $self = shift;
	return $self->{url};
}

sub type{
	my $self = shift;
	return $self->{type};
}

sub price{
	my $self = shift;
	return $self->{price};
}

1;
