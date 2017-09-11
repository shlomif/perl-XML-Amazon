package XML::Amazon::Collection;

use strict;
use warnings;
use utf8;

sub new {
    my $pkg = shift;
    my $data = {
        total_results => undef,
        total_pages => undef,
        current_page => undef,
        collection => []
    };
    bless $data, $pkg;
    return $data;
}

sub add_Amazon {
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

sub collection {
    my $self = shift;
    my @list;
    LIST: for my $el (@{$self->{collection}}) {
        if (! $el) {
            last LIST;
        }
        push @list, $el;
    }
    return @list;
}

1;

=head1 METHODS

=head2 new

Constructor

=head2 $self->add_Amazon($item)

Add item to the collection.

=head2 $self->current_page()

Returns the current page.

=head2 $self->total_pages()

Returns the count of total pages.

=head2 $self->total_results()

Returns the total results.

=head2 $self->collection()

Returns a flattened array of the collection.

=cut


