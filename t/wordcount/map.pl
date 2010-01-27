#!/usr/bin/env perl

package Wordcount::Mapper;
our $VERSION = '0.100270';
use Moose;
with 'Hadoop::Streaming::Mapper';

sub map {
    my ($self, $line ) = @_;

    for (split /\s+/, $line ) {
        $self->emit( $_ => 1 );
    }
}

package main;
our $VERSION = '0.100270';
Wordcount::Mapper->run;
