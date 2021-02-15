CREATE TABLE addresses (
    id INTEGER NOT NULL PRIMARY KEY,
    street_address TEXT,
    building_name TEXT,
    locality TEXT,
    town TEXT,
    postcode TEXT,
    creation_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reports (
    id BIGSERIAL PRIMARY KEY,
    address_id INTEGER,
    creation_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(address_id) REFERENCES addresses(id)
);

