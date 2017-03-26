SET TIME ZONE 'UTC';

DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

CREATE TABLE affiliation_year (
    year NUMERIC(4) PRIMARY KEY CHECK (year >= 1980 AND year <= 2079),
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
    (2018),
    (2019),
    (2020),
    (2021),
    (2022),
    (2023),
    (2024),
    (2025);

CREATE TABLE affiliation (
    affiliation_id SERIAL PRIMARY KEY,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE state (
    state_abbr CHAR(2) PRIMARY KEY,
    state_name VARCHAR(32) NOT NULL CHECK (state_name <> '') UNIQUE,
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
    zip DECIMAL(5) NOT NULL,
    city VARCHAR(64) NOT NULL CHECK (city <> ''),
    state_abbr CHAR(2) NOT NULL REFERENCES state (state_abbr),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    UNIQUE(zip, city, state_abbr)
);

CREATE TABLE residential_address (
    affiliation_id INTEGER NOT NULL PRIMARY KEY REFERENCES affiliation (affiliation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    street_line_1 VARCHAR(128) NOT NULL CHECK (street_line_1 <> ''),
    street_line_2 VARCHAR(128) CHECK (street_line_2 IS NULL OR street_line_2 <> ''),
    csz_id INTEGER NOT NULL REFERENCES city_state_zip (csz_id) ON DELETE CASCADE ON UPDATE CASCADE,
    plus_four NUMERIC(4) CHECK (plus_four IS NULL OR LENGTH(plus_four) = 4),
    definitely_in_library_special_voting_district boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE postal_address (
    affiliation_id INTEGER NOT NULL PRIMARY KEY REFERENCES affiliation (affiliation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    street_line_1 VARCHAR(128) NOT NULL CHECK (street_line_1 <> ''),
    street_line_2 VARCHAR(128) CHECK (street_line_2 IS NULL OR street_line_2 <> ''),
    csz_id INTEGER NOT NULL REFERENCES city_state_zip (csz_id) ON DELETE CASCADE ON UPDATE CASCADE,
    plus_four NUMERIC(4) CHECK (plus_four IS NULL OR LENGTH(plus_four) = 4),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TYPE donation_type_enum AS ENUM ('membership_fee', 'donation');

CREATE TABLE donation (
    donation_id SERIAL PRIMARY KEY,
    affiliation_id INTEGER NOT NULL REFERENCES affiliation (affiliation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    affiliation_year NUMERIC(4) NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    donation_type donation_type_enum NOT NULL,
    amount MONEY NOT NULL CHECK (amount > 0::money),
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    affiliation_id INTEGER REFERENCES affiliation (affiliation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    first_name VARCHAR(64) NOT NULL,
    last_name VARCHAR(64) NOT NULL,
    opted_out boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE affiliation_year_registered_voter (
    affiliation_year NUMERIC(4) NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (affiliation_year, person_id)
);

CREATE TABLE person_phone (
    person_id INTEGER NOT NULL REFERENCES person (person_id),
    phone_number VARCHAR(32) NOT NULL CHECK (phone_number <> ''),
    is_preferred boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, phone_number)
);

CREATE TABLE person_email (
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    email_address VARCHAR(128) NOT NULL CHECK (email_address <> ''),
    is_preferred boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, email_address)
);

CREATE TABLE participation_role (
    participation_role_id SERIAL PRIMARY KEY,
    parent_role_id INTEGER,
    role_name VARCHAR(128) NOT NULL CHECK (role_name <> '') UNIQUE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE person_has_participated (
    affiliation_year NUMERIC(4) NOT NULL REFERENCES affiliation_year (year) ON DELETE CASCADE ON UPDATE CASCADE,
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    participation_role_id INTEGER NOT NULL REFERENCES participation_role (participation_role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (affiliation_year, person_id, participation_role_id)
);

CREATE TABLE person_interested_in_participating (
    person_id INTEGER NOT NULL REFERENCES person (person_id) ON DELETE CASCADE ON UPDATE CASCADE,
    participation_role_id INTEGER NOT NULL REFERENCES participation_role (participation_role_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW(),
    PRIMARY KEY (person_id, participation_role_id)
);

CREATE TABLE app_user (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(32) NOT NULL CHECK (username <> '') UNIQUE,
    password_hash bytea NOT NULL CHECK(length(password_hash) = 64),
    first_name VARCHAR(32) NOT NULL CHECK (first_name <> ''),
    last_name VARCHAR(32) NOT NULL CHECK (last_name <> ''),
    login_enabled boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT NOW(),
    updated_at timestamp with time zone DEFAULT NOW()
);

CREATE TABLE app_role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(64) NOT NULL CHECK (role_name <> '') UNIQUE,
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

CREATE TABLE app_privilege (
    privilege_id SERIAL PRIMARY KEY,
    privilege_name VARCHAR(64) NOT NULL CHECK (privilege_name <> '') UNIQUE,
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
