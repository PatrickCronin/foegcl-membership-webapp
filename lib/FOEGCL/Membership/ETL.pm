package FOEGCL::Membership::ETL;

use Moose;

use Carp qw(croak);
use DDP;
use List::MoreUtils qw(part);
use List::Util qw(sum0);

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
                city => $self->_trim($legacy_csz->city),
                state_abbr => $self->_trim($legacy_csz->state),
                zip => $self->_trim($legacy_csz->postal_code),
            }
        );
    }
}

sub _etl_roletypes {
    my $self = shift;
    
    my $legacy_role_types_rs = $self->_legacy_schema->resultset('RolesType');
    my $webapp_participation_role_rs = $self->_schema->resultset('ParticipationRole');
    while (my $legacy_role_type = $legacy_role_types_rs->next) {
        my $role_name = $self->_trim($legacy_role_type->role);
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
    
    my $legacy_friend_rs = $self->_legacy_schema->resultset('Friend');
    while (my $legacy_friend = $legacy_friend_rs->next) {
        my $affiliation = $self->_etl_friend_affiliation($legacy_friend);
        $self->_etl_friend_address($legacy_friend, $affiliation);
        $self->_etl_friend_donations($legacy_friend, $affiliation);
        my @people = $self->_etl_friend_people($legacy_friend, $affiliation);
        $self->_etl_friend_emails($legacy_friend, @people);
        $self->_etl_friend_phones($legacy_friend, @people);
        $self->_etl_friend_interested_roles($legacy_friend, @people);
    }
}

sub _etl_friend_affiliation {
    my ($self, $legacy_friend) = @_;
    
    return $self->_schema->resultset('Affiliation')->create({
        legacy_friend_id => $legacy_friend->friend_id
    });
}

sub _etl_friend_address {
    my ($self, $legacy_friend, $affiliation) = @_;
    return if ! defined $legacy_friend->city_state_zip;
    
    my %fields = (
        affiliation_id => $affiliation->affiliation_id,
        csz_id => $self->_schema->resultset('CityStateZip')->find(
            {
                city => $self->_trim($legacy_friend->city_state_zip->city),
                state_abbr => $self->_trim($legacy_friend->city_state_zip->state),
                zip => $self->_trim($legacy_friend->city_state_zip->postal_code),
            },
            { key => 'city_state_zip_is_unique' }
        )->csz_id,
    );
    
    my @street_lines = split /(?:\r\n|\r|\n)+/, $legacy_friend->address;
    die 'Address for Friend ' . $legacy_friend->friend_id
        . ' has more than 2 street address lines!'
        if @street_lines > 2;
    $fields{"street_line_$_"} = $self->_trim($street_lines[$_ - 1]) for 1..2;

    return $self->_schema->resultset('PhysicalAddress')->create(\%fields);
}

sub _etl_friend_donations {
    my ($self, $legacy_friend, $affiliation) = @_;
    
    my %annual_donations;
    push @{ $annual_donations{$_->year} }, $_->donation for $legacy_friend->donations;
    
    my %transformed_annual_donations;
    $transformed_annual_donations{$_} = $self->_transform_year_friend_donations(
        $legacy_friend,
        $_,
        @{ $annual_donations{$_} }
    ) for keys %annual_donations;
    
    for my $year (keys %transformed_annual_donations) {
        for my $donation (@{ $transformed_annual_donations{$year} } ) {
            $self->_schema->resultset('Donation')->create({
                affiliation_id => $affiliation->affiliation_id,
                affiliation_year => $year,
                donation_type => $donation->[0],
                amount => $donation->[1],
            });
        }
    }
}

sub _transform_year_friend_donations {
    my ($self, $legacy_friend, $year, @donations) = @_;
   
    my @given = @donations;
   
    my %membership_req =
        $self->_year_membership_requirements($year, $legacy_friend);
    
    my @transformed;
    
    my $donations_total = sum0 @donations;
    if ($donations_total >= $membership_req{'expected_amount'}) {
        @transformed = 
            $self->_transform_year_friend_donations_for_membership_type(
            $membership_req{'expected_type'},
            $membership_req{'expected_amount'},
            @donations
        );
    }
    elsif ($year < 2017
        && $donations_total >= $membership_req{'other_amount'}
        ) {
        @transformed = 
            $self->_transform_year_friend_donations_for_membership_type(
            $membership_req{'other_type'},
            $membership_req{'other_amount'},
            @donations
        );
    }
    else {
        @transformed =
            $self->_transform_year_friend_donations_to_contributions(
                @donations
            );
    }
    
    if ( (sum0 @given) != (sum0 map { $_->[1] } @transformed) ) {
        my %debug = (
            legacy_friend => $legacy_friend->friend_id,
            year => $year,
            legacy_donations => \@given,
            legacy_total => (sum0 @given),
            transformed_donations => \@transformed,
            transformed_total => (sum0 map { $_->[1] } @transformed),
        );
        p %debug;
    }
    
    return \@transformed;
}

sub _transform_year_friend_donations_for_membership_type {
    my ($self, $membership_type, $membership_amount, @donations) = @_;
    
    my @parts = part { 1 + ($_ <=> $membership_amount) } @donations;
    
    # Does a donation equal the expected amount? If so, its the membership; remaining are donations.
    return (
        [ $membership_type, 0 + shift @{ $parts[1] } ],
        $self->_transform_year_friend_donations_to_contributions(
            grep { $_ > 0 } map { @{ $_ } } grep { defined } @parts
        )
    ) if defined $parts[1];
    
    # Does a single donation total more than the expected membership amount? If so, split it.
    if (defined $parts[2]) {
        my $combined_donation = 0 + shift @{ $parts[2] };
        unshift @{ $parts[2] },
            $membership_amount,
            $combined_donation - $membership_amount;
    }
    # Does a sum of the donations total the expected amount or more? If so, add 'em up and split the total if necessary.
    elsif (sum0(@donations) >= $membership_amount) {   
        my $sum = 0;
        while (@donations && $sum < $membership_amount) {
            $sum += shift @{ $parts[0] };
        }
        unshift @{ $parts[0] },
            $membership_amount,
            $sum - $membership_amount;
    }
    else {
        confess "This sub cannot handle donations total under membership_amount. " . (sum0 @donations) . ' ' . $membership_amount;
    }
    
    return $self->_transform_year_friend_donations_for_membership_type(
        $membership_type,
        $membership_amount,
        grep { $_ > 0 } map { @{ $_ } } grep { defined } @parts
    );
}

sub _transform_year_friend_donations_to_contributions {
    my ($self, @contributions) = @_;
    
    return
        map { [ 'general_contribution', 0 + $_ ] }
        grep { $_ > 0 }
        @contributions;
}

sub _year_membership_requirements {
    my ($self, $year, $legacy_friend) = @_;
    
    my @year_memberships = $self->_schema->resultset('AffiliationYearMembershipLevel')->search(
        { affiliation_year => $year }
    );
    
    my %year_membership_requirements = map {
        $_->membership_donation_type->donation_type => 0 + $_->amount
    } @year_memberships;
        
    my $is_currently_household = defined $legacy_friend->spouse_first_name && $self->_trim($legacy_friend->spouse_first_name) ne '';
    return (
        'expected_type' => $is_currently_household
            ? 'household_membership'
            : 'individual_membership',
        'expected_amount' => $is_currently_household
            ? $year_membership_requirements{household_membership}
            : $year_membership_requirements{individual_membership},
        'other_type' => $is_currently_household
            ? 'individual_membership'
            : 'household_membership',
        'other_amount' => $is_currently_household
            ? $year_membership_requirements{individual_membership}
            : $year_membership_requirements{household_membership}
    );
}

sub _etl_friend_people {
    my ($self, $legacy_friend, $affiliation) = @_;
    
    my @people;
        
    push @people, $self->_schema->resultset('Person')->create({
        affiliation_id => $affiliation->affiliation_id,
        first_name => $self->_trim($legacy_friend->first_name),
        last_name => $self->_trim($legacy_friend->last_name),
        opted_out => $legacy_friend->inactive,
    });
    
    push @people, $self->_schema->resultset('Person')->create({
        affiliation_id => $affiliation->affiliation_id,
        first_name => $self->_trim($legacy_friend->spouse_first_name),
        last_name => $self->_trim($legacy_friend->spouse_last_name),
        opted_out => $legacy_friend->inactive,
    }) if defined $legacy_friend->spouse_first_name && $self->_trim($legacy_friend->spouse_first_name) ne '';
    
    return @people;
}

sub _etl_friend_emails {
    my ($self, $legacy_friend, @people) = @_;
 
    my $friend_email_rs = $legacy_friend->contact_infos->search({
        email_address => { '!=' => undef }
    });
    
    while (my $friend_email = $friend_email_rs->next) {
        $self->_schema->resultset('PersonEmail')->create({
            person_id => $_->person_id,
            email_address => $friend_email->email_address,
            is_preferred => $friend_email->preferred,
        }) for @people;
    }
}

sub _etl_friend_phones {
    my ($self, $legacy_friend, @people) = @_;
 
    my $friend_phone_rs = $legacy_friend->contact_infos->search({
        'Phone Number' => { '!=' => undef },
    });
    
    while (my $friend_phone = $friend_phone_rs->next) {
        $self->_schema->resultset('PersonPhone')->create({
            person_id => $_->person_id,
            phone_number => $friend_phone->area_code . q{ }
                . $friend_phone->phone_number,
            is_preferred => $friend_phone->preferred,
        }) for @people;
    }
}

sub _etl_friend_interested_roles {
    my ($self, $legacy_friend, @people) = @_;
    
    my $legacy_roles_rs = $legacy_friend->roles;
    my $webapp_interests_rs =
        $self->_schema->resultset('PersonInterestedInParticipating');
    my $webapp_roles_rs =
        $self->_schema->resultset('ParticipationRole');
    while (my $legacy_role = $legacy_roles_rs->next) {   
        next if $legacy_role->role_type->historical;
        $webapp_interests_rs->create({
            person_id => $_->person_id,
            participation_role_id => $webapp_roles_rs->find(
                { role_name => $self->_trim($legacy_role->role_type->role) },
                { key => 'role_name_is_unique' },
            )->participation_role_id,
        }) for @people;
    }
}

sub _trim {
    my ($self, @values) = @_;
    
    my @trimmed_values = map { 
        defined $_ ? s/\A \s+ | \s+ \z//rgx : undef
    } @values;
    
    return @trimmed_values if wantarray;
    return $trimmed_values[0];
}

__PACKAGE__->meta->make_immutable;
1;