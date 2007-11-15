use strict;
use warnings;

use Test::More tests => 4;


{
    package Standard;

    use Moose;

    has 'thing' => ( is => 'rw' );
}

{
    package Stricter;

    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw' );
}

{
    package Tricky;

    use MooseX::StrictConstructor;

    has 'thing' => ( is => 'rw' );

    sub BUILD
    {
        my $self   = shift;
        my $params = shift;

        delete $params->{spy};
    }
}


eval { Standard->new( thing => 1, bad => 99 ) };
is( $@, '', 'standard Moose class ignores unknown params' );

eval { Stricter->new( thing => 1, bad => 99 ) };
like( $@, qr/unknown attribute.+: bad/, 'strict constructor blows up on unknown params' );

eval { Tricky->new( thing => 1, spy => 99 ) };
is( $@, '', 'can work around strict constructor by deleting params in BUILD()' );

eval { Tricky->new( thing => 1, agent => 99 ) };
like( $@, qr/unknown attribute.+: agent/, 'Tricky still blows up on unknown params other than spy' );
