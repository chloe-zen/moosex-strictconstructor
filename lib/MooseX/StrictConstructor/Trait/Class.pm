package MooseX::StrictConstructor::Trait::Class;

use Moose::Role;

use namespace::autoclean;

use B ();

my %pkg_attrs;

around new_object => sub {
    my $orig     = shift;
    my $self     = shift;
    my $params   = @_ == 1 ? $_[0] : {@_};
    my $instance = $self->$orig(@_);

    my $attrs =
      $pkg_attrs{ref($instance)} ||= {
          __INSTANCE__ => 1,
          map { $_ => 1 }
          grep {defined}
          map  { $_->init_arg() } $self->get_all_attributes()
      };

    if (my @bad = sort grep { !$attrs->{$_} } keys %$params) {
        $self->throw_error(
            "Found unknown attribute(s) init_arg passed to the constructor: @bad"
        );
    }

    return $instance;
};

around '_inline_BUILDALL' => sub {
    my $orig = shift;
    my $self = shift;

    my @source = $self->$orig();

    my @attrs = (
        '__INSTANCE__ => 1,',
        map { B::perlstring($_) . ' => 1,' }
        grep {defined}
        map  { $_->init_arg() } $self->get_all_attributes()
    );

    my $MY = 'my';
    if ($] >= 5.009004) {
        push @source, "use feature 'state';";
        $MY = 'state';
    }

    return (
        @source,
        $MY.' $attrs = {' . ( join ' ', @attrs ) . '};',
        'if (my @bad = sort grep { !$attrs->{$_} } keys %$params) {',
            'Moose->throw_error("Found unknown attribute(s) passed to the constructor: @bad");',
        '}',
    );
} if $Moose::VERSION >= 1.9900;

1;

# ABSTRACT: A role to make immutable constructors strict

__END__

=pod

=head1 DESCRIPTION

This role simply wraps C<_inline_BUILDALL()> (from
C<Moose::Meta::Class>) so that immutable classes have a
strict constructor.

=cut
