package MooseX::StrictConstructor;

use strict;
use warnings;

use Moose 0.94 ();
use Moose::Exporter;
use Moose::Util::MetaRole;

{
    my %class_meta = ( class => ['MooseX::StrictConstructor::Trait::Class'] );


    if ( $Moose::VERSION < 1.9900 ) {
        require MooseX::StrictConstructor::Trait::Method::Constructor;
        $class_meta{constructor}
            = ['MooseX::StrictConstructor::Trait::Method::Constructor'];
    }

    Moose::Exporter->setup_import_methods(
        class_metaroles => \%class_meta,
    );
}

1;

# ABSTRACT: Make your object constructors blow up on unknown attributes

__END__

=pod

=head1 SYNOPSIS

    package My::Class;

    use Moose;
    use MooseX::StrictConstructor;

    has 'size' => ...;

    # then later ...

    # this blows up because color is not a known attribute
    My::Class->new( size => 5, color => 'blue' );

=head1 DESCRIPTION

Simply loading this module makes your constructors "strict". If your
constructor is called with an attribute init argument that your class
does not declare, then it calls C<Moose->throw_error()>. This is a great way
to catch small typos.

=head2 Subverting Strictness

You may find yourself wanting to have your constructor accept a
parameter which does not correspond to an attribute.

In that case, you'll probably also be writing a C<BUILD()> or
C<BUILDARGS()> method to deal with that parameter. In a C<BUILDARGS()>
method, you can simply make sure that this parameter is not included
in the hash reference you return. Otherwise, in a C<BUILD()> method,
you can delete it from the hash reference of parameters.

  sub BUILD {
      my $self   = shift;
      my $params = shift;

      if ( delete $params->{do_something} ) {
          ...
      }
  }

=head1 BUGS

Please report any bugs or feature requests to
C<bug-moosex-strictconstructor@rt.cpan.org>, or through the web
interface at L<http://rt.cpan.org>.  I will be notified, and then
you'll automatically be notified of progress on your bug as I make
changes.

=cut
