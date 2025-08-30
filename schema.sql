-- ENUM type
CREATE TYPE staff_status AS ENUM ('active', 'inactive');
CREATE TYPE bulletin_category AS ENUM ('announcement', 'advisory', 'reminder');
CREATE TYPE multimedia_category AS ENUM ('announcement', 'advisory', 'reminder');
CREATE TYPE archive_category AS ENUM ('article', 'multimedia', 'issues', 'ed_board');

-- Staffs table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    staff_id VARCHAR(100) UNIQUE NOT NULL, 
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    full_name_slug TEXT UNIQUE NOT NULL,
    pen_name VARCHAR(100) UNIQUE NOT NULL,
    pen_name_slug TEXT UNIQUE NOT NULL,
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

CREATE TABLE editorial_boards (
    id SERIAL PRIMARY KEY,
    term VARCHAR(100) NOT NULL, --2024-2025...
    staff_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    is_current BOOLEAN,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
    writer_id INTEGER REFERENCES users(id),
    body TEXT NOT NULL,
    published_at TIMESTAMP,
    is_live BOOLEAN DEFAULT FALSE,
    article_series INTEGER REFERENCES articles(id) ON DELETE SET NULL, 
    is_header BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    cover_photo TEXT NOT NULL, -- path
    cover_artist_id INTEGER REFERENCES users(id),
    cover_credit_type VARCHAR(20),
    cover_caption VARCHAR(255),
    thumbnail TEXT, -- path
    thumbnail_artist_id INTEGER REFERENCES users(id),
    add_to_ticker BOOLEAN DEFAULT FALSE,
    ticker_expires_at DATE,
    publisher_id INTEGER REFERENCES users(id),
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
    is_perpetual BOOLEAN DEFAULT FALSE, -- is all day?
    venue TEXT,
    details TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    event_type VARCHAR(50) CHECK (event_type IN  ('release', 'meeting', 'event')), --release, meeting, event
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE bulletin (
    id SERIAL PRIMARY KEY, 
    title VARCHAR(255) NOT NULL, 
    slug TEXT UNIQUE NOT NULL,
    published_at TIMESTAMP NOT NULL,
    category bulletin_category NOT NULL,
    writer_id INTEGER REFERENCES users(id),
    details TEXT,
    cover_photo TEXT, 
    cover_artist_id INTEGER REFERENCES users(id),
    publisher_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP 
);

CREATE TABLE multimedia (
    id SERIAL PRIMARY KEY, 
    title VARCHAR(255),
    slug TEXT UNIQUE NOT NULL,
    caption VARCHAR(255),
    category multimedia_category NOT NULL, 
    published_at TIMESTAMP,
    files TEXT NOT NULL, --path
    multimedia_artist INT REFERENCES users(id) NOT NULL,
    files_credit_type VARCHAR(20),
    thumbnail_photo TEXT NOT NULL, --path
    thumbnail_artist_id INT REFERENCES users(id) NOT NULL,
    publisher_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP, 
    archived_at TIMESTAMP 
);

CREATE TABLE multimedia_user (
    id SERIAL PRIMARY KEY,
    multimedia_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP, 

    CONSTRAINT fk_multimedia_user_multimedia_id
        FOREIGN KEY (multimedia_id)
        REFERENCES multimedia(id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_multimedia_user_user_id
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,
    
    CONSTRAINT unique_multimedia_user
        UNIQUE (multimedia_id, user_id)

);

CREATE TABLE issues (
    issue_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    publication_date DATE NOT NULL,
    editors TEXT NOT NULL,
    writers TEXT NOT NULL,
    photojournalists TEXT NOT NULL,
    artists TEXT NOT NULL,
    layout_artists TEXT NOT NULL, 
    contributors TEXT NOT NULL,
    issue_file TEXT NOT NULL, -- path
    thumbnail TEXT NOT NULL, -- path
    is_archived BOOLEAN DEFAULT FALSE,
    archived_at TIMESTAMP,
    publisher_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP, 
    archived_at TIMESTAMP 
);

--data inserted with the staff creation form

CREATE TABLE community_segments (
    id SERIAL PRIMARY KEY, 
    title VARCHAR(255) NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    segment_type VARCHAR(50) CHECK (segment_type IN ('article', 'poll')), -- article or poll
    series_of INTEGER REFERENCES community_segments(id),
    writer_id INTEGER REFERENCES users(id) NOT NULL,
    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    series_order INT NULL,
    segment_cover TEXT NOT NULL, -- path 
    cover_caption VARCHAR(255) NULL,
    cover_artist_id INTEGER REFERENCES users(id),
    credit_type VARCHAR(20),
    publisher_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,    
    archived_at TIMESTAMP 
);


CREATE TABLE segments_poll (
    id SERIAL PRIMARY KEY,
    segment_id INTEGER PRIMARY KEY REFERENCES community_segments(id) ON DELETE CASCADE, 
    question TEXT NOT NULL,
    options TEXT[] NOT NULL,
    ends_at INTERVAL NOT NULL
);

CREATE TABLE segments_article (
    id SERIAL PRIMARY KEY,
    segment_id INTEGER PRIMARY KEY REFERENCES community_segments(id) ON DELETE CASCADE,
    body TEXT NULL
);

CREATE TABLE archives (
    id SERIAL PRIMARY KEY, 
    archivable_type VARCHAR(255) NOT NULL, -- models
    archivable_id BIGINT NOT NULL, -- record's primary key 
    title VARCHAR(255) NULL, -- most common searchable field 
    slug VARCHAR(255), 
    data JSONB NOT NULL, -- full snapshot of original record 
    archived_at TIMESTAMPTZ  NOT NULL, 
    archiver_id INTEGER REFERENCES users(id) NOT NULL, 
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

        -- Add useful indexes
    CONSTRAINT archives_archivable_unique UNIQUE (archivable_type, archivable_id),
    INDEX idx_archives_archivable (archivable_type, archivable_id),
    INDEX idx_archives_archived_at (archived_at),
    INDEX idx_archives_title (title),
    INDEX idx_archives_slug (slug)
);


CREATE TABLE newsletter (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    status VARCHAR(255),
    subscribed_on TIMESTAMP
);





