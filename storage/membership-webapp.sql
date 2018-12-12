SET TIME ZONE 'UTC';

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
    source_friend_id NUMERIC(11),
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

CREATE TYPE membership_type AS ENUM (
    'individual_membership',
    'household_membership',
    'senior_student_individual_membership',
    'senior_household_membership'
);

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
    (2017, 'senior_student_individual_membership', 1, 10),
    (2017, 'senior_household_membership', 2, 20),
    (2018, 'individual_membership', 1, 15),
    (2018, 'household_membership', 2, 25),
    (2018, 'senior_student_individual_membership', 1, 10),
    (2018, 'senior_household_membership', 2, 20);

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
SELECT * FROM affiliation WHERE membership_type IS NOT NULL;

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
    received DATE NOT NULL DEFAULT CURRENT_DATE,
    notes VARCHAR(128)
        CONSTRAINT notes_is_null_or_trimmed_and_not_empty CHECK (notes IS NULL OR (notes <> '' AND notes = trim(both from notes))),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE INDEX contribution__affiliation_id ON contribution (affiliation_id);

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


CREATE FUNCTION verify_affiliation_person_integrity(
    v_affiliation_id INTEGER
)
RETURNS VOID AS $$
BEGIN
    IF (
        SELECT COUNT(*)
        FROM affiliation_person
        WHERE affiliation_id = v_affiliation_id
    ) = 0 THEN
        RAISE EXCEPTION 'This change would leave affiliation % without any people', v_affiliation_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION verify_affiliation_contribution_integrity(
    v_affiliation_id INTEGER
)
RETURNS VOID AS $$
BEGIN
    IF (
        SELECT COUNT(*)
        FROM contribution
        WHERE affiliation_id = v_affiliation_id
    ) < 1 THEN
        RAISE EXCEPTION 'This change would leave affiliation % without any contributions.', v_affiliation_id;
    END IF;

    IF (
        SELECT COUNT(*)
        FROM contribution
        INNER JOIN affiliation USING (affiliation_id)
        WHERE affiliation_id = v_affiliation_id
        AND DATE_PART('YEAR', received) <> affiliation.year
    ) > 0 THEN
        RAISE EXCEPTION 'This change would mean at least one contribution for affiliation % would have a recieved date in a different year.', v_affiliation_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION verify_cur_year_affiliation_person_mailing_address_integrity(
    v_affiliation_id INTEGER
)
RETURNS VOID AS $$
BEGIN
    IF DATE_PART('YEAR', CURRENT_DATE) <> (
        SELECT year
        FROM affiliation
        WHERE affiliation_id = v_affiliation_id
    ) THEN
        RETURN;
    END IF;

    IF (
        SELECT COUNT(*)
        FROM (
            SELECT DISTINCT street_line_1, street_line_2, csz_id
            FROM affiliation
            INNER JOIN affiliation_person USING (affiliation_id)
            LEFT JOIN mailing_address USING (person_id)
            WHERE affiliation_id = v_affiliation_id
        ) distinct_affiliation_addresses
    ) <> 1 THEN
        RAISE EXCEPTION 'This change would leave affiliation % with multiple mailing addresses', v_affiliation_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION verify_cur_year_affiliation_person_physical_address_integrity(
    v_affiliation_id INTEGER
)
RETURNS VOID AS $$
BEGIN
    IF DATE_PART('YEAR', CURRENT_DATE) <> (
        SELECT year
        FROM affiliation
        WHERE affiliation_id = v_affiliation_id
    ) THEN
        RETURN;
    END IF;

    IF (
        SELECT COUNT(*)
        FROM (
            SELECT DISTINCT street_line_1, street_line_2, csz_id
            FROM affiliation
            INNER JOIN affiliation_person USING (affiliation_id)
            LEFT JOIN physical_address USING (person_id)
            WHERE affiliation_id = v_affiliation_id
        ) distinct_affiliation_addresses
    ) <> 1 THEN
        RAISE EXCEPTION 'This change would leave affiliation % with multiple physical addresses', v_affiliation_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION verify_membership_maximum_person_integrity(
    v_affiliation_id INTEGER
)
RETURNS VOID AS $$
BEGIN
    IF (
        SELECT membership_type
        FROM affiliation
        WHERE affiliation_id = v_affiliation_id
    ) IS NULL THEN
        RETURN;
    END IF;

    IF (
        SELECT COUNT(*)
        FROM affiliation_person
        WHERE affiliation_id = v_affiliation_id
    ) > (
        SELECT membership_max_people
        FROM affiliation
        INNER JOIN membership_type_parameters USING (year, membership_type)
        WHERE affiliation_id = v_affiliation_id
    ) THEN
        RAISE EXCEPTION 'This change would leave affiliation % with more people than the membership type supports', v_affiliation_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION verify_membership_minimum_contribution_integrity(
    v_affiliation_id INTEGER
)
RETURNS VOID AS $$
BEGIN
    IF (
        SELECT membership_type
        FROM affiliation
        WHERE affiliation_id = v_affiliation_id
    ) IS NULL THEN
        RETURN;
    END IF;

    IF (
        SELECT COALESCE(SUM(amount), 0)
        FROM contribution
        WHERE affiliation_id = v_affiliation_id
    ) < (
        SELECT membership_amount
        FROM affiliation
        INNER JOIN membership_type_parameters USING (year, membership_type)
        WHERE affiliation_id = v_affiliation_id
    ) THEN
        RAISE EXCEPTION 'This change would leave affiliation % without enough contributions to support it''s minimum contribution requirement.', v_affiliation_id;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- For INSERT, UPDATE and DELETE
CREATE FUNCTION validate_contribution_change()
RETURNS TRIGGER AS $$
DECLARE
    v_affected_affiliation_ids INTEGER[];
    affiliation_id INTEGER;
BEGIN
    IF TG_OP = ANY ( ARRAY['DELETE', 'UPDATE'] ) THEN
        v_affected_affiliation_ids = v_affected_affiliation_ids || OLD.affiliation_id;
    END IF;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        v_affected_affiliation_ids = v_affected_affiliation_ids || NEW.affiliation_id;
    END IF;

    FOREACH affiliation_id IN ARRAY v_affected_affiliation_ids LOOP
        PERFORM verify_affiliation_contribution_integrity(affiliation_id);
        PERFORM verify_membership_minimum_contribution_integrity(affiliation_id);
    END LOOP;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_contribution_change
AFTER INSERT OR UPDATE OR DELETE ON contribution
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW
EXECUTE PROCEDURE validate_contribution_change();

-- Only for INSERT and UPDATE
-- Not necessary for DELETE
CREATE FUNCTION validate_affiliation_change()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM verify_affiliation_person_integrity(NEW.affiliation_id);
    PERFORM verify_affiliation_contribution_integrity(NEW.affiliation_id);
    PERFORM verify_cur_year_affiliation_person_mailing_address_integrity(NEW.affiliation_id);
    PERFORM verify_cur_year_affiliation_person_physical_address_integrity(NEW.affiliation_id);
    PERFORM verify_membership_maximum_person_integrity(NEW.affiliation_id);
    PERFORM verify_membership_minimum_contribution_integrity(NEW.affiliation_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_affiliation_change
AFTER INSERT OR UPDATE ON affiliation
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW
EXECUTE PROCEDURE validate_affiliation_change();

-- For INSERT, UPDATE and DELETE
CREATE FUNCTION validate_affiliation_person_change()
RETURNS TRIGGER AS $$
DECLARE
    v_affected_affiliation_ids INTEGER[];
    affiliation_id INTEGER;
BEGIN
    IF TG_OP = ANY ( ARRAY['DELETE', 'UPDATE'] ) THEN
        v_affected_affiliation_ids = v_affected_affiliation_ids || OLD.affiliation_id;
    END IF;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        v_affected_affiliation_ids = v_affected_affiliation_ids || NEW.affiliation_id;
    END IF;

    FOREACH affiliation_id IN ARRAY v_affected_affiliation_ids LOOP
        PERFORM verify_affiliation_person_integrity(affiliation_id);
        PERFORM verify_cur_year_affiliation_person_mailing_address_integrity(affiliation_id);
        PERFORM verify_cur_year_affiliation_person_physical_address_integrity(affiliation_id);
        PERFORM verify_membership_maximum_person_integrity(affiliation_id);
    END LOOP;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_affiliation_person_change
AFTER INSERT OR UPDATE OR DELETE ON affiliation_person
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW
EXECUTE PROCEDURE validate_affiliation_person_change();

-- For INSERT, UPDATE and DELETE
CREATE FUNCTION validate_mailing_address_change()
RETURNS TRIGGER AS $$
DECLARE
    v_affected_person_ids INTEGER[];
    v_affected_affiliation_ids INTEGER[];
    v_affiliation_id INTEGER;
BEGIN
    IF TG_OP = ANY ( ARRAY['DELETE', 'UPDATE'] ) THEN
        v_affected_person_ids = v_affected_person_ids || OLD.person_id;
    END IF;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        v_affected_person_ids = v_affected_person_ids || NEW.person_id;
    END IF;

    v_affected_affiliation_ids = (
        SELECT array_agg(affiliation_id)
        FROM mailing_address
        INNER JOIN person USING (person_id)
        INNER JOIN affiliation_person USING (person_id)
        INNER JOIN affiliation USING (affiliation_id)
        WHERE person_id = ANY (v_affected_person_ids)
    );

    IF array_length(v_affected_affiliation_ids, 1) > 0 THEN
        FOREACH v_affiliation_id IN ARRAY v_affected_affiliation_ids LOOP
            PERFORM verify_cur_year_affiliation_person_mailing_address_integrity(v_affiliation_id);
        END LOOP;
    END IF;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_mailing_address_change
AFTER INSERT OR UPDATE OR DELETE ON mailing_address
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW
EXECUTE PROCEDURE validate_mailing_address_change();

-- For INSERT, UPDATE and DELETE
CREATE FUNCTION validate_physical_address_change()
RETURNS TRIGGER AS $$
DECLARE
    v_affected_person_ids INTEGER[];
    v_affected_affiliation_ids INTEGER[];
    v_affiliation_id INTEGER;
BEGIN
    IF TG_OP = ANY ( ARRAY['DELETE', 'UPDATE'] ) THEN
        v_affected_person_ids = v_affected_person_ids || OLD.person_id;
    END IF;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        v_affected_person_ids = v_affected_person_ids || NEW.person_id;
    END IF;

    v_affected_affiliation_ids = (
        SELECT array_agg(affiliation_id)
        FROM physical_address
        INNER JOIN person USING (person_id)
        INNER JOIN affiliation_person USING (person_id)
        INNER JOIN affiliation USING (affiliation_id)
        WHERE person_id = ANY (v_affected_person_ids)
    );

    IF array_length(v_affected_affiliation_ids, 1) > 0 THEN
        FOREACH v_affiliation_id IN ARRAY v_affected_affiliation_ids LOOP
            PERFORM verify_cur_year_affiliation_person_physical_address_integrity(v_affiliation_id);
        END LOOP;
    END IF;

    IF TG_OP = ANY ( ARRAY['UPDATE', 'INSERT'] ) THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_physical_address_change
AFTER INSERT OR UPDATE OR DELETE ON physical_address
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW
EXECUTE PROCEDURE validate_physical_address_change();

CREATE TABLE voter_registration (
    year SMALLINT NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (year, person_id)
);

CREATE INDEX voter_registration__person_id ON voter_registration (person_id);

CREATE TABLE app_user (
    username VARCHAR(128) NOT NULL PRIMARY KEY
        CONSTRAINT username_is_trimmed_and_not_empty CHECK (username <> '' AND username = trim(both from username)),
    password_hash VARCHAR(137) NOT NULL,
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
    username VARCHAR(128) NOT NULL REFERENCES app_user (username) ON DELETE CASCADE ON UPDATE CASCADE,
    role_id INTEGER NOT NULL REFERENCES app_role (role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (username, role_id)
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

-- Anyone who was connected with a contributing affiliation within the
-- last two calendar years. Separated to enable testing.
CREATE VIEW report_blast_email_list_by_contribution AS
SELECT DISTINCT email_address
FROM contribution
INNER JOIN affiliation USING (affiliation_id)
INNER JOIN affiliation_person USING (affiliation_id)
INNER JOIN person USING (person_id)
INNER JOIN person_email USING (person_id)
WHERE year IN (
    date_part('year', CURRENT_DATE) - 1,
    date_part('year', CURRENT_DATE)
)
AND opted_out = false;

-- Anyone who has an active interest. Separated to enable testing.
CREATE VIEW report_blast_email_list_by_interest AS
SELECT DISTINCT email_address
FROM participation_interest
INNER JOIN person USING (person_id)
INNER JOIN person_email USING (person_id)
WHERE opted_out = false;

-- Anyone who participated in something within the last two calendar years.
-- Separated to enable testing.
CREATE VIEW report_blast_email_list_by_participation AS
SELECT DISTINCT email_address
FROM participation_record
INNER JOIN person USING (person_id)
INNER JOIN person_email USING (person_id)
WHERE year IN (
    date_part('year', CURRENT_DATE) - 1,
    date_part('year', CURRENT_DATE)
)
AND opted_out = false;

CREATE VIEW report_blast_email_list AS
SELECT email_address FROM report_blast_email_list_by_contribution
UNION
SELECT email_address FROM report_blast_email_list_by_interest
UNION
SELECT email_address FROM report_blast_email_list_by_participation
ORDER BY email_address;

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
SELECT
    friend_id,
    first_name as first_name,
    last_name as last_name,
    last_name || ', ' || first_name AS name,
    COALESCE(street_line_1) || COALESCE( E'\n' || street_line_2, '') street_lines,
    city || ', ' || state_abbr || ' ' || zip || COALESCE( '-' || plus_four, '') city_state_zip,
    emails,
    phones
FROM person
INNER JOIN affiliation_person USING (person_id)
INNER JOIN membership USING (affiliation_id)
LEFT JOIN physical_address USING (person_id)
LEFT JOIN city_state_zip USING (csz_id)
LEFT JOIN (
    SELECT person_id, string_agg(email_address, E'\n' ORDER BY is_preferred DESC, email_address) emails
    FROM person_email
    GROUP BY person_id
) aggregated_email USING (person_id)
LEFT JOIN (
    SELECT person_id, string_agg(format_phone_number(phone_number), E'\n' ORDER BY is_preferred DESC, format_phone_number(phone_number)) phones
    FROM person_phone
    GROUP BY person_id
) aggregated_phone USING (person_id)
WHERE year = date_part('year', CURRENT_DATE)
ORDER BY last_name, first_name;

CREATE VIEW report_contributing_friends_annual_friend_contribution_agg AS
SELECT
    year,
    friend_id,
    COALESCE(SUM(amount), 0) AS total_contributed,
    COALESCE(membership_amount, 0) AS membership_portion_of_contributions,
    COALESCE(SUM(amount), 0) - COALESCE(membership_amount, 0) AS donation_portion_of_contributions,
    COUNT(amount) AS number_of_contributions
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
    year AS "Year",
    number_of_contributing_friends AS "Contributing Friends",
    number_of_renewees AS "Renewees",
    number_of_refreshees AS "Refreshees",
    number_of_first_timers AS "First Timers",
    contribution_total AS "Total Contributed",
    membership_portion AS "Membership Portion",
    donation_portion AS "Donation Portion",
    number_of_contributions AS "Number of Contributions"
FROM affiliation_year
LEFT JOIN (
    SELECT
        year,
        COUNT(*) number_of_contributing_friends,
        COALESCE(SUM(total_contributed), 0) AS contribution_total,
        COALESCE(SUM(membership_portion_of_contributions), 0) AS membership_portion,
        COALESCE(SUM(donation_portion_of_contributions), 0) AS donation_portion,
        COALESCE(SUM(number_of_contributions), 0) AS number_of_contributions
    FROM report_contributing_friends_annual_friend_contribution_agg
    GROUP BY year
) annual_all_friend_contribution_agg USING (year)
LEFT JOIN (
    SELECT year, COUNT(renewee_friend_id) AS number_of_renewees
    FROM report_contributing_friends_renewees
    GROUP BY year
) annual_renewals_agg USING (year)
LEFT JOIN (
    SELECT year, COUNT(refreshee_friend_id) AS number_of_refreshees
    FROM report_contributing_friends_refreshees
    GROUP BY year
) annual_refreshees_agg USING (year)
LEFT JOIN (
    SELECT
        first_contribution_year AS year,
        COUNT(friend_id) AS number_of_first_timers
    FROM report_contributing_friends_earliest_friend_contributions
    GROUP BY first_contribution_year
) first_timers_agg USING (year)
WHERE year <= date_part('year', CURRENT_DATE)
ORDER BY year;

CREATE FUNCTION format_list (items TEXT[], delimiter TEXT DEFAULT ', ', conjunction TEXT DEFAULT ' and ')
RETURNS TEXT
AS $$
DECLARE
    v_num_items INTEGER;
BEGIN
    v_num_items = array_length(items, 1);

    IF v_num_items = 0 THEN
        RETURN '';
    ELSIF v_num_items = 1 THEN
        RETURN items[1];
    ELSIF v_num_items > 1 THEN
        RETURN array_to_string(items[1:v_num_items-1], delimiter)
            || conjunction || items[v_num_items];
    END IF;

    RAISE EXCEPTION 'Unknown number of names';
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION format_names_by_family (person_ids INTEGER[])
RETURNS TEXT
AS $$
BEGIN
    IF array_length(person_ids, 1) = 0 THEN
        RETURN NULL;
    END IF;

    RETURN (
        SELECT format_list(array_agg(family)) AS families
        FROM (
            SELECT format_list(array_agg(first_name::TEXT)) || ' ' || last_name AS family
            FROM person
            WHERE person_id = ANY(person_ids)
            GROUP BY last_name
        ) AS people_by_family
    );
END;
$$ LANGUAGE plpgsql;

CREATE VIEW person_address_for_mailing AS
SELECT
    person_id,
    street_line_1,
    street_line_2,
    city,
    state_abbr,
    zip,
    plus_four
FROM mailing_address
INNER JOIN city_state_zip USING (csz_id)
UNION ALL
SELECT
    p.person_id,
    p.street_line_1,
    p.street_line_2,
    city,
    state_abbr,
    zip,
    p.plus_four
FROM physical_address p
INNER JOIN city_state_zip USING (csz_id)
LEFT JOIN mailing_address USING (person_id)
WHERE mailing_address.street_line_1 IS NULL;

COMMENT ON VIEW person_address_for_mailing IS 'A person with no mailing address can be mailed at their physical address';

CREATE VIEW membership_renewal_mailing_list_by_contribution AS
SELECT
    format_names_by_family(array_agg(person_id)) AS names,
    street_line_1,
    street_line_2,
    city,
    state_abbr,
    zip,
    plus_four
FROM person_address_for_mailing
INNER JOIN person USING (person_id)
INNER JOIN affiliation_person USING (person_id)
INNER JOIN affiliation USING (affiliation_id)
INNER JOIN contribution USING (affiliation_id)
WHERE year >= EXTRACT (YEAR FROM CURRENT_DATE) - 2
GROUP BY street_line_1, street_line_2, city, state_abbr, zip, plus_four;

COMMENT ON VIEW membership_renewal_mailing_list_by_contribution IS 'This is just for ETL testing.';

CREATE VIEW recently_relevant_person AS
SELECT person_id
FROM person
INNER JOIN affiliation_person USING (person_id)
INNER JOIN affiliation USING (affiliation_id)
INNER JOIN contribution USING (affiliation_id)
WHERE year >= EXTRACT (YEAR FROM CURRENT_DATE) - 2
UNION
SELECT person_id
FROM participation_interest
UNION
SELECT person_id
FROM participation_record
WHERE year >= EXTRACT (YEAR FROM CURRENT_DATE) - 2;

CREATE VIEW membership_renewal_mailing_list AS
SELECT
    format_names_by_family(array_agg(person_id)) AS names,
    street_line_1,
    street_line_2,
    city,
    state_abbr,
    zip,
    plus_four
FROM recently_relevant_person
INNER JOIN person USING (person_id)
INNER JOIN person_address_for_mailing USING (person_id)
LEFT JOIN affiliation_person ap USING (person_id)
LEFT JOIN membership m ON ap.affiliation_id = m.affiliation_id AND year = EXTRACT(YEAR FROM CURRENT_DATE)
WHERE opted_out = false
AND m.affiliation_id IS NULL -- does not already have a current membership
GROUP BY street_line_1, street_line_2, city, state_abbr, zip, plus_four;

CREATE VIEW end_of_year_donation_mailing_list AS
SELECT
    format_names_by_family(array_agg(person_id)) AS names,
    street_line_1,
    street_line_2,
    city,
    state_abbr,
    zip,
    plus_four
FROM recently_relevant_person
INNER JOIN person USING (person_id)
INNER JOIN person_address_for_mailing USING (person_id)
WHERE opted_out = false
GROUP BY street_line_1, street_line_2, city, state_abbr, zip, plus_four;

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
