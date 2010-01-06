#!/usr/bin/env perl

package Wordcount::Mapper;
our $VERSION = '0.100060';
use Moose;
with 'Hadoop::Streaming::Mapper';

sub map {
    my ($self, $key, $value) = @_;

    for (split /\s+/, $value) {
        $self->emit( $_ => 1 );
    }
}

package main;
our $VERSION = '0.100060';
Wordcount::Mapper->run;
