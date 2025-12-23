CREATE TABLE phd_applications (
    id SERIAL PRIMARY KEY,
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
    recommendation TEXT, -- APPLY / CONSIDER / SKIP
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
    status TEXT DEFAULT 'pending', -- pending / applied / rejected / interview
    user_rating TEXT, -- excellent / good / poor
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_score ON phd_applications(final_score DESC);
CREATE INDEX idx_deadline ON phd_applications(deadline);
CREATE INDEX idx_status ON phd_applications(status);