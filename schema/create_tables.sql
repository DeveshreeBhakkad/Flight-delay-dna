-- ============================================
-- FLIGHT DELAY DNA - DATABASE SCHEMA
-- ============================================
-- This file creates all tables for our flight delay analysis project
-- Read each comment to understand WHY we write each line

-- ============================================
-- TABLE 1: airlines
-- ============================================
-- Purpose: Store information about airline companies
-- Example: American Airlines, Delta, United, etc.

CREATE TABLE airlines (
    -- airline_code: Unique 2-3 letter code (like 'AA', 'DL')
    -- VARCHAR(3) means: text up to 3 characters
    -- PRIMARY KEY means: this uniquely identifies each airline (no duplicates allowed)
    airline_code VARCHAR(3) PRIMARY KEY,
    
    -- airline_name: Full company name
    -- VARCHAR(100) means: text up to 100 characters
    -- NOT NULL means: this field cannot be empty (must have a value)
    airline_name VARCHAR(100) NOT NULL,
    
    -- country: Which country the airline is from
    -- VARCHAR(50): text up to 50 characters
    -- Default 'United States' means: if we don't specify, assume USA
    country VARCHAR(50) DEFAULT 'United States'
);

-- WHY THIS STRUCTURE?
-- - airline_code as PRIMARY KEY: Each airline has unique code
-- - airline_name NOT NULL: Every airline must have a name
-- - country has default: Most of our data is US airlines


-- ============================================
-- TABLE 2: airports
-- ============================================
-- Purpose: Store information about airports
-- Example: JFK, LAX, ORD, etc.

CREATE TABLE airports (
    -- airport_code: 3-letter IATA code (like 'JFK', 'LAX')
    -- PRIMARY KEY: Uniquely identifies each airport
    airport_code VARCHAR(3) PRIMARY KEY,
    
    -- airport_name: Full airport name
    airport_name VARCHAR(100) NOT NULL,
    
    -- city: Which city the airport is in
    city VARCHAR(50) NOT NULL,
    
    -- state: 2-letter US state code (like 'NY', 'CA')
    -- Can be NULL because some airports might be international
    state VARCHAR(2),
    
    -- latitude: GPS coordinate (north-south position)
    -- DECIMAL(10,6) means: 10 total digits, 6 after decimal
    -- Example: 40.639722
    latitude DECIMAL(10,6),
    
    -- longitude: GPS coordinate (east-west position)
    -- Example: -73.778889
    longitude DECIMAL(10,6)
);

-- WHY THIS STRUCTURE?
-- - airport_code as PRIMARY KEY: Each airport has unique 3-letter code
-- - city and airport_name NOT NULL: Must have these basics
-- - state can be NULL: International airports don't have US states
-- - DECIMAL for coordinates: Need precise GPS location


-- ============================================
-- TABLE 3: flights
-- ============================================
-- Purpose: Store information about individual flights
-- Example: AA123 from JFK to LAX on Jan 15, 2024

CREATE TABLE flights (
    -- flight_id: Unique ID for each flight record
    -- SERIAL means: PostgreSQL automatically generates 1, 2, 3, 4...
    -- PRIMARY KEY: Uniquely identifies this specific flight instance
    flight_id SERIAL PRIMARY KEY,
    
    -- flight_number: The flight number (like 'AA123')
    -- VARCHAR(10): Up to 10 characters
    flight_number VARCHAR(10) NOT NULL,
    
    -- airline_code: Which airline operates this flight
    -- VARCHAR(3): The 3-letter airline code
    -- FOREIGN KEY: Must match an airline_code in the airlines table
    -- REFERENCES airlines(airline_code): Creates the link
    -- This means: "This flight belongs to an airline that exists in airlines table"
    airline_code VARCHAR(3) NOT NULL,
    
    -- origin_airport: Where the flight departs from
    -- FOREIGN KEY: Must match an airport_code in airports table
    origin_airport VARCHAR(3) NOT NULL,
    
    -- dest_airport: Where the flight arrives
    -- FOREIGN KEY: Must match an airport_code in airports table  
    dest_airport VARCHAR(3) NOT NULL,
    
    -- scheduled_departure: When flight is SUPPOSED to depart
    -- TIMESTAMP: Stores both date and time
    -- Example: '2024-01-15 08:30:00'
    scheduled_departure TIMESTAMP NOT NULL,
    
    -- scheduled_arrival: When flight is SUPPOSED to arrive
    scheduled_arrival TIMESTAMP NOT NULL,
    
    -- distance: Miles between origin and destination
    -- INTEGER: Whole number (no decimals needed)
    distance INTEGER,
    
    -- Now we define the FOREIGN KEY relationships:
    -- These create the links between tables
    
    FOREIGN KEY (airline_code) REFERENCES airlines(airline_code),
    FOREIGN KEY (origin_airport) REFERENCES airports(airport_code),
    FOREIGN KEY (dest_airport) REFERENCES airports(airport_code)
);

-- WHY THIS STRUCTURE?
-- - flight_id as SERIAL PRIMARY KEY: Auto-generated unique ID
-- - Three FOREIGN KEYS: Link to airlines and airports tables
-- - TIMESTAMP for times: Need both date and time
-- - INTEGER for distance: Don't need decimal precision for miles


-- ============================================
-- TABLE 4: flight_delays
-- ============================================
-- Purpose: Store actual delay information for each flight
-- Example: Flight AA123 was delayed 45 minutes due to weather

CREATE TABLE flight_delays (
    -- delay_id: Unique ID for each delay record
    -- SERIAL PRIMARY KEY: Auto-generated
    delay_id SERIAL PRIMARY KEY,
    
    -- flight_id: Which flight does this delay belong to?
    -- FOREIGN KEY: Links to flights table
    -- This is how we connect delay info to flight info
    flight_id INTEGER NOT NULL,
    
    -- actual_departure: When the flight ACTUALLY departed
    -- TIMESTAMP: Can be NULL if flight was cancelled
    actual_departure TIMESTAMP,
    
    -- actual_arrival: When the flight ACTUALLY arrived
    actual_arrival TIMESTAMP,
    
    -- departure_delay: How many minutes late at departure
    -- INTEGER: Positive = late, Negative = early, 0 = on time
    -- DEFAULT 0: If not specified, assume on time
    departure_delay INTEGER DEFAULT 0,
    
    -- arrival_delay: How many minutes late at arrival
    arrival_delay INTEGER DEFAULT 0,
    
    -- delay_reason: WHY was it delayed?
    -- Common reasons: 'Weather', 'Carrier', 'Security', 'Aircraft', 'Late Aircraft'
    delay_reason VARCHAR(50),
    
    -- cancelled: Was the flight cancelled?
    -- BOOLEAN: true or false
    -- DEFAULT false: Most flights are not cancelled
    cancelled BOOLEAN DEFAULT false,
    
    -- diverted: Was flight sent to different airport?
    -- BOOLEAN: true or false
    diverted BOOLEAN DEFAULT false,
    
    -- Define FOREIGN KEY relationship
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- WHY THIS STRUCTURE?
-- - delay_id as PRIMARY KEY: Each delay record is unique
-- - flight_id as FOREIGN KEY: Links each delay to a specific flight
-- - actual times can be NULL: Cancelled flights have no actual times
-- - DEFAULT 0 for delays: Most flights are on time
-- - BOOLEAN for yes/no questions: cancelled, diverted


-- ============================================
-- TABLE 5: weather
-- ============================================
-- Purpose: Store weather conditions at airports
-- Example: JFK had snow and 32°F on Jan 15, 2024

CREATE TABLE weather (
    -- weather_id: Unique ID for each weather record
    -- SERIAL PRIMARY KEY: Auto-generated
    weather_id SERIAL PRIMARY KEY,
    
    -- airport_code: Which airport's weather is this?
    -- FOREIGN KEY: Links to airports table
    airport_code VARCHAR(3) NOT NULL,
    
    -- date: Which day is this weather for?
    -- DATE: Only stores date, not time (YYYY-MM-DD)
    date DATE NOT NULL,
    
    -- temperature: Temperature in Fahrenheit
    -- INTEGER: Whole numbers are fine for temperature
    temperature INTEGER,
    
    -- precipitation: Inches of rain or snow
    -- DECIMAL(5,2): Example: 1.25 inches
    -- 5 total digits, 2 after decimal
    precipitation DECIMAL(5,2) DEFAULT 0.00,
    
    -- wind_speed: Wind speed in miles per hour
    -- INTEGER: Whole numbers
    wind_speed INTEGER DEFAULT 0,
    
    -- visibility: How far you can see in miles
    -- DECIMAL(5,2): Example: 10.50 miles
    visibility DECIMAL(5,2) DEFAULT 10.00,
    
    -- condition: Weather description
    -- VARCHAR(50): 'Clear', 'Rain', 'Snow', 'Fog', etc.
    condition VARCHAR(50),
    
    -- Define FOREIGN KEY relationship
    FOREIGN KEY (airport_code) REFERENCES airports(airport_code)
);

-- WHY THIS STRUCTURE?
-- - weather_id as PRIMARY KEY: Each weather record unique
-- - airport_code as FOREIGN KEY: Links to airports
-- - DATE not TIMESTAMP: We only care about the day, not specific time
-- - DECIMAL for precipitation/visibility: Need decimal precision
-- - DEFAULT values: Assume good weather if not specified


-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
-- Purpose: Make queries faster by creating indexes on frequently searched columns
-- Think of indexes like a book's index - helps find information quickly

-- Index on flight dates (we'll search by date often)
CREATE INDEX idx_flight_scheduled_departure ON flights(scheduled_departure);

-- Index on airline code (to quickly find all flights by an airline)
CREATE INDEX idx_flight_airline ON flights(airline_code);

-- Index on airports (to quickly find all flights from/to an airport)
CREATE INDEX idx_flight_origin ON flights(origin_airport);
CREATE INDEX idx_flight_dest ON flights(dest_airport);

-- Index on delay reasons (to analyze delay causes)
CREATE INDEX idx_delay_reason ON flight_delays(delay_reason);

-- Index on weather date and airport (to join with flights)
CREATE INDEX idx_weather_date_airport ON weather(date, airport_code);




