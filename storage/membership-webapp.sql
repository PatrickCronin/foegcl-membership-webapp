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
    source_friend_id NUMERIC(11) NOT NULL,
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

-- Convenience view. Is this still needed?
CREATE VIEW address AS
SELECT person_id, 'physical' AS address_type, street_line_1, street_line_2, csz_id, plus_four
FROM physical_address
UNION ALL
SELECT person_id, 'mailing' AS address_type, street_line_1, street_line_2, csz_id, plus_four
FROM mailing_address;

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

CREATE TABLE membership_year (
    membership_year SMALLINT PRIMARY KEY
        CONSTRAINT membership_year_is_reasonable CHECK (membership_year >= 1980 AND membership_year <= 2079),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

INSERT INTO membership_year (membership_year)
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
    membership_year SMALLINT NOT NULL REFERENCES membership_year (membership_year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    participation_role_id INTEGER NOT NULL REFERENCES participation_role (participation_role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (membership_year, person_id, participation_role_id)
);

CREATE INDEX participation_record__person_id ON participation_record (person_id);
CREATE INDEX participation_record__participation_role_id ON participation_record (person_id);

CREATE TYPE membership_type AS ENUM ('individual_membership', 'household_membership');

CREATE TABLE membership (
    membership_id SERIAL PRIMARY KEY,
    membership_year SMALLINT NOT NULL REFERENCES membership_year (membership_year) ON DELETE CASCADE ON UPDATE CASCADE,
    membership_type membership_type NULL,
    friend_id NUMERIC(11) NOT NULL,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

COMMENT ON COLUMN membership.friend_id IS 'This value should follow a renewed membership. Otherwise, a new one should be assigned.';

CREATE UNIQUE INDEX membership__membership_year__friend_id ON membership (membership_year, friend_id);
CREATE INDEX membership__membership_type ON membership (membership_type);
CREATE INDEX membership__friend_id ON membership (friend_id);

CREATE OR REPLACE FUNCTION next_friend_id()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.friend_id IS NULL THEN
        NEW.friend_id = (SELECT MAX(friend_id) + 1 FROM membership);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER membership__next_friend_id
BEFORE INSERT OR UPDATE ON membership
FOR EACH ROW
EXECUTE PROCEDURE next_friend_id();

CREATE TABLE membership_person (
    membership_id INTEGER NOT NULL REFERENCES membership (membership_id) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (membership_id, person_id)
);

CREATE INDEX membership_person__person_id ON membership_person (person_id);

CREATE TABLE annual_membership_parameters (
    membership_year SMALLINT NOT NULL REFERENCES membership_year (membership_year) ON DELETE CASCADE ON UPDATE CASCADE,
    membership_type membership_type NOT NULL,
    membership_max_people SMALLINT DEFAULT 1
        CONSTRAINT max_people_is_greater_than_zero CHECK (membership_max_people > 0),
    membership_amount NUMERIC(11,2) NOT NULL
        CONSTRAINT membership_amount_is_not_negative CHECK (membership_amount >= 0),
    PRIMARY KEY (membership_year, membership_type)
);

INSERT INTO annual_membership_parameters
(membership_year, membership_type, membership_max_people, membership_amount)
VALUES
    (2011, 'individual_membership', 1, 10),
    (2011, 'household_membership', 2, 20),
    (2012, 'individual_membership', 1, 10),
    (2012, 'household_membership', 2, 20),
    (2013, 'individual_membership', 1, 10),
    (2013, 'household_membership', 2, 20),
    (2014, 'individual_membership', 1, 10),
    (2014, 'household_membership', 2, 20),
    (2015, 'individual_membership', 1, 10),
    (2015, 'household_membership', 2, 20),
    (2016, 'individual_membership', 1, 10),
    (2016, 'household_membership', 2, 20),
    (2017, 'individual_membership', 1, 15),
    (2017, 'household_membership', 2, 25),
    (2018, 'individual_membership', 1, 15),
    (2018, 'household_membership', 2, 25);

CREATE TABLE donation (
    donation_id SERIAL PRIMARY KEY,
    membership_id INTEGER NOT NULL REFERENCES membership (membership_id) ON DELETE CASCADE ON UPDATE CASCADE,
    amount NUMERIC(11,2) NOT NULL
        CONSTRAINT amount_is_not_negative CHECK (amount >= 0),
    notes VARCHAR(128)
        CONSTRAINT notes_is_null_or_trimmed_and_not_empty CHECK (notes IS NULL OR (notes <> '' AND notes = trim(both from notes))),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX donation__membership_id ON donation (membership_id);

CREATE FUNCTION person_is_in_current_membership(
    v_person_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'v_person_id cannot be NULL';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM membership_person
        INNER JOIN membership USING (membership_id)
        WHERE person_id = v_person_id
        AND membership_year = date_part('year', CURRENT_DATE)
    ) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_address_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF person_is_in_current_membership(NEW.person_id) THEN
        RAISE EXCEPTION 'Cannot add an address to a person in an membership. Change the membership''s address instead.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_address_update()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.person_id <> NEW.person_id THEN
        RAISE EXCEPTION 'Cannot reassign a person''s address to another person. Delete this address and create a new one.';
    END IF;

    IF person_is_in_current_membership(NEW.person_id) THEN
        RAISE EXCEPTION 'Cannot update the address of a person in an membership. Change the membership''s address instead.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_address_delete()
RETURNS TRIGGER AS
$$
BEGIN
    IF person_is_in_current_membership(NEW.person_id) THEN
        IF TG_TABLE_NAME = 'physical_address' THEN
            RAISE EXCEPTION 'Cannot delete the physical address of a person in an membership.';
        ELSIF TG_TABLE_NAME = 'mailing_address' THEN
            RAISE EXCEPTION 'Cannot delete the mailing address of a person in an membership. Please delete the mailing address of the person''s membership instead.';
        END IF;
    END IF;

    RETURN OLD;
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
BEFORE DELETE ON mailing_address
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
BEFORE DELETE ON physical_address
FOR EACH ROW
EXECUTE PROCEDURE validate_address_delete();

CREATE FUNCTION clear_library_special_voting_district_on_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.in_library_special_voting_district IS NULL THEN
        NEW.in_library_special_voting_district = 'unchecked';
    END IF;

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

CREATE FUNCTION validate_donation_update()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.membership_id <> NEW.membership_id THEN
        RAISE EXCEPTION 'You cannot move a donation from one membership to another.';
    END IF;

    IF (
        SELECT membership_amount
        FROM membership
        INNER JOIN annual_membership_parameters USING (membership_year, membership_type)
        WHERE membership_id = NEW.membership_id
    ) > (
        SELECT SUM(amount) - OLD.amount + NEW.amount
        FROM donation
        WHERE membership_id = NEW.membership_id
    ) THEN
        RAISE EXCEPTION 'This update is prohibited because it would make the membership''s total donation amount less than what''s required for its current membership type.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_donation_update
BEFORE DELETE ON donation
FOR EACH ROW
WHEN (
    OLD.membership_id IS NOT NULL
    AND OLD.amount IS NOT NULL
)
EXECUTE PROCEDURE validate_donation_update();

CREATE FUNCTION validate_donation_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT membership_amount
        FROM membership
        INNER JOIN annual_membership_parameters USING (membership_year, membership_type)
        WHERE membership_id = OLD.membership_id
    ) > (
        SELECT SUM(amount) - OLD.amount
        FROM donation
        WHERE membership_id = OLD.membership_id
    ) THEN
        RAISE EXCEPTION 'This delete is prohibited because it would make the membership''s total donation amount less than what''s required for its current membership type.';
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_donation_delete
BEFORE DELETE ON donation
FOR EACH ROW
WHEN (
    OLD.membership_id IS NOT NULL
)
EXECUTE PROCEDURE validate_donation_delete();

CREATE FUNCTION validate_membership_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.membership_type IS NULL AND (
        SELECT COUNT(*) num_membership_members
        FROM membership_person
        WHERE membership_id = NEW.membership_id
    ) > 0 THEN
        RAISE EXCEPTION 'This change is prohibited because it would result in too many members for the membership type.';
    END IF;

    IF NEW.membership_type IS NOT NULL AND (
        SELECT membership_amount
        FROM annual_membership_parameters
        WHERE membership_year = NEW.membership_year
        AND membership_type = NEW.membership_type
    ) < (
        SELECT COUNT(*) membership_donation_sum
        FROM donations
        WHERE membership_id = NEW.membership_id
    ) THEN
        RAISE EXCEPTION 'This change is prohibited because the total donation sum is not sufficient to support the selected membership type.';
    END IF;

    IF NEW.membership_type IS NOT NULL AND (
        SELECT membership_max_people
        FROM annual_membership_parameters
        WHERE membership_year = NEW.membership_year
        AND membership_type = NEW.membership_type
    ) < (
        SELECT COUNT(*) num_membership_members
        FROM membership_person
        WHERE membership_id = NEW.membership_id
    ) THEN
        RAISE EXCEPTION 'This change is prohibited because it would result in too many members for the membership type.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_membership_update
BEFORE UPDATE ON membership
FOR EACH ROW
WHEN (
    NEW.membership_id IS NOT NULL
    AND NEW.membership_year IS NOT NULL
)
EXECUTE PROCEDURE validate_membership_update();

CREATE FUNCTION person_address_suitable_for_membership(
    v_person_id INTEGER,
    v_membership_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'v_person_id cannot be NULL';
    ELSIF v_membership_id IS NULL THEN
        RAISE EXCEPTION 'v_membership_id cannot be NULL';
    END IF;

    -- 1. All people in an membership must have the same physical address
    -- 2. All people in an membership must have the same mailing address (or
    --    all people may have no mailing address)
    IF EXISTS (
        SELECT 1
        FROM physical_address
        WHERE person_id = v_person_id
        )
        AND  person_address_matches_membership_address(v_person_id, 'physical', v_membership_id)
        AND person_address_matches_membership_address(v_person_id, 'mailing', v_membership_id)
        THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION person_address_matches_membership_address (
    v_person_id INTEGER,
    v_address_type TEXT,
    v_membership_id INTEGER
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
    ELSIF v_membership_id IS NULL THEN
        RAISE EXCEPTION 'v_membership_id cannot be NULL';
    END IF;

    IF v_address_type NOT IN ('mailing', 'physical') THEN
        RAISE EXCEPTION 'Address type must be either "mailing" or "physical". Received %s.', v_address_type;
    END IF;

    -- Check the number of distinct addresses between the membership and the
    -- person.
    -- OK 1: The membership has no current address, and the person being added has one
    -- OK 2: The membership has an address, and the person being added has the same
    EXECUTE FORMAT(
        'WITH membership_addresses AS ( '
            'SELECT DISTINCT street_line_1, street_line_2, csz_id '
            'FROM membership '
            'INNER JOIN membership_person USING (membership_id) '
            'INNER JOIN %I USING (person_id) '
            'WHERE membership_id = $1'
        '), '
        'new_person_address AS ( '
            'SELECT street_line_1, street_line_2, csz_id '
            'FROM %I '
            'WHERE person_id = $2 '
        ') '
        'SELECT street_line_1, street_line_2, csz_id '
        'FROM ( '
            'SELECT * FROM membership_addresses '
            'UNION '
            'SELECT * FROM new_person_address '
        ') AS unique_addresses ',
        v_table_name,
        v_table_name
    )
    INTO v_num_unique_addresses
    USING v_membership_id, v_person_id;

    IF v_num_unique_addresses <= 1 THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_membership_person_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT membership_type
        FROM membership
        WHERE membership_id = NEW.membership_id
    ) IS NULL THEN
        RAISE EXCEPTION 'Cannot add this person to this membership because the membership does not have a type.';
    END IF;

    -- Make sure the person's address is compatible with the membership's
    IF NOT person_address_suitable_for_membership(NEW.person_id, NEW.membership_id) THEN
        RAISE EXCEPTION 'Cannot add this person to this membership because one or more of the person''s addresses did not match those of the membership.';
    END IF;

    -- Make sure the membership can fit another person
    -- IF current_people + 1 > membership_max_people THEN WHAMO!
    IF (
        SELECT COUNT(*) num_members
        FROM membership_person
        WHERE membership_id = NEW.membership_id
    ) + 1 > (
        SELECT membership_max_people
        FROM membership
        INNER JOIN annual_membership_parameters USING (membership_year, membership_type)
        WHERE membership_id = NEW.membership_id
    ) THEN
        RAISE EXCEPTION 'This membership cannot accommodate another person because it has reached its membership limit.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_membership_person_insert
BEFORE INSERT ON membership_person
FOR EACH ROW
WHEN (
    NEW.membership_id IS NOT NULL
    AND NEW.person_id IS NOT NULL
)
EXECUTE PROCEDURE validate_membership_person_insert();

CREATE FUNCTION validate_membership_person_update()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Cannot update a membership person association. Try deleting and re-creating instead.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_membership_person_update
BEFORE UPDATE ON membership_person
FOR EACH ROW
WHEN (
    NEW.membership_id IS NOT NULL
    AND NEW.person_id IS NOT NULL
)
EXECUTE PROCEDURE validate_membership_person_update();

CREATE TABLE membership_year_voter_registration (
    membership_year SMALLINT NOT NULL REFERENCES membership_year (membership_year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (membership_year, person_id)
);

CREATE INDEX membership_year_voter_registration__person_id ON membership_year_voter_registration (person_id);

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

CREATE VIEW report_blast_email_list AS
SELECT DISTINCT email_address
FROM person
INNER JOIN person_email USING (person_id)
WHERE person_id IN (
    -- Anyone who was a member within the last two years
    SELECT person_id
    FROM membership_person
    INNER JOIN membership USING (membership_id)
    WHERE membership_year IN (
        date_part('year', CURRENT_DATE) - 1,
        date_part('year', CURRENT_DATE)
    )

    UNION ALL

    -- Anyone who has an active interest
    SELECT person_id
    FROM participation_interest

    UNION ALL

    -- Anyone who participated in something within the last two years
    SELECT person_id
    FROM participation_record
    WHERE membership_year IN (
        date_part('year', CURRENT_DATE) - 1,
        date_part('year', CURRENT_DATE)
    )
)
AND opted_out = false;

CREATE FUNCTION format_phone_number (phone_number VARCHAR(32))
RETURNS VARCHAR(32)
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT
AS $$
BEGIN
    IF phone_number SIMILAR TO '[0-9]{10}' THEN
        RETURN regexp_replace(phone_number, '^(\d{3})(\d{3})(\d{4})$', '(\1) \2-\3');
    ELSIF phone_number SIMILAR TO '[0-9]{7}' THEN
        RETURN regexp_replace(phone_number, '^(\d{3})(\d{4})$', '\1-\2');
    ELSE
        RETURN phone_number;
    END IF;
END;
$$;

CREATE VIEW report_current_membership_list AS
WITH member_person AS (
    SELECT person_id
    FROM person
    INNER JOIN membership_person USING (person_id)
    INNER JOIN membership USING (membership_id)
    WHERE membership_year = date_part('year', CURRENT_DATE)
),
aggregated_email AS (
    SELECT person_id, string_agg(email_address, E'\n' ORDER BY is_preferred DESC, email_address) emails
    FROM person_email
    INNER JOIN member_person USING (person_id)
    GROUP BY person_id
),
aggregated_phone AS (
    SELECT person_id, string_agg(phone_number, E'\n' ORDER BY is_preferred DESC, phone_number) phones
    FROM (
        SELECT person_id, is_preferred, format_phone_number(phone_number) AS phone_number
        FROM person_phone
        INNER JOIN member_person USING (person_id)
    ) person_formatted_phone
    GROUP BY person_id
)
SELECT
    last_name || ', ' || first_name AS name,
    COALESCE(street_line_1) || COALESCE( E'\n' || street_line_2, '') street_lines,
    city || ', ' || state_abbr || ' ' || zip || COALESCE( '-' || plus_four, '') csz,
    emails,
    phones
FROM person
INNER JOIN member_person USING (person_id)
LEFT JOIN physical_address USING (person_id)
LEFT JOIN city_state_zip USING (csz_id)
LEFT JOIN aggregated_email USING (person_id)
LEFT JOIN aggregated_phone USING (person_id)
ORDER BY last_name, first_name;

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
-- LEFT JOIN membership USING (membership_id)
-- LEFT JOIN physical_address pa USING (membership_id)
-- LEFT JOIN mailing_address ma USING (membership_id);

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
