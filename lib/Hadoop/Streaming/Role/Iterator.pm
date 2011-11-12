package Hadoop::Streaming::Role::Iterator;
{
  $Hadoop::Streaming::Role::Iterator::VERSION = '0.113160';
}
use Any::Moose qw(Role);

requires qw(has_next next);
#ABSTRACT: Role to require has_next and next

1;


__END__
=pod

=head1 NAME

Hadoop::Streaming::Role::Iterator - Role to require has_next and next

=head1 VERSION

version 0.113160

=head1 AUTHORS

=over 4

=item *

andrew grangaard <spazm@cpan.org>

=item *

Naoya Ito <naoya@hatena.ne.jp>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

