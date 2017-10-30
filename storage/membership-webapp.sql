SET TIME ZONE 'UTC';

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE applied_migration (
    migration TEXT PRIMARY KEY,
    applied timestamp with time zone DEFAULT NOW()
);

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(64) NOT NULL
        CONSTRAINT first_name_is_trimmed_and_not_empty CHECK(first_name <> '' AND first_name = trim(both from first_name)),
    last_name VARCHAR(64) NOT NULL
        CONSTRAINT last_name_is_trimmed_and_not_empty CHECK(last_name <> '' AND last_name = trim(both from last_name)),
    opted_out boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX person__first_name__gin_trgm_idx ON person USING gin (first_name gin_trgm_ops);
CREATE INDEX person__last_name__gin_trgm_idx ON person USING gin (last_name gin_trgm_ops);
CREATE INDEX person__opted_out ON person (opted_out);

CREATE TABLE person_phone (
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    phone_number VARCHAR(32) NOT NULL CHECK (phone_number <> '')
        CONSTRAINT phone_number_is_one_or_more_digits CHECK (phone_number <> '' and phone_number ~ '^\d+$'),
    is_preferred boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, phone_number)
);

CREATE INDEX person_phone__phone_number__gin_trgm_idx ON person_phone USING gin (phone_number gin_trgm_ops);

CREATE TABLE person_email (
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    email_address VARCHAR(128) NOT NULL
        CONSTRAINT email_address_is_trimmed_and_not_empty CHECK (email_address <> '' AND email_address = trim(both from email_address)),
    is_preferred boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, email_address)
);

CREATE INDEX person_email__email_address__gin_trgm_idx ON person_email USING gin (email_address gin_trgm_ops);

CREATE TABLE state (
    state_abbr CHAR(2) PRIMARY KEY,
    state_name VARCHAR(32) NOT NULL
        CONSTRAINT state_name_is_unique UNIQUE
        CONSTRAINT state_name_is_trimmed_and_not_empty CHECK (state_name <> '' AND state_name = trim(both from state_name) ),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

INSERT INTO state (state_abbr, state_name)
VALUES
    ('AL', 'Alabama'),
    ('AK', 'Alaska'),
    ('AZ', 'Arizona'),
    ('AR', 'Arkansas'),
    ('CA', 'California'),
    ('CO', 'Colorado'),
    ('CT', 'Connecticut'),
    ('DE', 'Delaware'),
    ('DC', 'District of Columbia'),
    ('FL', 'Florida'),
    ('GA', 'Georgia'),
    ('HI', 'Hawaii'),
    ('ID', 'Idaho'),
    ('IL', 'Illinois'),
    ('IN', 'Indiana'),
    ('IA', 'Iowa'),
    ('KS', 'Kansas'),
    ('KY', 'Kentucky'),
    ('LA', 'Louisiana'),
    ('ME', 'Maine'),
    ('MD', 'Maryland'),
    ('MA', 'Massachusetts'),
    ('MI', 'Michigan'),
    ('MN', 'Minnesota'),
    ('MS', 'Mississippi'),
    ('MO', 'Missouri'),
    ('MT', 'Montana'),
    ('NE', 'Nebraska'),
    ('NV', 'Nevada'),
    ('NH', 'New Hampshire'),
    ('NJ', 'New Jersey'),
    ('NM', 'New Mexico'),
    ('NY', 'New York'),
    ('NC', 'North Carolina'),
    ('ND', 'North Dakota'),
    ('OH', 'Ohio'),
    ('OK', 'Oklahoma'),
    ('OR', 'Oregon'),
    ('PA', 'Pennsylvania'),
    ('RI', 'Rhode Island'),
    ('SC', 'South Carolina'),
    ('SD', 'South Dakota'),
    ('TN', 'Tennessee'),
    ('TX', 'Texas'),
    ('UT', 'Utah'),
    ('VT', 'Vermont'),
    ('VA', 'Virginia'),
    ('WA', 'Washington'),
    ('WV', 'West Virginia'),
    ('WI', 'Wisconsin'),
    ('WY', 'Wyoming');

CREATE TABLE city_state_zip (
    csz_id SERIAL PRIMARY KEY,
    zip CHAR(5) NOT NULL
        CONSTRAINT zip_is_five_digits CHECK (zip ~ '^[0-9]{5}$'),
    city VARCHAR(64) NOT NULL
        CONSTRAINT city_is_trimmed_and_not_empty CHECK (city <> '' AND city = trim(both from city)),
    state_abbr CHAR(2) NOT NULL REFERENCES state (state_abbr) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    CONSTRAINT city_state_zip_is_unique UNIQUE(zip, city, state_abbr)
);

CREATE INDEX city_state_zip__city__gin_trgm_idx ON city_state_zip USING gin (city gin_trgm_ops);
CREATE INDEX city_state_zip__zip ON city_state_zip (zip);

CREATE TABLE mailing_address (
    person_id INTEGER NOT NULL PRIMARY KEY REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    street_line_1 VARCHAR(128) NOT NULL
        CONSTRAINT mailing_address_street_line_1_is_trimmed_and_not_empty CHECK (street_line_1 <> '' AND street_line_1 = trim(both from street_line_1)),
    street_line_2 VARCHAR(128)
        CONSTRAINT mailing_address_street_line_2_is_null_or_trimmed_and_not_empty CHECK (street_line_2 IS NULL OR (street_line_2 <> '' AND street_line_2 = trim(both from street_line_2))),
    csz_id INTEGER NOT NULL REFERENCES city_state_zip (csz_id) ON DELETE CASCADE ON UPDATE CASCADE,
    plus_four CHAR(4) DEFAULT NULL
        CONSTRAINT mailing_address_plus_four_is_null_or_five_digits CHECK (plus_four IS NULL OR plus_four ~ '^[0-9]{4}$'),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX mailing_address__street_line_1__gin_trgm_idx ON mailing_address USING gin (street_line_1 gin_trgm_ops);
CREATE INDEX mailing_address__street_line_2__gin_trgm_idx ON mailing_address USING gin (street_line_2 gin_trgm_ops);

CREATE TYPE library_special_voting_district_status AS ENUM ('in', 'out', 'unchecked', 'checked-but-unknown');

CREATE TABLE physical_address (
    person_id INTEGER NOT NULL PRIMARY KEY REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    street_line_1 VARCHAR(128) NOT NULL
        CONSTRAINT physical_address_street_line_1_is_trimmed_and_not_empty CHECK (street_line_1 <> '' AND street_line_1 = trim(both from street_line_1)),
    street_line_2 VARCHAR(128)
        CONSTRAINT physical_address_street_line_2_is_null_or_trimmed_and_not_empty CHECK (street_line_2 IS NULL OR (street_line_2 <> '' AND street_line_2 = trim(both from street_line_2))),
    csz_id INTEGER NOT NULL REFERENCES city_state_zip (csz_id) ON DELETE CASCADE ON UPDATE CASCADE,
    plus_four CHAR(4) DEFAULT NULL
        CONSTRAINT physical_address_plus_four_is_null_or_five_digits CHECK (plus_four IS NULL OR plus_four ~ '^[0-9]{4}$'),
    in_library_special_voting_district library_special_voting_district_status DEFAULT 'unchecked'::library_special_voting_district_status,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX physical_address__street_line_1__gin_trgm_idx ON physical_address USING gin (street_line_1 gin_trgm_ops);
CREATE INDEX physical_address__street_line_2__gin_trgm_idx ON physical_address USING gin (street_line_2 gin_trgm_ops);

CREATE TABLE participation_role (
    participation_role_id SERIAL PRIMARY KEY,
    parent_role_id INTEGER REFERENCES participation_role (participation_role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    role_name VARCHAR(128) NOT NULL
        CONSTRAINT participation_role_name_is_trimmed_and_not_empty CHECK (role_name <> '' AND role_name = trim(both from role_name))
        CONSTRAINT participation_role_name_is_unique UNIQUE,
    is_hidden boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX participation_role__parent_role_id ON participation_role (parent_role_id);

CREATE TABLE participation_interest (
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    participation_role_id INTEGER NOT NULL REFERENCES participation_role (participation_role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, participation_role_id)
);

CREATE INDEX participation_interest__participation_role_id ON participation_interest (participation_role_id);

CREATE TABLE affiliation_year (
    affiliation_year SMALLINT PRIMARY KEY
        CONSTRAINT affiliation_year_is_reasonable CHECK (affiliation_year >= 1980 AND affiliation_year <= 2079),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

INSERT INTO affiliation_year (affiliation_year)
VALUES
    (2011),
    (2012),
    (2013),
    (2014),
    (2015),
    (2016),
    (2017),
    (2018);

CREATE TABLE participation_record (
    affiliation_year SMALLINT NOT NULL REFERENCES affiliation_year (affiliation_year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    participation_role_id INTEGER NOT NULL REFERENCES participation_role (participation_role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (affiliation_year, person_id, participation_role_id)
);

CREATE INDEX participation_record__person_id ON participation_record (person_id);
CREATE INDEX participation_record__participation_role_id ON participation_record (person_id);

CREATE TABLE affiliation (
    affiliation_id SERIAL PRIMARY KEY,
    affiliation_year SMALLINT NOT NULL REFERENCES affiliation_year (affiliation_year) ON DELETE CASCADE ON UPDATE CASCADE,
    friend_id NUMERIC(11) NOT NULL,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

COMMENT ON COLUMN affiliation.friend_id IS 'This value should follow a renewed affiliation. Otherwise, a new one should be assigned.';

CREATE INDEX affiliation__affiliation_year ON affiliation (affiliation_year);
CREATE INDEX affiliation__friend_id ON affiliation (friend_id);

CREATE OR REPLACE FUNCTION next_friend_id()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.friend_id IS NULL THEN
        NEW.friend_id = (SELECT MAX(friend_id) + 1 FROM affiliation);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER affiliation__next_friend_id
BEFORE INSERT OR UPDATE ON affiliation
FOR EACH ROW
EXECUTE PROCEDURE next_friend_id();

CREATE TABLE affiliation_person (
    affiliation_id INTEGER NOT NULL REFERENCES affiliation (affiliation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (affiliation_id, person_id)
);

CREATE INDEX affiliation_person__person_id ON affiliation_person (person_id);

CREATE TYPE donation_type AS ENUM ('individual_membership', 'household_membership', 'honorary_membership', 'general_donation');

CREATE TABLE membership_donation_type (
    affiliation_year SMALLINT NOT NULL REFERENCES affiliation_year (affiliation_year) ON DELETE CASCADE ON UPDATE CASCADE,
    donation_type donation_type NOT NULL,
    membership_max_people SMALLINT DEFAULT 1
        CONSTRAINT max_people_is_greater_than_zero_if_set CHECK (membership_max_people IS NULL OR membership_max_people > 0),
    membership_amount NUMERIC(11,2) NOT NULL
        CONSTRAINT membership_amount_is_not_negative CHECK (membership_amount >= 0),
    PRIMARY KEY (affiliation_year, donation_type)
);

INSERT INTO membership_donation_type
(affiliation_year, donation_type, membership_max_people, membership_amount)
VALUES
    (2011, 'individual_membership', 1, 10),
    (2011, 'household_membership', 2, 20),
    (2011, 'honorary_membership', NULL, 0),
    (2012, 'individual_membership', 1, 10),
    (2012, 'household_membership', 2, 20),
    (2012, 'honorary_membership', NULL, 0),
    (2013, 'individual_membership', 1, 10),
    (2013, 'household_membership', 2, 20),
    (2013, 'honorary_membership', NULL, 0),
    (2014, 'individual_membership', 1, 10),
    (2014, 'household_membership', 2, 20),
    (2014, 'honorary_membership', NULL, 0),
    (2015, 'individual_membership', 1, 10),
    (2015, 'household_membership', 2, 20),
    (2015, 'honorary_membership', NULL, 0),
    (2016, 'individual_membership', 1, 10),
    (2016, 'household_membership', 2, 20),
    (2016, 'honorary_membership', NULL, 0),
    (2017, 'individual_membership', 1, 15),
    (2017, 'household_membership', 2, 25),
    (2017, 'honorary_membership', NULL, 0),
    (2018, 'individual_membership', 1, 15),
    (2018, 'household_membership', 2, 25),
    (2018, 'honorary_membership', NULL, 0);

CREATE TABLE donation (
    donation_id SERIAL PRIMARY KEY,
    affiliation_id INTEGER NOT NULL REFERENCES affiliation (affiliation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    donation_type donation_type NOT NULL DEFAULT 'general_donation',
    amount NUMERIC(11,2) NOT NULL
        CONSTRAINT amount_is_not_negative CHECK (amount >= 0),
    notes VARCHAR(128)
        CONSTRAINT notes_is_null_or_trimmed_and_not_empty CHECK (notes IS NULL OR (notes <> '' AND notes = trim(both from notes))),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX donation__affiliation_id ON donation (affiliation_id);

CREATE VIEW membership AS
SELECT affiliation_id, affiliation_year, donation_type, membership_max_people
FROM donation
INNER JOIN affiliation USING (affiliation_id)
INNER JOIN membership_donation_type USING (affiliation_year, donation_type);

COMMENT ON VIEW membership IS 'Affiliations with a qualifying membership donation';

CREATE VIEW member AS
SELECT affiliation_id, affiliation_year, donation_type, person_id
FROM membership
INNER JOIN affiliation_person USING (affiliation_id);

COMMENT ON VIEW member IS 'People belonging to affiliations with qualifiying memberhsip donations';

CREATE FUNCTION person_is_in_current_affiliation(
    v_person_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'v_person_id cannot be NULL';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM affiliation_person
        INNER JOIN affiliation USING (affiliation_id)
        WHERE person_id <> v_person_id
        AND affiliation_year = date_part('year', CURRENT_DATE)
    ) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_address_insert()
RETURNS TRIGGER AS
$$
BEGIN
    IF person_is_in_affiliation(NEW.person_id) THEN
        RAISE EXCEPTION 'Cannot add an address directly to a person in an affiliation. Change the affiliation''s address instead';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_address_update()
RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.person_id <> NEW.person_id THEN
        RAISE EXCEPTION 'Cannot reassign a person''s address to another person. Delete this one and create a new one.';
    END IF;

    IF person_is_in_affiliation(NEW.person_id) THEN
        RAISE EXCEPTION 'Cannot update the address of a person in an affiliation. Change the affiliation''s address instead.';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_address_delete()
RETURNS TRIGGER AS
$$
BEGIN
    IF person_is_in_affiliation(NEW.person_id) THEN
        IF TG_TABLE_NAME = 'physical_address' THEN
            RAISE EXCEPTION 'Cannot delete the physical address of a person in an affiliation.';
        ELSIF TG_TABLE_NAME = 'mailing_address' THEN
            RAISE EXCEPTION 'Cannot delete the mailing address of a person in an affiliation. Please delete the mailing address of the person''s affiliation instead.';
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_mailing_address_on_insert
BEFORE INSERT ON mailing_address
FOR EACH ROW
WHEN (NEW.person_id IS NOT NULL)
EXECUTE PROCEDURE validate_address_insert();

CREATE TRIGGER check_mailing_address_on_update
BEFORE UPDATE ON mailing_address
FOR EACH ROW
WHEN (NEW.person_id IS NOT NULL)
EXECUTE PROCEDURE validate_address_update();

CREATE TRIGGER check_mailing_address_on_delete
BEFORE INSERT ON mailing_address
FOR EACH ROW
EXECUTE PROCEDURE validate_address_delete();

CREATE TRIGGER check_physical_address_on_insert
BEFORE INSERT ON physical_address
FOR EACH ROW
WHEN (NEW.person_id IS NOT NULL)
EXECUTE PROCEDURE validate_address_insert();

CREATE TRIGGER check_physical_address_on_update
BEFORE UPDATE ON physical_address
FOR EACH ROW
WHEN (NEW.person_id IS NOT NULL)
EXECUTE PROCEDURE validate_address_update();

CREATE TRIGGER check_physical_address_on_delete
BEFORE INSERT ON physical_address
FOR EACH ROW
EXECUTE PROCEDURE validate_address_delete();

CREATE FUNCTION clear_library_special_voting_district_on_update()
RETURNS TRIGGER AS $$
BEGIN
    NEW.in_library_special_voting_district = 'unchecked';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clear_library_special_voting_district_status
BEFORE UPDATE ON physical_address
FOR EACH ROW
WHEN (
    OLD.street_line_1 <> NEW.street_line_1
    OR OLD.street_line_2 IS DISTINCT FROM NEW.street_line_2
    OR OLD.csz_id <> NEW.csz_id
)
EXECUTE PROCEDURE clear_library_special_voting_district_on_update();

CREATE FUNCTION validate_affiliation_update()
RETURNS TRIGGER AS $$
DECLARE
    v_old_membership_amount NUMERIC(11,2) DEFAULT NULL;
    v_membership_donation_type donation_type DEFAULT NULL;
    v_new_membership_amount NUMERIC(11,2) DEFAULT NULL;
    v_new_membership_max_people SMALLINT DEFAULT NULL;
BEGIN
    -- The year change means the donation membership parameters may have
    -- changed. Validate that the new membership parameters will still be
    -- respected.
    SELECT membership_amount, donation_type
    INTO v_old_membership_amount, v_membership_donation_type
    FROM membership
    WHERE affiliation_id = OLD.affiliation_id;

    IF v_membership_donation_type IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT membership_amount, membership_max_people
    INTO v_new_membership_amount, v_new_membership_max_people
    FROM membership_donation_type
    WHERE affiliation_year = NEW.affiliation_year
    AND donation_type = v_membership_donation_type;

    IF v_old_membership_amount IS DISTINCT FROM v_new_membership_amount THEN
        RAISE EXCEPTION 'Cannot update affiliation because the new membership donation amount does not match the previous donation amount. Please delete the membership donation, update the affiliation, and add the appropriate donation(s).';
    END IF;

    IF v_new_membership_max_people IS NOT NULL THEN
        IF (
            SELECT COUNT(person_id)
            FROM affiliation_person
            WHERE affiliation_id = OLD.affiliation_id
        ) > v_new_membership_max_people THEN
            RAISE EXCEPTION 'Cannot update affiliation because the membership would have too many members. Please delete the membership donation, update the affiliation, and re-add the appropriate donation(s).';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_affiliation_update
BEFORE UPDATE ON affiliation
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.affiliation_year IS NOT NULL
    AND OLD.affiliation_year <> NEW.affiliation_year
)
EXECUTE PROCEDURE validate_affiliation_update();

CREATE FUNCTION affiliation_can_fit_another_person (
    v_affiliation_id INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_membership_max_people SMALLINT DEFAULT NULL;
BEGIN
    IF v_affiliation_id IS NULL THEN
        RAISE EXCEPTION 'v_affiliation_id cannot be NULL';
    END IF;

    IF NOT affiliation_is_membership(v_affiliation_id) THEN
        RETURN TRUE;
    END IF;

    SELECT membership_max_people
    INTO v_membership_max_people
    FROM membership
    WHERE affiliation_id = v_affiliation_id;

    IF v_membership_max_people IS NULL THEN
        RETURN TRUE;
    END IF;

    IF (
        SELECT COUNT(*) + 1
        FROM affiliation_person
        WHERE affiliation_id = v_affiliation_id
    ) <= v_membership_max_people THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION person_has_physical_address(
    v_person_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'v_person_id cannot be NULL';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM physical_address
        WHERE person_id = v_person_id
    ) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION person_address_suitable_for_affiliation(
    v_person_id INTEGER,
    v_affiliation_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'v_person_id cannot be NULL';
    ELSIF v_affiliatoin_id IS NULL THEN
        RAISE EXCEPTION 'v_affiliatoin_id cannot be NULL';
    END IF;

    -- 1. All people in an affiliation must have a physical address
    -- 2. All people in an affiliation must have the same physical address
    -- 3. All people in an affiliation must have the same mailing address (or
    --    all people may have no mailing address)
    IF person_has_physical_address(v_person_id)
        AND person_address_matches_affiliation_address(v_person_id, 'physical', v_affiliation_id)
        AND person_address_matches_affiliation_address(v_person_id, 'mailing', v_affiliation_id)
        THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION person_address_matches_affiliation_address (
    v_person_id INTEGER,
    v_address_type TEXT,
    v_affiliation_id INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_num_unique_addresses SMALLINT DEFAULT 0;
    v_table_name text := v_address_type || '_address';
BEGIN
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'v_person_id cannot be NULL';
    ELSIF v_address_type IS NULL THEN
        RAISE EXCEPTION 'v_address_type cannot be NULL';
    ELSIF v_affiliation_id IS NULL THEN
        RAISE EXCEPTION 'v_affiliation_id cannot be NULL';
    END IF;

    IF v_address_type NOT IN ('mailing', 'physical') THEN
        RAISE EXCEPTION 'Address type must be either "mailing" or "physical". Received %s.', v_address_type;
    END IF;

    -- Check the number of distinct addresses between the affiliation and the
    -- person.
    EXECUTE FORMAT(
        'WITH membership_addresses AS ( '
            'SELECT DISTINCT street_line_1, street_line_2, csz_id '
            'FROM membership '
            'INNER JOIN affiliation_person USING (affiliation_id) '
            'INNER JOIN %I USING (person_id) '
            'WHERE affiliation = $1'
        '), '
        'new_person_address AS ( '
            'SELECT street_line_1, street_line_2, csz_id '
            'FROM %I '
            'WHERE person_id = $2 '
        ') '
        'SELECT COUNT(*) '
        'FROM ( '
            '( '
                'SELECT * FROM membership_physical_addresses '
                'EXCEPT '
                'SELECT * FROM new_person_address '
            ') '
            'UNION '
            '( '
                'SELECT * FROM new_person_address '
                'EXCEPT '
                'SELECT * FROM membership_physical_addresses '
            ') '
        ') AS unique_addresses ',
        v_table_name,
        v_table_name
    )
    INTO v_num_unique_addresses
    USING v_affiliation_id, v_person_id;

    IF v_num_unique_addresses <= 1 THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION affiliation_is_membership(
    v_affiliation_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_affiliation_id IS NULL THEN
        RAISE EXCEPTION 'v_affiliation_id cannot be NULL';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM membership
        WHERE affiliation_id = v_affiliation_id
    ) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_affiliation_person_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Make sure the person's address is compatible with the affiliation's
    IF NOT person_address_suitable_for_affiliation(NEW.person_id, NEW.affiliation_id) THEN
        RAISE EXCEPTION 'Cannot add this person to this affiiation because one or more of the person''s addresses did not match those of the affiliation.';
    END IF;

    -- Make sure the affiliation can fit another person
    IF NOT affiliation_can_fit_another_person(NEW.affilation_id) THEN
        RAISE EXCEPTION 'This affiliation cannot accommodate another person because it''s membership limit has been reached.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_affiliation_person_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Make sure the person's address is compatible with the affiliation's
    IF NOT person_address_suitable_for_affiliation(NEW.person_id, NEW.affiliation_id) THEN
        RAISE EXCEPTION 'Cannot add this person to this affiiation because one or more of the person''s addresses did not match those of the affiliation.';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_affiliation_person_insert
BEFORE INSERT ON affiliation_person
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.person_id IS NOT NULL
)
EXECUTE PROCEDURE validate_affiliation_person_insert();

CREATE TRIGGER check_affiliation_person_update
BEFORE UPDATE ON affiliation_person
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.person_id IS NOT NULL
)
EXECUTE PROCEDURE validate_affiliation_person_update();

CREATE FUNCTION donation_is_membership_donation_for_affiliation (
    v_donation_type donation_type,
    v_affiliation_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_donation_type IS NULL THEN
        RAISE EXCEPTION 'v_donation_type cannot be NULL';
    ELSIF v_affiliation_id IS NULL THEN
        RAISE EXCEPTION 'v_affiliation_id cannot be NULL';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM affiliation
        INNER JOIN membership_donation_type USING (affiliation_year)
        WHERE affiliation_id = v_affiliation_id
        AND donation_type = v_donation_type
    ) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_donation_insert()
RETURNS TRIGGER AS $$
DECLARE
    v_expected_donation_amount DECIMAL(11,2) DEFAULT NULL;
    v_maximum_members SMALLINT DEFAULT NULL;
    v_donation_name_readable TEXT := REPLACE(NEW.donation_type, '_', ' ');
BEGIN
    IF NOT donation_is_membership_donation_for_affiliation(NEW.donation_type, NEW.affiliation_id) THEN
        RETURN NEW;
    END IF;

    -- The affiliation can have only one membership donation at a time
    IF affiliation_is_membership(NEW.affilation_id) THEN
        RAISE EXCEPTION 'Cannot add this donation because the affiliation already has an existing membership donation.';
    END IF;

    -- Verify new membership parameters
    SELECT membership_amount, membership_max_people
    INTO v_expected_donation_amount, v_maximum_members
    FROM affiliation
    INNER JOIN membership_donation_type USING (affiliation_year)
    WHERE affiliation_id = NEW.affiliation_id
    AND donation_type = NEW.donation_type;

    -- The membership donation should be the correct amount
    IF v_expected_donation_amount <> NEW.amount THEN
        RAISE EXCEPTION 'Since the donation is for a %s, it must be exactly $%.2f. If the actual donation was larger, add an additional "general donation" for the difference.', v_donation_name_readable, v_expected_donation_amount;
    END IF;

    -- The affiliation should have a suitable number of people
    IF v_maximum_members > (
            SELECT COUNT(*)
            FROM affiliation_person
            WHERE affiliation_id = NEW.affiliation_id
    ) THEN
        RAISE EXCEPTION 'There are too many people in the affiliation to add a %s.', v_donation_name_readable;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_donation_insert
BEFORE INSERT OR UPDATE ON donation
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.donation_type IS NOT NULL
    AND NEW.amount IS NOT NULL
)
EXECUTE PROCEDURE validate_donation_insert();

CREATE OR REPLACE FUNCTION validate_donation_update()
RETURNS TRIGGER AS $$
DECLARE
    v_expected_donation_amount DECIMAL(11,2) DEFAULT NULL;
    v_maximum_members SMALLINT DEFAULT NULL;
    v_donation_name_readable TEXT := REPLACE(NEW.donation_type, '_', ' ');
    v_donation_is_for_membership BOOLEAN DEFAULT NULL;
BEGIN
    -- Donation updates shouldn't move them to a new affiliation
    IF OLD.affilation_id <> NEW.affiliation_id THEN
        RAISE EXCEPTION 'Cannot move a donation from one affiliation to another. Rather, delete this donation and create a new one on the affiliation that needs one.';
    END IF;

    SELECT donation_is_membership_donation_for_affiliation(NEW.donation_type, NEW.affiliation_id)
    INTO v_donation_is_for_membership;

    -- Check we're not doubling the membership donations
    IF NOT donation_is_membership_donation_for_affiliation(OLD.donation_type, NEW.affiliation_id)
        AND v_donation_is_for_membership
        AND affiliation_is_membership(NEW.affiliation_id) THEN
        RAISE EXCEPTION 'Cannot change this donation to a membership donation because the affiliation already has a membership donation.';
    END IF;

    -- Retrieve the expected membership parameters
    SELECT membership_amount, membership_max_people
    INTO v_expected_donation_amount, v_maximum_members
    FROM membership_donation_type
    INNER JOIN affiliation USING (affiliation_year)
    WHERE donation_type = NEW.donation_type
    AND affiliation_id = NEW.affiliation_id;

    IF OLD.donation_type <> NEW.donation_type
        AND v_donation_is_for_membership THEN

        -- The donation amount must match the expected amount
        IF NEW.amount <> v_expected_donation_amount THEN
            RAISE EXCEPTION 'Since the donation is for a %s, it must be exactly $%.2f. If the funds received was larger, add an additional "general donation" for the difference.', v_donation_name_readable, v_expected_donation_amount;
        END IF;

        -- The affiliation should have a suitable number of people
        IF OLD.donation_type <> NEW.donation_type THEN
            IF v_maximum_members > (
                SELECT COUNT(*)
                FROM affiliation_person
                WHERE affiliation_id = NEW.affiliation_id
            ) THEN
                RAISE EXCEPTION 'There are too many people in the membership to switch to a %s.', v_donation_name_readable;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_donation_update
BEFORE INSERT OR UPDATE ON donation
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.donation_type IS NOT NULL
    AND NEW.amount IS NOT NULL
)
EXECUTE PROCEDURE validate_donation_update();

CREATE TABLE affiliation_year_voter_registration (
    affiliation_year SMALLINT NOT NULL REFERENCES affiliation_year (affiliation_year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (affiliation_year, person_id)
);

CREATE INDEX affiliation_year_voter_registration__person_id ON affiliation_year_voter_registration (person_id);

CREATE TABLE app_user (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(32) NOT NULL
        CONSTRAINT username_is_unique UNIQUE
        CONSTRAINT username_is_trimmed_and_not_empty CHECK (username <> '' AND username = trim(both from username)),
    password_hash bytea NOT NULL CHECK(length(password_hash) = 64),
    first_name VARCHAR(32) NOT NULL
        CONSTRAINT first_name_is_trimmed_and_not_empty CHECK (first_name <> '' AND first_name = trim(both from first_name)),
    last_name VARCHAR(32) NOT NULL
        CONSTRAINT last_name_is_trimmed_and_not_empty CHECK (last_name <> '' AND last_name = trim(both from last_name)),
    login_enabled boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE app_role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(64) NOT NULL
        CONSTRAINT app_role_name_is_unique UNIQUE
        CONSTRAINT app_role_name_is_trimmed_and_not_empty CHECK (role_name <> '' AND role_name = trim(both from role_name)),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE app_user_has_role (
    user_id INTEGER NOT NULL REFERENCES app_user (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    role_id INTEGER NOT NULL REFERENCES app_role (role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

CREATE INDEX app_user_has_role__role_id ON app_user_has_role (role_id);

CREATE TABLE app_privilege (
    privilege_id SERIAL PRIMARY KEY,
    privilege_name VARCHAR(64) NOT NULL
        CONSTRAINT app_privilege_name_is_unique UNIQUE
        CONSTRAINT app_privilege_name_is_trimmed_and_not_empty CHECK (privilege_name <> '' AND privilege_name = trim(both from privilege_name)),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE app_role_has_privilege (
    role_id INTEGER NOT NULL REFERENCES app_role (role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    privilege_id INTEGER NOT NULL REFERENCES app_privilege (privilege_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (role_id, privilege_id)
);

CREATE INDEX app_role_has_privilege__privilege_id ON app_role_has_privilege (privilege_id);

-- CREATE VIEW person_finder AS
-- SELECT
    -- person_id,
    -- first_name,
    -- last_name,
    -- phone_number,
    -- email_address,
    -- pa.street_line_1 AS pa_street_line_1,
    -- pa.street_line_2 AS pa_street_line_2,
    -- pa.city AS pa_city,
    -- pa.state_abbr AS pa_state_abbr,
    -- pa.state_name AS pa_state_name,
    -- pa.zip AS pa_zip,
    -- ma.street_line_1 AS ma_street_line_1,
    -- ma.street_line_2 AS ma_street_line_2,
    -- ma.city AS ma_city,
    -- ma.state_abbr AS ma_state_abbr,
    -- ma.state_name AS ma_state_name,
    -- ma.zip AS ma_zip
-- FROM person
-- LEFT JOIN person_phone USING (person_id)
-- LEFT JOIN person_email USING (person_id)
-- LEFT JOIN affiliation USING (affiliation_id)
-- LEFT JOIN physical_address pa USING (affiliation_id)
-- LEFT JOIN mailing_address ma USING (affiliation_id);

-- SELECT
    -- person_id,
    -- CASE WHEN first_name LIKE '%?%' THEN 10 ELSE 0
        -- + CASE WHEN last_name LIKE '%?%' THEN 10 ELSE 0
        -- + CASE WHEN email_address LIKE '%?%' THEN 10 ELSE 0
        -- + CASE WHEN pa_street_line_1 LIKE '%?%' THEN 3 ELSE 0
        -- + CASE WHEN pa_street_line_2 LIKE '%?%' THEN 3 ELSE 0
        -- + CASE WHEN pa_city LIKE '%?%' THEN 2 ELSE 0
        -- + CASE WHEN pa_state_abbr LIKE '%?%' THEN 1 ELSE 0
        -- + CASE WHEN pa_state_name LIKE '%?%' THEN 1 ELSE 0
        -- + CASE WHEN ma_street_line_1 LIKE '%?%' THEN 3 ELSE 0
        -- + CASE WHEN ma_street_line_2 LIKE '%?%' THEN 3 ELSE 0
        -- + CASE WHEN ma_city LIKE '%?%' THEN 2 ELSE 0
        -- + CASE WHEN ma_state_abbr LIKE '%?%' THEN 1 ELSE 0
        -- + CASE WHEN ma_state_name LIKE '%?%' THEN 1 ELSE 0
        -- + CASE WHEN phone_number LIKE '%?%' THEN 10 ELSE 0
        -- + CASE WHEN pa_zip LIKE '%?%' THEN 2 ELSE 0
        -- + CASE WHEN ma_zip LIKE '%?%' THEN 2 ELSE 0
-- FROM person_finder
-- WHERE first_name LIKE '%?%'
-- OR last_name LIKE '%?%'
-- OR phone_number LIKE '%?%'
-- OR email_address LIKE '%?%'
-- OR pa_street_line_1 LIKE '%?%'
-- OR pa_street_line_2 LIKE '%?%'
-- OR pa_city LIKE '%?%'
-- OR pa_state_abbr LIKE '%?%'
-- OR pa_state_name LIKE '%?%'
-- OR pa_zip LIKE '%?%'
-- OR ma_street_line_1 LIKE '%?%'
-- OR ma_street_line_2 LIKE '%?%'
-- OR ma_city LIKE '%?%'
-- OR ma_state_abbr LIKE '%?%'
-- OR ma_state_name LIKE '%?%'
-- OR ma_zip LIKE '%?%';
