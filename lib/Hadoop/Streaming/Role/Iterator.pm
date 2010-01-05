package Hadoop::Streaming::Role::Iterator;
our $VERSION = '0.100050';
use Moose::Role;

requires qw/has_next next/;

1;


__END__
=pod

=head1 NAME

Hadoop::Streaming::Role::Iterator

=head1 VERSION

version 0.100050

=head1 AUTHORS

  andrew grangaard <spazm@cpan.org>
  Naoya Ito <naoya@hatena.ne.jp>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

