#!/usr/bin/env perl

package Analog::Reducer;
our $VERSION = '0.100060';
use Moose;
with 'Hadoop::Streaming::Reducer';

sub reduce {
    my ($self, $key, $values) = @_;

    my $count = 0;
    while ($values->has_next) {
        $count++;
        $values->next;
    }
    $self->emit($key, $count);
}

package main;
our $VERSION = '0.100060';
Analog::Reducer->run;
