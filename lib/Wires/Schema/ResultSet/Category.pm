use utf8;

package Wires::Schema::ResultSet::Category;

use strict;
use warnings;
use parent 'DBIx::Class::ResultSet';

sub get_categories {
    my ( $self ) = @_;
    my $schema = $self->result_source->schema;
    my @cats = $self->search(
        {},
        {   
            #order_by => { -asc => 'name' },
            # Recommended way to send simple data to a template vs. sending the ResultSet object
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    );
    return \@cats;
}

1;
