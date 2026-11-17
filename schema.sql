PRAGMA foreign_keys = ON;

CREATE TABLE brand (
    name TEXT PRIMARY KEY
);

CREATE TABLE specialty (
    name TEXT PRIMARY KEY
);

CREATE TABLE vehicle (
    plate       TEXT PRIMARY KEY,
    model       TEXT NOT NULL,
    year        INTEGER NOT NULL,
    engine_type TEXT NOT NULL,
    brand_name  TEXT NOT NULL REFERENCES brand(name)
);

CREATE TABLE workshop (
    tax_id       TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    phone_number TEXT,
    address      TEXT,
    latitude     REAL NOT NULL,
    longitude    REAL NOT NULL
);

CREATE TABLE fault_code (
    code           TEXT PRIMARY KEY,
    description    TEXT NOT NULL,
    urgency        TEXT NOT NULL CHECK (urgency IN ('low', 'medium', 'high')),
    specialty_name TEXT NOT NULL REFERENCES specialty(name)
);

CREATE TABLE service_record (
    record_id       INTEGER PRIMARY KEY,
    plate           TEXT NOT NULL REFERENCES vehicle(plate),
    workshop_tax_id TEXT NOT NULL REFERENCES workshop(tax_id),
    date            TEXT NOT NULL,
    km              INTEGER NOT NULL,
    description     TEXT,
    price           REAL
);

CREATE TABLE fuel_record (
    fuel_id     INTEGER PRIMARY KEY,
    plate       TEXT NOT NULL REFERENCES vehicle(plate),
    date        TEXT NOT NULL,
    km          INTEGER NOT NULL,
    liters      REAL NOT NULL CHECK (liters > 0),
    total_price REAL NOT NULL
);

CREATE TABLE serves_brand (
    workshop_tax_id TEXT NOT NULL REFERENCES workshop(tax_id),
    brand_name      TEXT NOT NULL REFERENCES brand(name),
    PRIMARY KEY (workshop_tax_id, brand_name)
);

CREATE TABLE has_specialty (
    workshop_tax_id TEXT NOT NULL REFERENCES workshop(tax_id),
    specialty_name  TEXT NOT NULL REFERENCES specialty(name),
    PRIMARY KEY (workshop_tax_id, specialty_name)
);

CREATE TABLE fixed (
    record_id INTEGER NOT NULL REFERENCES service_record(record_id),
    code      TEXT NOT NULL REFERENCES fault_code(code),
    PRIMARY KEY (record_id, code)
);
