PRAGMA foreign_keys = ON;

-- All data in this file is fictional and created for testing.

-- 1) Independent tables first: brands and specialties
INSERT INTO brand (name) VALUES
    ('Fiat'),
    ('Tofaş'),
    ('Renault'),
    ('Toyota'),
    ('Lexus'),
    ('Mazda'),
    ('Mitsubishi'),
    ('Nissan'),
    ('Hyundai'),
    ('Volkswagen'),
    ('Opel'),
    ('Mercedes-Benz'),
    ('Volvo'),
    ('Peugeot');

INSERT INTO specialty (name) VALUES
    ('Engine'),
    ('Electrical'),
    ('Transmission'),
    ('Exhaust'),
    ('Brakes');

-- 2) Fault codes (each needs a specialty that already exists)
INSERT INTO fault_code (code, description, urgency, specialty_name) VALUES
    ('P0300', 'Random/multiple cylinder misfire detected',      'high',   'Engine'),
    ('P0171', 'System too lean (bank 1)',                       'medium', 'Engine'),
    ('P0128', 'Coolant thermostat below regulating temp.',      'low',    'Engine'),
    ('P0420', 'Catalyst efficiency below threshold',            'medium', 'Exhaust'),
    ('P0562', 'System voltage low',                             'medium', 'Electrical'),
    ('P0700', 'Transmission control system malfunction',        'high',   'Transmission'),
    ('U0100', 'Lost communication with engine control module',  'high',   'Electrical');

-- 3) Workshops (all made-up names)
--    IDs are assigned in this order: 1, 2, 3, 4, 5
INSERT INTO workshop (name, phone_number, address, latitude, longitude) VALUES
    ('Owile Motor',        NULL, 'Efeler, Aydın', 37.8380, 27.8300),
    ('Muti Oto Elektrik',  NULL, 'Efeler, Aydın', 37.8460, 27.8400),
    ('Masterbas Şanzıman', NULL, 'Efeler, Aydın', 37.8520, 27.8350),
    ('Ryaelf Egzoz',       NULL, 'Efeler, Aydın', 37.8400, 27.8500),
    ('Ibowile Fren',       NULL, 'Efeler, Aydın', 37.8300, 27.8450);

-- 4) Which brands each workshop serves
INSERT INTO serves_brand (workshop_id, brand_name) VALUES
    (1, 'Mazda'),
    (1, 'Toyota'),
    (1, 'Lexus'),
    (1, 'Mitsubishi'),
    (2, 'Fiat'),
    (2, 'Tofaş'),
    (2, 'Renault'),
    (3, 'Opel'),
    (3, 'Volkswagen'),
    (3, 'Mercedes-Benz'),
    (4, 'Nissan'),
    (4, 'Volvo'),
    (5, 'Fiat'),
    (5, 'Volvo'),
    (5, 'Peugeot');

-- 5) Which specialties each workshop has
--    Clutch work is counted under Transmission
INSERT INTO has_specialty (workshop_id, specialty_name) VALUES
    (1, 'Engine'),
    (1, 'Transmission'),
    (2, 'Electrical'),
    (3, 'Transmission'),
    (4, 'Exhaust'),
    (5, 'Brakes');

-- 6) Vehicle (fictional plate)
INSERT INTO vehicle (plate, model, year, engine_type, brand_name) VALUES
    ('09 TST 001', 'Egea', 2021, 'diesel', 'Fiat');

-- 7a) Service records (record_id is assigned automatically: 1, 2, 3)
INSERT INTO service_record (plate, workshop_id, date, km, description, price) VALUES
    ('09 TST 001', 5, '2026-03-12', 41200, 'Front brake pads replaced',          3200),
    ('09 TST 001', 2, '2026-06-05', 48900, 'Battery replaced after low voltage', 4500),
    ('09 TST 001', 5, '2026-10-20', 56300, 'Rear brake discs replaced',          5800);

-- 7b) Which fault codes were fixed during a service visit
INSERT INTO fixed (record_id, code) VALUES
    (2, 'P0562');

-- 7c) Fuel records
INSERT INTO fuel_record (plate, date, km, liters, total_price) VALUES
    ('09 TST 001', '2026-08-02', 51000, 42.5, 2210),
    ('09 TST 001', '2026-08-24', 51780, 38.0, 1990),
    ('09 TST 001', '2026-09-15', 52610, 40.2, 2120),
    ('09 TST 001', '2026-10-08', 53420, 39.1, 2085);
