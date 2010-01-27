#!/usr/bin/env perl

package WordCount::Reducer;
our $VERSION = '0.100270';
use Moose;
with qw/Hadoop::Streaming::Reducer/;

sub reduce {
    my ($self, $key, $values) = @_;

    my $count = 0;
    while ( $values->has_next ) {
        $count++;
        $values->next;
    }

    $self->emit( $key => $count );
}

package main;
our $VERSION = '0.100270';
WordCount::Reducer->run;
