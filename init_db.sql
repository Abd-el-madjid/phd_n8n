-- drop VIEW IF EXISTS unprocessed_sources;
-- drop VIEW IF EXISTS collection_stats;

-- drop TABLE IF EXISTS phd_applications;
-- drop TABLE IF EXISTS phd_sources;


-- Table 1: PhD Sources (collected by agent)
CREATE TABLE IF NOT EXISTS phd_sources (
    id SERIAL PRIMARY KEY,
    url TEXT UNIQUE NOT NULL,
    full_url TEXT,
    title TEXT,
    category TEXT, -- university, job_board, research_institute
    
    -- Quality metrics
    relevance_score INTEGER,
    quality_score INTEGER,
    
    -- Metadata
    search_query TEXT,
    contact_emails TEXT[],
    validation_reason TEXT,
    
    -- Tracking
    status TEXT DEFAULT 'active', -- active, processed, inactive
    times_found INTEGER DEFAULT 1,
    last_checked TIMESTAMP DEFAULT NOW(),
    last_processed TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- Table 2: PhD Applications (from main workflow)
CREATE TABLE IF NOT EXISTS phd_applications (
    id SERIAL PRIMARY KEY,
    source_id INTEGER REFERENCES phd_sources(id),
    
    title TEXT NOT NULL,
    university TEXT NOT NULL,
    country TEXT,
    domain TEXT,
    supervisor TEXT,
    lab TEXT,
    
    -- Scores
    similarity_score FLOAT,
    llm_score INTEGER,
    final_score INTEGER,
    
    -- Match details
    recommendation TEXT,
    strengths TEXT[],
    missing_requirements TEXT[],
    justification TEXT,
    
    -- Position details
    requirements TEXT[],
    preferred_skills TEXT[],
    deadline DATE,
    funded BOOLEAN,
    start_date TEXT,
    url TEXT UNIQUE,
    
    -- Application materials
    motivation_paragraph TEXT,
    email_subject TEXT,
    email_body TEXT,
    
    -- Tracking
    status TEXT DEFAULT 'pending',
    user_rating TEXT,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_sources_status ON phd_sources(status);
CREATE INDEX IF NOT EXISTS idx_sources_category ON phd_sources(category);
CREATE INDEX IF NOT EXISTS idx_sources_quality ON phd_sources(quality_score DESC);
CREATE INDEX IF NOT EXISTS idx_sources_created ON phd_sources(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_applications_score ON phd_applications(final_score DESC);
CREATE INDEX IF NOT EXISTS idx_applications_deadline ON phd_applications(deadline);
CREATE INDEX IF NOT EXISTS idx_applications_status ON phd_applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_source ON phd_applications(source_id);

-- View: High-quality unprocessed sources
CREATE OR REPLACE VIEW unprocessed_sources AS
SELECT *
FROM phd_sources
WHERE status = 'active'
  AND last_processed IS NULL
  AND quality_score >= 5
ORDER BY quality_score DESC, created_at DESC;

-- View: Collection statistics
CREATE OR REPLACE VIEW collection_stats AS
SELECT 
    COUNT(*) as total_sources,
    COUNT(*) FILTER (WHERE category = 'university') as universities,
    COUNT(*) FILTER (WHERE category = 'job_board') as job_boards,
    COUNT(*) FILTER (WHERE category = 'research_institute') as institutes,
    COUNT(*) FILTER (WHERE last_processed IS NOT NULL) as processed,
    COUNT(*) FILTER (WHERE last_processed IS NULL) as pending,
    AVG(quality_score) as avg_quality,
    MAX(created_at) as last_added
FROM phd_sources
WHERE status = 'active';