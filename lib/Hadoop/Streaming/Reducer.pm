package Hadoop::Streaming::Reducer;
our $VERSION = '0.100060';
use Moose::Role;

with 'Hadoop::Streaming::Role::Emitter';

use IO::Handle;
use Params::Validate qw/validate_pos/;
use Hadoop::Streaming::Reducer::Input;

with 'Hadoop::Streaming::Role::Emitter';
requires qw/reduce/;

# ABSTRACT: Simplify writing Hadoop Streaming jobs. Write a map() and reduce() function and let this role handle the Stream interface.  The Reducer roll provides an iterator over the multiple values for a given key.



sub run {
    my $class = shift;
    my $self = $class->new;

    my $input = Hadoop::Streaming::Reducer::Input->new(handle => \*STDIN);
    my $iter = $input->iterator;

    while ($iter->has_next) {
        my ($key, $values_iter) = $iter->next or last;
        eval {
            $self->reduce( $key => $values_iter );
        };
        if ($@) {
            warn $@;
        }
    }
}

sub emit {
    my ($self, $key, $value) = @_;
    eval {
        $self->put($key, $value);
    };
    if ($@) {
        warn $@;
    }
}

sub put {
    my ($self, $key, $value) = validate_pos(@_, 1, 1, 1);
    printf "%s\t%s\n", $key, $value;
}

1;


__END__
=pod

=head1 NAME

Hadoop::Streaming::Reducer - Simplify writing Hadoop Streaming jobs. Write a map() and reduce() function and let this role handle the Stream interface.  The Reducer roll provides an iterator over the multiple values for a given key.

=head1 VERSION

version 0.100060

=head1 SYNOPSIS

    #!/usr/bin/env perl

    package WordCount::Reducer;
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
    WordCount::Reducer->run;

Your mapper class must implement map($key,$value) and your reducer must 
implement reduce($key,$value).  Your classes will have emit() and run() 
methods added via the role.

=head1 METHODS

=head2 run

    Package->run();

This method starts the Hadoop::Streaming::Reducer instance.  

After creating a new object instance, it reads from STDIN and calls $object->reduce( ) passing in the key and an iterator of values for that key.

Subclasses need only implement reduce() to produce a complete Hadoop Streaming compatible reducer.

=head2 emit

    $object->emit( $key, $value )

This method emits a key,value pair in the format expected by Hadoop::Streaming.  It does this 
by calling $self->put().  Catches errors from put and turns them into warnings.

=head2 put

    $object->put( $key, $value )

This method emits a key,value pair to STDOUT in the format expected by Hadoop::Streaming. (key\tvalue\n)

=head1 AUTHORS

  andrew grangaard <spazm@cpan.org>
  Naoya Ito <naoya@hatena.ne.jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

