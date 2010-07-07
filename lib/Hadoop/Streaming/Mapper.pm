package Hadoop::Streaming::Mapper;
BEGIN {
  $Hadoop::Streaming::Mapper::VERSION = '0.101881';
}
use Moose::Role;
use IO::Handle;

with 'Hadoop::Streaming::Role::Emitter';
#requires qw(emit counter status); #from Hadoop::Streaming::Role::Emitter
requires qw(map);  # from consumer

# ABSTRACT: Simplify writing Hadoop Streaming Mapper jobs.  Write a map() function and let this role handle the Stream interface.



sub run
{
    my $class = shift;
    my $self  = $class->new;

    while ( my $line = STDIN->getline )
    {
        chomp $line;
        $self->map($line);
    }
}

1;

__END__
=pod

=head1 NAME

Hadoop::Streaming::Mapper - Simplify writing Hadoop Streaming Mapper jobs.  Write a map() function and let this role handle the Stream interface.

=head1 VERSION

version 0.101881

=head1 SYNOPSIS

  #!/usr/bin/env perl
  
  package Wordcount::Mapper;
  use Moose;
  with 'Hadoop::Streaming::Mapper';
  
  sub map
  {
    my ( $self, $line ) = @_;
    $self->emit( $_ => 1 ) for ( split /\s+/, $line );
  }
  
  package main;
  Wordcount::Mapper->run;

Your mapper class must implement map($key,$value) and your reducer must 
implement reduce($key,$value).  Your classes will have emit(), counter(),
status() and run() methods added via a role.

=head1 METHODS

=head2 run

    Package->run();

This method starts the Hadoop::Streaming::Mapper instance.  

After creating a new object instance, it reads from STDIN and calls 
$object->map() on each line of input.  Subclasses need only implement map() 
to produce a complete Hadoop Streaming compatible mapper.

=head1 AUTHORS

=over 4

=item *

andrew grangaard <spazm@cpan.org>

=item *

Naoya Ito <naoya@hatena.ne.jp>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

