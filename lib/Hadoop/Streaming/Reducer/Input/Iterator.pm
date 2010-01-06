package Hadoop::Streaming::Reducer::Input::Iterator;
our $VERSION = '0.100060';
use Moose;
with 'Hadoop::Streaming::Role::Iterator';

use Hadoop::Streaming::Reducer::Input::ValuesIterator;

has input => (
    is       => 'ro',
    isa      => 'Hadoop::Streaming::Reducer::Input',
    required => 1,
);

has current_key => (
    is   => 'rw',
    does => 'Str'
);


sub has_next {
    my $self = shift;
    return if not defined $self->input->next_key;
    1;
}


sub next {
    my $self = shift;

    if ( not defined $self->current_key ) {
        $self->current_key($self->input->next_key);
        return $self->retval( $self->current_key );
    }

    if ($self->current_key ne $self->input->next_key) {
        $self->current_key($self->input->next_key);
        return $self->retval( $self->current_key );
    }

    my ($key, $value);
    do {
        ($key, $value) = $self->input->each or return;
    } while ($self->current_key eq $key);
    $self->current_key( $key );

    return $self->retval($key, $value);
}


sub retval {
    my ($self, $key, $value) = @_;
    return (
        $key,
        Hadoop::Streaming::Reducer::Input::ValuesIterator->new(
            input_iter => $self,
            first      => $value,
        ),
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=head1 NAME

Hadoop::Streaming::Reducer::Input::Iterator

=head1 VERSION

version 0.100060

=head1 METHODS

=head2 has_next

    $Iterator->has_next();

Checks if the iterator has a next_key.  Returns 1 if there is another key in the input iterator.

=head2 next

    $Iterator->next();

Returns the key and value iterator for the next key.  Discards any remaining values from the current key.

Moves the iterator to the next key value, and returns the output of retval( $key, $value);

=head2 retval

    $Iterator->retval($key );
    $Iterator->retval($key, $value);

Returns an two element array containing the key and a Hadoop::Streaming::Reducer::Input::ValuesIterator initialized with the given value as the first element.

( $key, $ValueIterator)

=head1 AUTHORS

  andrew grangaard <spazm@cpan.org>
  Naoya Ito <naoya@hatena.ne.jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

