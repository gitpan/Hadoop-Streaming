package Hadoop::Streaming::Reducer::Input::ValuesIterator;
our $VERSION = '0.100050';
use Moose;
with 'Hadoop::Streaming::Role::Iterator';

has input_iter => (
    is       => 'ro',
    does     => 'Hadoop::Streaming::Role::Iterator',
    required => 1,
);

has first => (
    is       => 'rw',
);


sub has_next {
    my $self = shift;
    return 1 if $self->first;
    return unless defined $self->input_iter->input->next_key;
    return $self->input_iter->current_key eq $self->input_iter->input->next_key ? 1 : 0;
}


sub next {
    my $self = shift;
    if (my $first = $self->first) {
        $self->first( undef );
        return $first;
    }
    my ($key, $value) = $self->input_iter->input->each;
    $value;
}

__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=head1 NAME

Hadoop::Streaming::Reducer::Input::ValuesIterator

=head1 VERSION

version 0.100050

=head1 METHODS

=head2 has_next

    $ValuesIterator->has_next();

Checks if the ValueIterator has another value available for this key.

Returns 1 on success, 0 if the next value is from another key, and undef if there is no next key.

=head2 next

    $ValuesIterator->next();

Returns the next value available.  Reads from $ValuesIterator->input_iter->input

=head1 AUTHORS

  andrew grangaard <spazm@cpan.org>
  Naoya Ito <naoya@hatena.ne.jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

