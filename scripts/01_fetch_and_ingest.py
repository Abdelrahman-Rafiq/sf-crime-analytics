import requests
import psycopg2
from psycopg2.extras import execute_batch
from datetime import datetime

# API endpoint
URL = "https://data.sfgov.org/api/v3/views/wg3w-h783/query.json"

# DB metadata
DB_CONFIG = {
    "dbname": "",
    "user": "",
    "password": "",
    "host": "",
    "port": "",
}

def set_DB_CONFIG():
    '''Sets The DB connection metadata'''
    dbname = input("Enter database name:")
    DB_CONFIG["dbname"] = dbname
    user = input("Enter username:")
    DB_CONFIG["user"] = user
    passwd = input("Enter user password:")
    DB_CONFIG["password"] = passwd
    host = input("Enter host:")
    DB_CONFIG["host"] = host
    port = input("Enter port:")
    DB_CONFIG["port"] = port


def fetch_api_data():
    """Fetch raw JSON records from the DataSF Socrata API."""
    response = requests.get(URL)

    if response.status_code == 200:
        data = response.json()
        print(f"Successfully fetched {len(data)} records")
        return data
    else:
        raise Exception(
            f"API Request Failed with status code: {response.status_code}"
        )


def setup_database_table():
    """Create table structure in PostgreSQL."""

    create_table_query = """
    CREATE TABLE IF NOT EXISTS sfpd_incidents (
    -- Primary Keys & Identifiers
    row_id BIGINT PRIMARY KEY,
    incident_id BIGINT,
    incident_number BIGINT,
    cad_number VARCHAR(50),
    cnn VARCHAR(50),
    incident_code VARCHAR(10),
    
    -- Timestamps & Dates
    incident_datetime TIMESTAMP,
    incident_date DATE,
    incident_time TIME,
    incident_year INT,
    incident_day_of_week VARCHAR(15),
    report_datetime TIMESTAMP,
    
    -- Incident Classifications
    report_type_code VARCHAR(10),
    report_type_description TEXT,
    filed_online BOOLEAN,               
    incident_category VARCHAR(100),
    incident_subcategory VARCHAR(100),
    incident_description TEXT,
    resolution VARCHAR(100),
    
    -- Geographical Data
    police_district VARCHAR(50),
    supervisor_district INT,            -- Represented as district numbers 1-11
    intersection TEXT,
    latitude NUMERIC(10, 8),            -- High precision decimal coordinates
    longitude NUMERIC(11, 8),
    point POINT,                        -- Stored as (lon, lat)
    
    -- Metadata Timestamps
    data_as_of TIMESTAMP,
    data_loaded_at TIMESTAMP
    );
    """

    connection = psycopg2.connect(**DB_CONFIG)
    cursor = connection.cursor()

    try:
        cursor.execute(create_table_query)
        connection.commit()
        cursor.close()
        connection.close()
        print("PostgreSQL table created successfully")
    except:
        raise Exception(
            f"Failed to Create A table for the data"
        )

def parse_timestamp(val):
    """Safely parse ISO timestamp strings from Socrata API."""
    if not val:
        return None
    try:
        # Handles Socrata ISO formats like '2026-09-07T17:42:18.000'
        return datetime.fromisoformat(val.replace("Z", ""))
    except ValueError:
        return None


def parse_int(val):
    """Safely convert numerical string values to integers."""
    if val is None:
        return None
    try:
        return int(val)
    except ValueError:
        return None


def parse_float(val):
    """Safely convert numerical coordinate strings to floats."""
    if val is None:
        return None
    try:
        return float(val)
    except ValueError:
        return None


def parse_bool(val):
    """Safely map Socrata boolean/checkbox fields."""
    if isinstance(val, bool):
        return val
    if isinstance(val, str):
        return val.lower() in ("true", "1", "t", "yes")
    return False

def ingest_into_database(records):
    """Insert JSON API payloads into PostgreSQL with parameterized safe types."""
    insert_query = """
    INSERT INTO sfpd_incidents (
        row_id, incident_id, incident_number, cad_number, cnn, incident_code,
        incident_datetime, incident_date, incident_time, incident_year, incident_day_of_week, report_datetime,
        report_type_code, report_type_description, filed_online, incident_category, incident_subcategory, 
        incident_description, resolution, police_district, supervisor_district, intersection, 
        latitude, longitude, point, data_as_of, data_loaded_at
    )
    VALUES (
        %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s
    )
    ON CONFLICT (row_id) DO NOTHING;
    """

    data_tuples = []
    for item in records:
        # Map GeoJSON Point object: Socrata returns location as {'latitude': '...', 'longitude': '...'} or GeoJSON point
        lat = parse_float(item.get("latitude"))
        lon = parse_float(item.get("longitude"))
        point_val = f"({lon},{lat})" if lon is not None and lat is not None else None

        row = (
            # Primary Keys & Identifiers
            parse_int(item.get("row_id")),
            parse_int(item.get("incident_id")),
            parse_int(item.get("incident_number")),
            item.get("cad_number"),
            item.get("cnn"),
            item.get("incident_code"),
            # Timestamps & Dates
            parse_timestamp(item.get("incident_datetime")),
            item.get("incident_date"),  # Fits SQL DATE format (YYYY-MM-DD)
            item.get("incident_time"),  # Fits SQL TIME format (HH:MM)
            parse_int(item.get("incident_year")),
            item.get("incident_day_of_week"),
            parse_timestamp(item.get("report_datetime")),
            # Classifications & Flags
            item.get("report_type_code"),
            item.get("report_type_description"),
            parse_bool(item.get("filed_online")),
            item.get("incident_category"),
            item.get("incident_subcategory"),
            item.get("incident_description"),
            item.get("resolution"),
            # Location
            item.get("police_district"),
            parse_int(item.get("supervisor_district")),
            item.get("intersection"),
            lat,
            lon,
            point_val,
            # Metadata
            parse_timestamp(item.get("data_as_of")),
            parse_timestamp(item.get("data_loaded_at")),
        )
        data_tuples.append(row)

    # Batch execute for speed
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    execute_batch(cur, insert_query, data_tuples, page_size=1000)
    conn.commit()

    print(
        f"Batch process finished. Processed {len(data_tuples)} API records."
    )
    cur.close()
    conn.close()


if __name__ == "__main__":
    set_DB_CONFIG()
    setup_database_table()
    data = fetch_api_data()
    ingest_into_database(data)
