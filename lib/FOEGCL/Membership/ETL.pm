package FOEGCL::Membership::ETL;
# ABSTRACT: Extract, transform and load data from the Legacy DB to the WebApp DB

use Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::ETL::Friend ();

with qw(
    FOEGCL::Membership::Role::HasLegacySchema
    FOEGCL::Membership::Role::HasSchema
    MooseX::Getopt::Dashes
);

sub run {
    my $self = shift;
    $self->_etl_city_state_zips;
    $self->_etl_roletypes;
    $self->_etl_friends;
}

sub _etl_city_state_zips {
    my $self = shift;
    
    my $legacy_csz_rs = $self->_legacy_schema->resultset('CityStateZip');
    my $webapp_csz_rs = $self->_schema->resultset('CityStateZip');
    while (my $legacy_csz = $legacy_csz_rs->next) {
        $webapp_csz_rs->create(
            {
                city => trim($legacy_csz->city),
                state_abbr => trim($legacy_csz->state),
                zip => trim($legacy_csz->postal_code),
            }
        );
    }
}

sub _etl_roletypes {
    my $self = shift;
    
    my $legacy_role_types_rs = $self->_legacy_schema->resultset('RolesType');
    my $webapp_participation_role_rs = $self->_schema->resultset('ParticipationRole');
    while (my $legacy_role_type = $legacy_role_types_rs->next) {
        my $role_name = trim($legacy_role_type->role);
        $role_name = 'Historical ' . $role_name
            if $legacy_role_type->historical;
    
        $webapp_participation_role_rs->create(
            {
                role_name => $role_name,
                is_hidden => $legacy_role_type->historical,
            }
        );
    }
}

sub _etl_friends {
    my $self = shift;

    my $legacy_friend_rs = $self->_legacy_schema->resultset('Friend')
        ->search_rs( undef, { order_by => 'FriendID' } );
    while (my $legacy_friend = $legacy_friend_rs->next) {
        FOEGCL::Membership::ETL::Friend->new(
            legacy_friend => $legacy_friend,
        )->etl;
    }
}

__PACKAGE__->meta->make_immutable;
1;