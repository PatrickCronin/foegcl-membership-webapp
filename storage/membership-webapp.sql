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

CREATE TABLE physical_address (
    person_id INTEGER NOT NULL PRIMARY KEY REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    street_line_1 VARCHAR(128) NOT NULL
        CONSTRAINT physical_address_street_line_1_is_trimmed_and_not_empty CHECK (street_line_1 <> '' AND street_line_1 = trim(both from street_line_1)),
    street_line_2 VARCHAR(128)
        CONSTRAINT physical_address_street_line_2_is_null_or_trimmed_and_not_empty CHECK (street_line_2 IS NULL OR (street_line_2 <> '' AND street_line_2 = trim(both from street_line_2))),
    csz_id INTEGER NOT NULL REFERENCES city_state_zip (csz_id) ON DELETE CASCADE ON UPDATE CASCADE,
    plus_four CHAR(4) DEFAULT NULL
        CONSTRAINT physical_address_plus_four_is_null_or_five_digits CHECK (plus_four IS NULL OR plus_four ~ '^[0-9]{4}$'),
    in_library_special_voting_district boolean NULL DEFAULT NULL,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX physical_address__street_line_1__gin_trgm_idx ON physical_address USING gin (street_line_1 gin_trgm_ops);
CREATE INDEX physical_address__street_line_2__gin_trgm_idx ON physical_address USING gin (street_line_2 gin_trgm_ops);

CREATE OR REPLACE FUNCTION ensure_physical_addresses_match_in_membership()
    RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM person_membership
        WHERE person_id = NEW.person_id
    ) THEN
        RAISE EXCEPTION 'Cannot add, change or delete a physical address for a person in a membership';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION ensure_physical_addresses_match_in_membership() IS 'If a person is in a membership, their physical address should be changed with XXX';

CREATE TRIGGER physical_address__ensure_membership_matches
BEFORE INSERT OR UPDATE OR DELETE ON physical_address
FOR EACH ROW
EXECUTE PROCEDURE ensure_physical_addresses_match_in_membership();

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
        CONSTRAINT year_is_reasonable CHECK (membership_year >= 1980 AND membership_year <= 2079),
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

CREATE TABLE membership (
    membership_id SERIAL PRIMARY KEY,
    membership_year SMALLINT NOT NULL REFERENCES membership_year (membership_year) ON DELETE CASCADE ON UPDATE CASCADE,
    friend_id NUMERIC(11) NOT NULL,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

COMMENT ON COLUMN membership.friend_id IS 'This value should follow memberships year after year';

CREATE INDEX membership__membership_year ON membership (membership_year);
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

CREATE VIEW paying_memberships AS
SELECT membership_id, membership_year, donation_type
FROM donation
INNER JOIN membership USING (membership_id)
INNER JOIN membership_donation_type USING (membership_year, donation_type);

CREATE TABLE person_membership (
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    membership_id INTEGER NOT NULL REFERENCES membership (membership_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, membership_id)
);

CREATE INDEX person_membership__membership_id ON person_membership (membership_id);

CREATE OR REPLACE FUNCTION validate_new_person_membership()
    RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'Updates are not allowed on the person_membership table.';
    END IF;

    IF NEW.membership_id IS NULL THEN
        RAISE EXCEPTION 'membership_id cannot be null';
    END IF;
    IF NEW.person_id IS NULL THEN
        RAISE EXCEPTION 'person_id cannot be null';
    END IF;

    -- Verify membership has a type
    IF NOT EXISTS (
        SELECT 1
        FROM donation
        INNER JOIN membership USING (membership_id)
        INNER JOIN membership_donation_type USING (membership_year, donation_type)
        WHERE membership_id = NEW.membership_id
    ) THEN
        RAISE EXCEPTION 'Cannot add people to a membership without a membership donation.';
    END IF;

    -- Check membership people limit
    IF (
        SELECT COUNT(*)
        FROM person_membership
        WHERE membership_id = NEW.membership_id
    ) >= (
        SELECT membership_max_people
        FROM donation
        INNER JOIN membership USING (membership_id)
        INNER JOIN membership_donation_type USING (membership_year, donation_type)
        WHERE membership_id = NEW.membership_id
    ) THEN
        RAISE EXCEPTION 'Cannot add any more people to this membership. It already has the maximum number of people for its membership type.';
    END IF;

    -- Check membership people's physical addresses are the same
    IF NOT EXISTS (
        SELECT 1
        FROM person_membership
        WHERE membership_id = NEW.membership_id
    ) THEN
        RETURN NEW;
    END IF;

    IF (
        WITH membership_physical_addresses AS (
            SELECT DISTINCT street_line_1, street_line_2, csz_id
            FROM physical_address
            INNER JOIN person_membership USING (person_id)
            WHERE membership_id = NEW.membership_id
        ),
        new_person_address AS (
            SELECT street_line_1, street_line_2, csz_id
            FROM physical_address
            WHERE person_id = NEW.person_id
        )
        SELECT COUNT(*)
        FROM (
            (
                SELECT * FROM membership_physical_addresses
                EXCEPT
                SELECT * FROM new_person_address
            )
            UNION
            (
                SELECT * FROM new_person_address
                EXCEPT
                SELECT * FROM membership_physical_addresses
            )
        ) AS mismatched_addresses
    ) > 0 THEN
        RAISE EXCEPTION 'People sharing a membership must have the same physical address';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER person_membership__validate_new_person_membership
BEFORE INSERT OR UPDATE ON person_membership
FOR EACH ROW
EXECUTE PROCEDURE validate_new_person_membership();

CREATE TYPE donation_type AS ENUM ('individual_membership', 'household_membership', 'honorary_membership', 'general_donation');

CREATE TABLE membership_donation_type (
    membership_year SMALLINT NOT NULL REFERENCES membership_year (membership_year) ON DELETE CASCADE ON UPDATE CASCADE,
    donation_type donation_type NOT NULL,
    membership_max_people SMALLINT NOT NULL
        CONSTRAINT max_people_is_greater_than_zero CHECK (membership_max_people > 0),
    membership_amount NUMERIC(11,2) NOT NULL
        CONSTRAINT membership_amount_is_not_negative CHECK (membership_amount >= 0),
    PRIMARY KEY (membership_year, donation_type)
);

CREATE TABLE donation (
    donation_id SERIAL PRIMARY KEY,
    membership_id INTEGER NOT NULL REFERENCES membership (membership_id) ON DELETE CASCADE ON UPDATE CASCADE,
    donation_type donation_type NOT NULL DEFAULT 'general_donation',
    amount NUMERIC(11,2) NOT NULL
        CONSTRAINT amount_is_not_negative CHECK (amount >= 0),
    notes VARCHAR(128)
        CONSTRAINT notes_is_null_or_trimmed_and_not_empty CHECK (notes IS NULL OR (notes <> '' AND notes = trim(both from notes))),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX donation__membership_id ON donation (membership_id);

CREATE OR REPLACE FUNCTION validate_new_donation()
    RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'Updates are not allowed on the donation table.';
    END IF;

    IF NEW.membership_id IS NULL THEN
        RAISE EXCEPTION 'membership_id cannot be null';
    END IF;
    IF NEW.donation_type IS NULL THEN
        RAISE EXCEPTION 'donation_type cannot be null';
    END IF;
    IF NEW.amount IS NULL THEN
        RAISE EXCEPTION 'amount cannot be null';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM donation
        INNER JOIN membership USING (membership_id)
        INNER JOIN membership_donation_type USING (membership_year, donation_type)
        WHERE membership_id = NEW.membership_id
    ) AND EXISTS (
        SELECT 1
        FROM membership_donation_type
        INNER JOIN membership USING (membership_year)
        WHERE membership_id = NEW.membership_id
        AND donation_type = NEW.donation_type
    ) THEN
        RAISE EXCEPTION 'Cannot add a membership-type donation because the membership already has an existing membership-type donation.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM membership_donation_type
        INNER JOIN membership USING (membership_year)
        WHERE membership_id = NEW.membership_id
        AND donation_type = NEW.donation_type
        AND membership_amount <> NEW.amount
    ) THEN
        RAISE EXCEPTION 'Membership-related donations must be the correct membership amount.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER donation__validate_new_donation
BEFORE INSERT OR UPDATE ON donation
FOR EACH ROW
EXECUTE PROCEDURE validate_new_donation();

INSERT INTO membership_donation_type
(membership_year, donation_type, membership_max_people, membership_amount)
VALUES
    (2011, 'individual_membership', 1, 10),
    (2011, 'household_membership', 2, 20),
    (2011, 'honorary_membership', 1, 0),
    (2012, 'individual_membership', 1, 10),
    (2012, 'household_membership', 2, 20),
    (2012, 'honorary_membership', 1, 0),
    (2013, 'individual_membership', 1, 10),
    (2013, 'household_membership', 2, 20),
    (2013, 'honorary_membership', 1, 0),
    (2014, 'individual_membership', 1, 10),
    (2014, 'household_membership', 2, 20),
    (2014, 'honorary_membership', 1, 0),
    (2015, 'individual_membership', 1, 10),
    (2015, 'household_membership', 2, 20),
    (2015, 'honorary_membership', 1, 0),
    (2016, 'individual_membership', 1, 10),
    (2016, 'household_membership', 2, 20),
    (2016, 'honorary_membership', 1, 0),
    (2017, 'individual_membership', 1, 15),
    (2017, 'household_membership', 2, 25),
    (2017, 'honorary_membership', 1, 0),
    (2018, 'individual_membership', 1, 15),
    (2018, 'household_membership', 2, 25),
    (2018, 'honorary_membership', 1, 0);

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
