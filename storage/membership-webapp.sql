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
    csz_id INTEGER NOT NULL REFERENCES city_state_zip (csz_id) ON DELETE RESTRICT ON UPDATE CASCADE,
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
    csz_id INTEGER NOT NULL REFERENCES city_state_zip (csz_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    plus_four CHAR(4) DEFAULT NULL
        CONSTRAINT physical_address_plus_four_is_null_or_five_digits CHECK (plus_four IS NULL OR plus_four ~ '^[0-9]{4}$'),
    in_library_special_voting_district library_special_voting_district_status NOT NULL DEFAULT 'unchecked'::library_special_voting_district_status,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX physical_address__street_line_1__gin_trgm_idx ON physical_address USING gin (street_line_1 gin_trgm_ops);
CREATE INDEX physical_address__street_line_2__gin_trgm_idx ON physical_address USING gin (street_line_2 gin_trgm_ops);

CREATE TABLE participation_role (
    participation_role_id SERIAL PRIMARY KEY,
    parent_role_id INTEGER REFERENCES participation_role (participation_role_id) ON DELETE RESTRICT ON UPDATE CASCADE,
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
    participation_role_id INTEGER NOT NULL REFERENCES participation_role (participation_role_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, participation_role_id)
);

CREATE INDEX participation_interest__participation_role_id ON participation_interest (participation_role_id);

CREATE TABLE affiliation_year (
    year SMALLINT PRIMARY KEY
        CONSTRAINT year_is_reasonable CHECK (year >= 1980 AND year <= 2079),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

INSERT INTO affiliation_year (year)
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
    year SMALLINT NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    participation_role_id INTEGER NOT NULL REFERENCES participation_role (participation_role_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (year, person_id, participation_role_id)
);

CREATE INDEX participation_record__person_id ON participation_record (person_id);
CREATE INDEX participation_record__participation_role_id ON participation_record (person_id);

CREATE TYPE membership_type AS ENUM ('individual_membership', 'household_membership');

CREATE TABLE membership_type_parameters (
    year SMALLINT NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    membership_type membership_type NOT NULL,
    membership_max_people SMALLINT DEFAULT 1
        CONSTRAINT max_people_is_greater_than_zero CHECK (membership_max_people > 0),
    membership_amount NUMERIC(11,2) NOT NULL
        CONSTRAINT membership_amount_is_not_negative CHECK (membership_amount >= 0),
    PRIMARY KEY (year, membership_type)
);

INSERT INTO membership_type_parameters
(year, membership_type, membership_max_people, membership_amount)
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

CREATE TABLE affiliation (
    affiliation_id SERIAL PRIMARY KEY,
    year SMALLINT NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    membership_type membership_type NULL,
    friend_id NUMERIC(11) NOT NULL,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    FOREIGN KEY (year, membership_type) REFERENCES membership_type_parameters (year, membership_type) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON COLUMN affiliation.friend_id IS 'This value should follow a renewed affiliation. Otherwise, a new one should be assigned.';

CREATE UNIQUE INDEX affiliation__year__friend_id ON affiliation (year, friend_id);
CREATE INDEX affiliation__membership_type ON affiliation (membership_type);
CREATE INDEX affiliation__friend_id ON affiliation (friend_id);

CREATE OR REPLACE FUNCTION next_friend_id()
    RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.friend_id IS NULL THEN
        NEW.friend_id = (SELECT COALESCE(MAX(friend_id), 0) + 1 FROM affiliation);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER affiliation__next_friend_id
BEFORE INSERT OR UPDATE ON affiliation
FOR EACH ROW
EXECUTE PROCEDURE next_friend_id();

CREATE VIEW membership AS
SELECT * FROM affiliation WHERE membership_TYPE IS NOT NULL;

CREATE TABLE affiliation_person (
    affiliation_id INTEGER NOT NULL REFERENCES affiliation (affiliation_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (affiliation_id, person_id)
);

CREATE INDEX affiliation_person__person_id ON affiliation_person (person_id);

CREATE TABLE contribution (
    contribution_id SERIAL PRIMARY KEY,
    affiliation_id INTEGER NOT NULL REFERENCES affiliation (affiliation_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    amount NUMERIC(11,2) NOT NULL
        CONSTRAINT amount_is_not_negative CHECK (amount >= 0),
    notes VARCHAR(128)
        CONSTRAINT notes_is_null_or_trimmed_and_not_empty CHECK (notes IS NULL OR (notes <> '' AND notes = trim(both from notes))),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX contribution__affiliation_id ON contribution (affiliation_id);

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
        WHERE person_id = v_person_id
        AND year = date_part('year', CURRENT_DATE)
    ) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION person_is_in_current_affiliation (INTEGER) IS 'Check if a person is associated with an affiliation in the current year.';

CREATE FUNCTION validate_address_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF person_is_in_current_affiliation(NEW.person_id) THEN
        RAISE EXCEPTION 'Cannot add an address to a person in an affiliation. Change the affiliation''s address instead.';
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

    IF person_is_in_current_affiliation(NEW.person_id) THEN
        RAISE EXCEPTION 'Cannot update the address of a person in an affiliation. Change the affiliation''s address instead.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION validate_address_delete()
RETURNS TRIGGER AS
$$
BEGIN
    IF person_is_in_current_affiliation(NEW.person_id) THEN
        IF TG_TABLE_NAME = 'physical_address' THEN
            RAISE EXCEPTION 'Cannot delete the physical address of a person in an affiliation.';
        ELSIF TG_TABLE_NAME = 'mailing_address' THEN
            RAISE EXCEPTION 'Cannot delete the mailing address of a person in an affiliation. Please delete the mailing address of the person''s affiliation instead.';
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

CREATE FUNCTION clear_library_special_voting_district_on_update_step1()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.in_library_special_voting_district = NEW.in_library_special_voting_district THEN
        NEW.in_library_special_voting_district = NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION clear_library_special_voting_district_on_update_step2()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.in_library_special_voting_district IS NULL THEN
        NEW.in_library_special_voting_district = OLD.in_library_special_voting_district;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION clear_library_special_voting_district_on_update_step3()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.in_library_special_voting_district IS NULL THEN
        NEW.in_library_special_voting_district = 'unchecked';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clear_library_special_voting_district_status_step1
BEFORE UPDATE ON physical_address
FOR EACH ROW
WHEN (
    OLD.street_line_1 <> NEW.street_line_1
    OR OLD.street_line_2 IS DISTINCT FROM NEW.street_line_2
    OR OLD.csz_id <> NEW.csz_id
)
EXECUTE PROCEDURE clear_library_special_voting_district_on_update_step1();

CREATE TRIGGER clear_library_special_voting_district_status_step2
BEFORE UPDATE OF in_library_special_voting_district ON physical_address
FOR EACH ROW
WHEN (
    OLD.street_line_1 <> NEW.street_line_1
    OR OLD.street_line_2 IS DISTINCT FROM NEW.street_line_2
    OR OLD.csz_id <> NEW.csz_id
)
EXECUTE PROCEDURE clear_library_special_voting_district_on_update_step2();

CREATE TRIGGER clear_library_special_voting_district_status_step3
BEFORE UPDATE ON physical_address
FOR EACH ROW
WHEN (
    OLD.street_line_1 <> NEW.street_line_1
    OR OLD.street_line_2 IS DISTINCT FROM NEW.street_line_2
    OR OLD.csz_id <> NEW.csz_id
)
EXECUTE PROCEDURE clear_library_special_voting_district_on_update_step3();

CREATE FUNCTION validate_contribution_update()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.affiliation_id <> NEW.affiliation_id THEN
        RAISE EXCEPTION 'You cannot move a contribution from one affiliation to another.';
    END IF;

    IF (
        SELECT membership_amount
        FROM affiliation
        INNER JOIN membership_type_parameters USING (year, membership_type)
        WHERE affiliation_id = NEW.affiliation_id
    ) > (
        SELECT COALESCE(SUM(amount), 0) - OLD.amount + NEW.amount
        FROM contribution
        WHERE affiliation_id = NEW.affiliation_id
    ) THEN
        RAISE EXCEPTION 'This update is prohibited because it would make the affiliation''s total contribution amount less than what''s required for its current membership type.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_contribution_update
BEFORE UPDATE ON contribution
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.amount IS NOT NULL
)
EXECUTE PROCEDURE validate_contribution_update();

CREATE FUNCTION validate_contribution_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT membership_amount
        FROM affiliation
        INNER JOIN membership_type_parameters USING (year, membership_type)
        WHERE affiliation_id = OLD.affiliation_id
    ) > (
        SELECT COALESCE(SUM(amount), 0) - OLD.amount
        FROM contribution
        WHERE affiliation_id = OLD.affiliation_id
    ) THEN
        RAISE EXCEPTION 'This delete is prohibited because it would make the affiliation''s total contribution amount less than what''s required for its current membership type.';
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_contribution_delete
BEFORE DELETE ON contribution
FOR EACH ROW
EXECUTE PROCEDURE validate_contribution_delete();

CREATE FUNCTION validate_affiliation_insert()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'You cannot create an affiliation with a NOT NULL membership type. It will not have requisite contributions at the time of creation.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_affiliation_insert
BEFORE INSERT ON affiliation
FOR EACH ROW
WHEN ( NEW.membership_type IS NOT NULL )
EXECUTE PROCEDURE validate_affiliation_insert();

CREATE FUNCTION validate_affiliation_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Check the membership contribution sum
    IF NEW.membership_type IS NOT NULL AND (
        SELECT membership_amount
        FROM membership_type_parameters
        WHERE year = NEW.year
        AND membership_type = NEW.membership_type
    ) > (
        SELECT COALESCE(SUM(amount), 0) affiliation_contribution_sum
        FROM contribution
        WHERE affiliation_id = NEW.affiliation_id
    ) THEN
        RAISE EXCEPTION 'This change is prohibited because the total contribution sum is not sufficient to support the affiliation''s new membership type.';
    END IF;

    -- Check the membership max person limit
    IF NEW.membership_type IS NOT NULL AND (
        SELECT membership_max_people
        FROM membership_type_parameters
        WHERE year = NEW.year
        AND membership_type = NEW.membership_type
    ) < (
        SELECT COUNT(*) num_affiliation_members
        FROM affiliation_person
        WHERE affiliation_id = NEW.affiliation_id
    ) THEN
        RAISE EXCEPTION 'This change is prohibited because it would result in too many members for the affiliation''s new membership type.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_affiliation_update
BEFORE UPDATE ON affiliation
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.year IS NOT NULL
)
EXECUTE PROCEDURE validate_affiliation_update();

CREATE FUNCTION person_address_suitable_for_affiliation(
    v_person_id INTEGER,
    v_affiliation_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'v_person_id cannot be NULL';
    ELSIF v_affiliation_id IS NULL THEN
        RAISE EXCEPTION 'v_affiliation_id cannot be NULL';
    END IF;

    -- 1. All people in an affiliation must have the same physical address (
    --    or all people may have no physical address)
    -- 2. All people in an membership must have the same mailing address (or
    --    all people may have no mailing address)
    IF person_address_matches_affiliation_address(v_person_id, 'physical', v_affiliation_id)
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

    -- If the affiliation has an address (being the address of current
    -- membership), then then person being added must have the same address.
    -- If the affiliation has no address (meaning existing membership have
    -- no address), the person being added may or may not have an address.
    EXECUTE FORMAT(
        'WITH affiliation_addresses AS ( '
            'SELECT DISTINCT street_line_1, street_line_2, csz_id '
            'FROM affiliation '
            'INNER JOIN affiliation_person USING (affiliation_id) '
            'INNER JOIN %I USING (person_id) '
            'WHERE affiliation_id = $1'
        '), '
        'new_person_address AS ( '
            'SELECT street_line_1, street_line_2, csz_id '
            'FROM %I '
            'WHERE person_id = $2 '
        ') '
        'SELECT COUNT(*) '
        'FROM ( '
            'SELECT * FROM affiliation_addresses '
            'UNION '
            'SELECT * FROM new_person_address '
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

CREATE FUNCTION validate_affiliation_person_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Make sure the person's address is compatible with the affiliation's
    IF NOT person_address_suitable_for_affiliation(NEW.person_id, NEW.affiliation_id) THEN
        RAISE EXCEPTION 'Cannot add this person to this affiliation because one or more of the person''s addresses did not match those of the affiliation.';
    END IF;

    -- Make sure the affiliation can fit another person
    -- IF current_people + 1 > membership_max_people THEN WHAMO!
    IF (
        SELECT COUNT(*) num_members
        FROM affiliation_person
        WHERE affiliation_id = NEW.affiliation_id
    ) >= (
        SELECT membership_max_people
        FROM affiliation
        INNER JOIN membership_type_parameters USING (year, membership_type)
        WHERE affiliation_id = NEW.affiliation_id
    ) THEN
        RAISE EXCEPTION 'This affiliation cannot accommodate another person because it has reached its maximum person limit.';
    END IF;

    RETURN NEW;
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

CREATE FUNCTION validate_affiliation_person_update()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Cannot update an affiliation person association. Try deleting and re-creating instead.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_affiliation_person_update
BEFORE UPDATE ON affiliation_person
FOR EACH ROW
WHEN (
    NEW.affiliation_id IS NOT NULL
    AND NEW.person_id IS NOT NULL
)
EXECUTE PROCEDURE validate_affiliation_person_update();

CREATE TABLE voter_registration (
    year SMALLINT NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (year, person_id)
);

CREATE INDEX voter_registration__person_id ON voter_registration (person_id);

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
    -- Anyone who was connected with a contributing affiliation within the
    -- last two years
    SELECT person_id
    FROM affiliation_person
    INNER JOIN affiliation USING (affiliation_id)
    INNER JOIN contribution USING (affiliation_id)
    WHERE year IN (
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
    WHERE year IN (
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
    INNER JOIN affiliation_person USING (person_id)
    INNER JOIN membership USING (affiliation_id)
    WHERE year = date_part('year', CURRENT_DATE)
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

CREATE VIEW report_contributing_friends_annual_friend_contribution_agg AS
SELECT
    year,
    friend_id,
    COALESCE(SUM(amount), 0) AS "Total Contributed",
    COALESCE(membership_amount, 0) AS "Of that, Membership",
    COALESCE(SUM(amount), 0) - COALESCE(membership_amount, 0) AS "Additional Donations",
    COUNT(amount) AS "Number of Contributions"
FROM contribution
INNER JOIN affiliation USING (affiliation_id)
LEFT JOIN membership_type_parameters USING (year, membership_type)
GROUP BY year, friend_id, membership_amount;

CREATE VIEW report_contributing_friends_earliest_friend_contributions AS
SELECT friend_id, min(year) AS first_contribution_year
FROM affiliation
INNER JOIN contribution USING (affiliation_id)
GROUP BY friend_id;

CREATE VIEW report_contributing_friends_renewees AS
SELECT
    base_year.year AS year,
    base_year.friend_id AS renewee_friend_id
FROM report_contributing_friends_annual_friend_contribution_agg AS base_year
INNER JOIN report_contributing_friends_annual_friend_contribution_agg AS last_year
ON base_year.friend_id = last_year.friend_id
AND base_year.year - 1 = last_year.year;

CREATE VIEW report_contributing_friends_refreshees AS
SELECT
    base_year.year AS year,
    base_year.friend_id refreshee_friend_id
FROM report_contributing_friends_annual_friend_contribution_agg AS base_year
INNER JOIN report_contributing_friends_earliest_friend_contributions
    ON base_year.friend_id = report_contributing_friends_earliest_friend_contributions.friend_id
    AND base_year.year > first_contribution_year
LEFT JOIN report_contributing_friends_annual_friend_contribution_agg AS last_year
ON base_year.friend_id = last_year.friend_id
AND base_year.year - 1 = last_year.year
WHERE last_year.year IS NULL;

CREATE VIEW report_contributing_friends AS
SELECT
    year,
    "Contributing Friends",
    "Renewees",
    "Refreshees",
    "First Timers",
    "Total Contributed",
    "Of that, Membership",
    "Additional Donations",
    "Number of Contributions"
FROM affiliation_year
LEFT JOIN (
    SELECT
        year,
        COUNT(*) "Contributing Friends",
        COALESCE(SUM("Total Contributed"), 0) AS "Total Contributed",
        COALESCE(SUM("Of that, Membership"), 0) AS "Of that, Membership",
        COALESCE(SUM("Additional Donations"), 0) AS "Additional Donations",
        COALESCE(SUM("Number of Contributions"), 0) AS "Number of Contributions"
    FROM report_contributing_friends_annual_friend_contribution_agg
    GROUP BY year
) annual_all_friend_contribution_agg USING (year)
LEFT JOIN (
    SELECT year, COUNT(renewee_friend_id) AS "Renewees"
    FROM report_contributing_friends_renewees
    GROUP BY year
) annual_renewals_agg USING (year)
LEFT JOIN (
    SELECT year, COUNT(refreshee_friend_id) AS "Refreshees"
    FROM report_contributing_friends_refreshees
    GROUP BY year
) annual_refreshees_agg USING (year)
LEFT JOIN (
    SELECT
        first_contribution_year AS year,
        COUNT(friend_id) AS "First Timers"
    FROM report_contributing_friends_earliest_friend_contributions
    GROUP BY first_contribution_year
) first_timers_agg USING (year)
WHERE year <= date_part('year', CURRENT_DATE)
ORDER BY year;

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
