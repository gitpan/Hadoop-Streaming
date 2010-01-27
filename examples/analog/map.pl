#!/usr/bin/env perl

package Analog::Mapper;
our $VERSION = '0.100270';
use Moose;
with 'Hadoop::Streaming::Mapper';

sub map {
    my ($self, $line) = @_;

    my @segments = split /\s+/, $line;
    $self->emit($segments[1] => 1); #referrer
}

package main;
our $VERSION = '0.100270';
Analog::Mapper->run;
