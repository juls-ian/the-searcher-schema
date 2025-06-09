-- ENUM type
CREATE TYPE staff_status AS ENUM ('active', 'inactive');
CREATE TYPE bulletin_category AS ENUM ('announcement', 'advisory', 'reminder');
CREATE TYPE multimedia_category AS ENUM ('announcement', 'advisory', 'reminder');
CREATE TYPE archive_category AS ENUM ('article', 'multimedia', 'issues', 'ed_board');

-- Staffs table
CREATE TABLE staffs (
    id SERIAL PRIMARY KEY,
    staff_id VARCHAR(100) UNIQUE NOT NULL, 
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    pen_name VARCHAR(100) UNIQUE NOT NULL,
    year_level INTEGER,
    course VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    edboard_position VARCHAR(100) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('admin', 'editor', 'staff')) NOT NULL DEFAULT 'staff',
    term VARCHAR(100), 
    status staff_status NOT NULL DEFAULT 'active',
    joined_at DATE,
    left_at DATE,
    password_hash VARCHAR(255) NOT NULL,
    profile_pic VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
    --UNIQUE(pen_name, email)
);

-- CREATE TABLE staff_roles (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(100) NOT NULL, 
--     role_desc TEXT
-- );

-- Categories table
CREATE TABLE articles_categories (
    id SERIAL PRIMARY KEY, 
    category VARCHAR(20) NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    parent_id INTEGER REFERENCES articles_categories(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Articles table
CREATE TABLE articles (
    id SERIAL PRIMARY KEY, 
    title VARCHAR(255) NOT NULL, 
    slug TEXT UNIQUE NOT NULL,
    category_id INTEGER REFERENCES articles_categories(id) ON DELETE CASCADE,
    writer_id INTEGER REFERENCES staffs(id),
    body TEXT NOT NULL,
    published_at TIMESTAMP,
    is_live BOOLEAN DEFAULT FALSE,
    article_series INTEGER REFERENCES articles(id) ON DELETE SET NULL, 
    is_header BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    cover_photo TEXT NOT NULL, -- path
    cover_artist INTEGER REFERENCES staffs(id),
    cover_caption VARCHAR(255),
    thumbnail TEXT, -- path
    thumbnail_artist INTEGER REFERENCES staffs(id),
    add_to_ticker BOOLEAN DEFAULT FALSE,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    archived_at TIMESTAMP 

);

CREATE TABLE calendar (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL, 
    slug TEXT UNIQUE NOT NULL,
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP,
    is_allday BOOLEAN DEFAULT FALSE,
    venue VARCHAR(255),
    details VARCHAR(255),
    is_public BOOLEAN DEFAULT FALSE,
    event_type VARCHAR(255), --release, meeting, event
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP

);


CREATE TABLE bulletin (
    id SERIAL PRIMARY KEY, 
    title VARCHAR(255) NOT NULL, 
    slug TEXT UNIQUE NOT NULL,
    posted_at TIMESTAMP NOT NULL,
    category bulletin_category NOT NULL,
    writer_id INTEGER REFERENCES staffs(id),
    details TEXT,
    cover_photo TEXT, 
    cover_artist INTEGER REFERENCES staffs(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP 
);

CREATE TABLE multimedia (
    id SERIAL PRIMARY KEY, 
    title VARCHAR(255),
    slug TEXT UNIQUE NOT NULL,
    category multimedia_category NOT NULL, 
    published_at TIMESTAMP,
    multimedia_files TEXT NOT NULL, --path
    multimedia_artist INT REFERENCES staffs(id) NOT NULL,
    thumbnail_photo TEXT NOT NULL, --path
    thumbnail_artist INT REFERENCES staffs(id) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP, 
    archived_at TIMESTAMP 
);

CREATE TABLE issues (
    issue_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    publication_date DATE NOT NULL,
    contributors TEXT NOT NULL,
    writers TEXT NOT NULL,
    photojournalists TEXT NOT NULL,
    artists TEXT NOT NULL,
    layout_artists TEXT NOT NULL, 
    editors TEXT NOT NULL,
    outsourced_photos TEXT NOT NULL,
    others TEXT,
    issue_file TEXT NOT NULL, -- path
    thumbnail TEXT NOT NULL, -- path
    is_archived BOOLEAN DEFAULT FALSE,
    archived_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP, 
    archived_at TIMESTAMP 
);

--data inserted with the staff creation form
CREATE TABLE editorial_boards (
    id SERIAL PRIMARY KEY,
    term VARCHAR(100) NOT NULL, --2024-2025...
    staff_id INTEGER REFERENCES staffs(id) ON DELETE CASCADE,
    role VARCHAR(100) NOT NULL,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE community_segments (
    id SERIAL PRIMARY KEY, 
    title VARCHAR(255) NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    segment_type VARCHAR(50), -- article or poll
    series_of VARCHAR(255) NOT NULL,
    writer_id INTEGER REFERENCES staffs(id) NOT NULL,
    series_order INT NULL,
    segment_cover TEXT NOT NULL, -- path 
    cover_artist INTEGER REFERENCES staffs(id),
    cover_caption VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,    
    archived_at TIMESTAMP 
);

CREATE TABLE segments_poll (
    segment_id SERIAL PRIMARY KEY REFERENCES community_segments(id) ON DELETE CASCADE, 
    question TEXT NOT NULL,
    options TEXT[] NOT NULL,
    duration INTERVAL NOT NULL
);

CREATE TABLE segments_article (
    segment_id SERIAL PRIMARY KEY REFERENCES community_segments(id) ON DELETE CASCADE,
    body TEXT NULL
);

CREATE TABLE newsletter (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    status VARCHAR(255),
    subscribed_on TIMESTAMP
);


