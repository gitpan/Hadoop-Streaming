package Hadoop::Streaming::Mapper;
our $VERSION = '0.100060';
use Moose::Role;

use IO::Handle;
use Params::Validate qw/validate_pos/;

with 'Hadoop::Streaming::Role::Emitter';
requires qw/map/;

# ABSTRACT: Simplify writing Hadoop Streaming jobs. Write a map() and reduce() function and let this role handle the Stream interface.



sub run {
    my $class = shift;
    my $self = $class->new;

    while (my $line = STDIN->getline) {
        chomp $line;

        $self->map(undef, $line);
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

Hadoop::Streaming::Mapper - Simplify writing Hadoop Streaming jobs. Write a map() and reduce() function and let this role handle the Stream interface.

=head1 VERSION

version 0.100060

=head1 SYNOPSIS

  #!/usr/bin/env perl
  
  package Wordcount::Mapper;
  use Moose;
  with 'Hadoop::Streaming::Mapper';
  
  sub map {
      my ($self, $key, $value) = @_;
  
      for (split /\s+/, $value) {
          $self->emit( $_ => 1 );
      }
  }
  
  package main;
  Wordcount::Mapper->run;

Your mapper class must implement map($key,$value) and your reducer must 
implement reduce($key,$value).  Your classes will have emit() and run() 
methods added via role.

=head1 METHODS

=head2 run

    Package->run();

This method starts the Hadoop::Streaming::Mapper instance.  

After creating a new object instance, it reads from STDIN and calls 
$object->map() on each line of input.  Subclasses need only implement map() 
to produce a complete Hadoop Streaming compatible mapper.

=head2 emit

    $object->emit( $key, $value )

This method emits a key,value pair in the format expected by Hadoop::Streaming.
It does this by calling $self->put().  This catches errors from put and turns 
them into warnings.

=head2 put

    $object->put( $key, $value )

This method emits a key,value pair to STDOUT in the format expected by 
Hadoop::Streaming: ( key \t value \n )

=head1 AUTHORS

  andrew grangaard <spazm@cpan.org>
  Naoya Ito <naoya@hatena.ne.jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

