package MOP::Slot;
# ABSTRACT: A representation of a class slot

use strict;
use warnings;

use UNIVERSAL::Object;

use MOP::Internal::Util;

our $VERSION   = '0.02';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = 'UNIVERSAL::Object' }
our %HAS; BEGIN {
    %HAS = (
        name        => sub { die '[ARGS] You must specify a slot name'        },
        initializer => sub { die '[ARGS] You must specify a slot initializer' },
    )
}

# if called upon to be a CODE ref
# then return the initializer
use overload '&{}' => 'initializer', fallback => 1;

sub BUILDARGS {
    my $class = shift;
    my $args;

    if ( scalar( @_ ) eq 2 && !(ref $_[0]) && ref $_[1] eq 'CODE' ) {
        $args = +{ name => $_[0], initializer => $_[1] };
    }
    else {
        $args = $class->SUPER::BUILDARGS( @_ );
    }

    die '[ARGS] You must specify a slot name'
        unless $args->{name};
    die '[ARGS] You must specify a slot initializer'
        unless $args->{initializer};
    die '[ARGS] The initializer specified must be a CODE reference'
        unless ref $args->{initializer} eq 'CODE';        

    return $args;
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub initializer {
    my ($self) = @_;
    return $self->{initializer};
}

sub origin_stash {
    my ($self) = @_;
    # NOTE:
    # for the time being we are going to stick with
    # the COMP_STASH as the indicator for the initalizers
    # instead of the glob ref, which might be trickier
    # however I really don't know, so time will tell.
    # - SL
    return MOP::Internal::Util::GET_STASH_NAME( $self->initializer );
}

sub was_aliased_from {
    my ($self, @classnames) = @_;

    die '[ARGS] You must specify at least one classname'
        if scalar( @classnames ) == 0;

    my $class = $self->origin_stash;
    foreach my $candidate ( @classnames ) {
        return 1 if $candidate eq $class;
    }
    return 0;
}

1;

__END__

=pod

=head1 DESCRIPTION

A slot is best thought of as representing a single entry in the 
package scoped C<%HAS> variable. This is basically just building upon the 
conceptual model laid out by L<UNIVERSAL::Object>.

=head1 CONSTRUCTORS

=over 4

=item L<new( name => $name, initializer => $initializer )>

=item L<new( $name, $initializer )>

=back

=head1 METHODS

=over 4

=item C<name>

=item C<initializer>

=item C<origin_stash>

=item C<was_aliased_from>

=back

=cut
