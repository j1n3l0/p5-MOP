package MOP::Util;
# ABSTRACT: For MOP External Use Only

use strict;
use warnings;

use MOP::Role;
use MOP::Internal::Util ();

our $VERSION   = '0.09';
our $AUTHORITY = 'cpan:STEVAN';

sub APPLY_ROLES { MOP::Internal::Util::APPLY_ROLES( @_ ) }

sub INHERIT_SLOTS {
    my ($meta) = @_;
    foreach my $super ( map { MOP::Role->new( name => $_ ) } @{ $meta->mro } ) {
        foreach my $slot ( $super->slots ) {
            $meta->alias_slot( $slot->name, $slot->initializer )
                unless $meta->has_slot( $slot->name )
                    || $meta->has_slot_alias( $slot->name );
        }
    }
}

1;

__END__

=pod

=head1 DESCRIPTION

No user serviceable parts inside.

=cut



