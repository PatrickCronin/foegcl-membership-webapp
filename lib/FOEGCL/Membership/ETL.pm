package FOEGCL::Membership::ETL;

use Moose;

has _annual_membership_amounts => (
    is => 'ro',
    isa => HashRef,
    builder => '_build_annual_membership_amounts',
);

with qw(
    FOEGCL::Membership::Role::HasLegacySchema
    FOEGCL::Membership::Role::HasSchema
);

sub _build_annual_membership_amounts {
    my $self = shift;
 
    return {
        2011 => { individual => 10, family => 20 },
        2012 => { individual => 10, family => 20 },
        2013 => { individual => 10, family => 20 },
        2014 => { individual => 10, family => 20 },
        2015 => { individual => 10, family => 20 },
        2016 => { individual => 15, family => 25 },
        2017 => { individual => 15, family => 25 },
    };
}

sub run {
    $self->_etl_city_state_zips;
    $self->_etl_roletypes;
    $self->_etl_friends;
}

sub _etl_city_state_zips {
    my $self = shift;
    
    my $legacy_csz_rs = $self->_legacy_schema->resultset('CityStateZip');
    my $webapp_csz_rs = $self->_schema->resultset('CityStateZip');
    while (my $legacy_csz = $legacy_csz_rs->next) {
        $webapp_csz_rs->find_or_create(
            {
                city => $legacy_csz->city,
                state_abbr => $legacy_csz->state,
                zip => $legacy_csz->postal_code,
            },
            { key => 'city_state_zip_zip_city_state_abbr_key' }
        );
    }
}

sub _etl_roletypes {
    my $self = shift;
    
    my $legacy_role_types_rs = $self->_legacy_schema->resultset('RoleTypes');
    my $webapp_participation_role_rs = $self->_schema->resultset('ParticipationRole');
    while (my $legacy_role_type = $legacy_role_types_rs->next) {
        my $role_name = $legacy_role_type->role;
        $role_name = 'Historical ' . $role_name
            if $legacy_role_type->historical;
    
        $webapp_participation_role_rs->find_or_create(
            { role_name => $role_name },
            { key => 'participation_role_role_name_key' }
        );
    }
}

sub _etl_friends {
    my $self = shift;
    
    my $legacy_friend_rs = $self->_legacy_schema->resultset('Friend');
    my $webapp_affiliation_rs = $self->_schema->resultset('Affiliation');
    while (my $legacy_friend = $legacy_friend_rs->next) {
        my $affiliation = $self->_etl_friend_affiliation($legacy_friend);
        $self->_etl_friend_address($legacy_friend, $affiliation);
        $self->_etl_friend_donations($legacy_friend, $affiliation);
        my @people = $self->_etl_friend_people($legacy_friend, $affiliation);
        $self->_etl_friend_emails($legacy_friend, @people);
        $self->_etl_friend_phones($legacy_friend, @people);
        $self->_etl_friend_historical_roles($legacy_friend, @people);
        $self->_etl_friend_interested_roles($legacy_friend, @people);
    }
}

sub _etl_friend_affiliation {
    my ($self, $legacy_friend) = @_;
    
    return $self->_schema->resultset('Affiliation')->create();
}

sub _etl_friend_address {
    my ($self, $legacy_friend, $affiliation) = @_;
    
    my $fields = {
        affiliation_id => $affiliation,
        csz_id => $self->_schema->resultset('CityStateZip')->find_or_create(
            {
                city => $legacy_friend->city_state_zip->city,
                state_abbr => $legacy_friend->city_state_zip->state,
                zip => $legacy_friend->city_state_zip->postal_code,
            },
            { key => 'city_state_zip_zip_city_state_abbr_key' }
        ),
    };
    
    my @street_lines = split /(?:\r\n|\r|\n)+/, $legacy_friend->address;
    die 'Address for Friend ' . $legacy_friend->friend_id
        . ' has more than 3 street address lines!'
        if @street_lines > 2;
    $fields->{"street_address_$_"} = $street_lines[$_ - 1]
        for (1..@street_lines);
    
    return $self->_schema->resultset('ResidentialAddress')->create($fields);
}

sub _etl_friend_donations {
    my ($self, $legacy_friend, $affiliation) = @_;
    
    my %annual_donations = $self->_extract_annual_donations(
        $legacy_friend->donations
    );
    
    $self->_load_friend_annual_donation(
        $legacy_friend,
        $affiliation,
        $_,
        $annual_donations{$_}
    ) for keys %annual_donations;
}

sub _extract_annual_donations (
    my ($self, $donations) = @_;
    
    my %annual_donations;
    while (my $donation = $donations->next) {
        $annual_donation{$donation->year} = []
            if ! exists $annual_donations{$donation->year};
        push @{ $annual_donations{$donation->year} }, $donation->donation;
    };
    
    return %annual_donations;
)

sub _load_annual_donations {
    my ($self, $legacy_friend, $affiliation, $year, $donations) = @_;
    
    my $expected_membership_amount = $self->_annual_membership_amounts
        ->{$year}
        ->{
            defined $legacy_friend->spouse_first_name
            ? 'family'
            : 'individual'
        };
    
    my @parts = part {
        1 + ($_ <=> $expected_membership_amount)
    } @{ $donations };
    
    my $processed_membership;
    my @processed_donations;
    
    # Does a donation equal the expected membership amount? If so, its the membership; remaining are donations.
    if (defined $parts[1]) {
        $processed_membership = shift @{ $parts[1] };
        push @processed_donations, @{ $parts[1] };
        push @processed_donations, @{ $parts[0] ) if defined $parts[0];
        push @processed_donations, @{ $parts[2] ) if defined $parts[2];
    }
    # Does a donation total more than the expected membership amount? If so, cut it in two.
    elsif (defined $parts[2]) {
        my $combined_donation = shift @{ $parts[2] };
        $processed_membership = $expected_membership_amount;
        push @processed_donations, $combined_donation - $expected_membership_amount;
        push @processed_donations, @{ $parts[0] } if defined $parts[0];
        push @processed_donations, @{ $parts[2] } if @{ $parts[2] };
    }   
    # Does a sum of the donations total more than the expected membership amount? If so, add them together, cutting if need be.
    # Otherwise, all are donations; no membership.
    else {
        my $incremental_membership = 0;
        
        while (
            $incremental_membership < $expected_membership_amount
            && @{ $donations }
            ) {
            $incremental_membership += shift @{ $donations };
        } 
        
        if ($incremental_membership >= $expected_membership_amount) {
            $processed_membership = $expected_membership_amount;
            push @processed_donations, $incremental_membership - $expected_membership_amount
                if $incremental_membership > $expected_membesrhip_amount;
            push @processed_donations, @{ $donations };
        }
        else {
            push @processed_donations, @{ $donations };
        }
    }
    
    $self->_schema->resultset('Donation')->create({
        affiliation_id => $affiliation,
        affiliation_year => $year,
        donation_type => 'membership_fee',
        amount => $processed_membership,
    }) if defined $processed_membership;
    
    $self->_schema->resultset('Donation')->create({
        affiliation_id => $affiliation,
        affiliation_year => $year,
        donation_type => 'donation',
        amount => $_,
    }) for @processed_donations;
    
}

sub _etl_friend_people {
    my ($self, $legacy_friend, $affiliation) = @_;
    
    my @people;
    
    push @people, $self->_schema->resultset('Person')->create({
        affiliation_id => $affiliation,
        first_name => $legacy_friend->first_name,
        last_name => $legacy_friend->last_name,
        opted_out => $legacy_friend->inactive,
    });
    
    push @people, $self->_schema->resultset('Person')->create({
        affiliation_id => $affiliation,
        first_name => $legacy_friend->spouse_first_name,
        last_name => $legacy_friend->spouse_last_name,
        opted_out => $legacy_friend->inactive,
    }) if defined $legacy_friend->spouse_first_name
        || defined $legacy_friend->spouse_last_name;
    
    return @people;
}

sub _etl_friend_emails {
    my ($self, $legacy_friend, @people) = @_;
 
    my $friend_email_rs = $legacy_friend->contact_infos->search({
        email_address => { '!=' => undef }
    });
    
    while (my $friend_email = $friend_email_rs->next) {
        $self->_schema->resultset('PersonEmail')->create({
            person_id => $_,
            email_address => $friend_email->email_address,
            is_preferred => $friend_email->preferred,
        }) for @people;
    }
}

sub _etl_friend_phones {
    my ($self, $legacy_friend, @people) = @_;
 
    my $friend_phone_rs = $legacy_friend->contact_infos->search({
        area_code => { '!=' => undef },
        phone_number => { '!=' => undef },
    });
    
    while (my $friend_phone = $friend_phone_rs->next) {
        $self->_schema->resultset('PersonPhone')->create({
            person_id => $_,
            phone_number => $friend_phone->area_code . q{ }
                . $friend_phone->phone_number,
            is_preferred => $friend_phone->preferred,
        }) for @people;
    }
}

sub _etl_friend_historical_roles {
    my ($self, $legacy_friend, @people) = @_;
    
    ...
}

sub _etl_friend_interested_roles {
    my ($self, $legacy_friend, @people) = @_;
    
    ...
}

__PACKAGE__->meta->make_immutable;
1;