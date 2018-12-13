package TestForETL::Report::MembershipRenewalMailingList;

use FOEGCL::Membership::Test::Class::Moose;

use Test::Differences 'eq_or_diff';

with(
    'FOEGCL::Membership::Role::UsesLegacyDatabase',
    'FOEGCL::Membership::Role::UsesWebAppDatabase',
);

sub test_membership_renewal_mailing_list ( $self, @ ) {
    my @migrated_memberships_for_renewal = sort {
               $a->{State} cmp $b->{State}
            || $a->{City} cmp $b->{City}
            || $a->{PostalCode} cmp $b->{PostalCode}
            || $a->{Address} cmp $b->{Address}
        }
        map {
        +{
            Name    => $_->{recipients},
            Address => $_->{street_line_1}
                . (
                $_->{street_line_2} ? "\r\n" . $_->{street_line_2} : q{} ),
            City       => $_->{city},
            State      => $_->{state_abbr},
            PostalCode => $_->{zip},
        }
        } $self->_schema->resultset(
        'MembershipRenewalMailingListByContribution')->search_rs(
        undef,
        {
            order_by =>
                [qw( state_abbr city zip street_line_1 street_line_2 )]
        }
    )->hri->all;

    my @legacy_memberships_for_renewal = sort {
               $a->{State} cmp $b->{State}
            || $a->{City} cmp $b->{City}
            || $a->{PostalCode} cmp $b->{PostalCode}
            || $a->{Address} cmp $b->{Address}
        }
        map { +{ $_->%{qw( Name Address City State PostalCode )} } }
        $self->_legacy_schema->resultset('MmRenewalMailingAllNonRenew2018')
        ->search_rs(
        undef,
        { order_by => [qw( State City PostalCode Address )] }
    )->hri->all;

    eq_or_diff(
        \@migrated_memberships_for_renewal,
        \@legacy_memberships_for_renewal,
        'membership renewal lists by contribution are identical'
    );
}

__PACKAGE__->meta->make_immutable;

1;
