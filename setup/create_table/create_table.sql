CREATE TABLE IF NOT EXISTS Role (
    role_id INT GENERATED ALWAYS AS IDENTITY,
    role_name VARCHAR(50),
    PRIMARY KEY(role_id)
);

CREATE TABLE IF NOT EXISTS Permission (
    permission_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS RolePermission (
    role_id INT REFERENCES Role(role_id),
    permission_id INT REFERENCES Permission(permission_id),
    PRIMARY KEY(role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS ServiceUser (
    user_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    role_id INT REFERENCES Role(role_id),
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Problem (
    problem_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    created_by INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (created_by) REFERENCES ServiceUser(user_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS TestCase (
    testcase_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    problem_id INT NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    input TEXT NOT NULL,
    output TEXT NOT NULL,
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Tag(
    tag_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    type TEXT NOT NULL,
    content TEXT NOT NULL
    CONSTRAINT chk_type CHECK (type IN ('difficulty', 'source', 'subcategory'))
);

CREATE TABLE IF NOT EXISTS ProblemTag (
    problem_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (problem_id, tag_id),
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES Tag(tag_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Discussion (
    discussion_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    problem_id INT NOT NULL,
    parentdiscussion_id INT DEFAULT NULL,
    user_id INT NOT NULL,
    title VARCHAR(500) DEFAULT NULL,
    content VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (parentdiscussion_id) REFERENCES Discussion(discussion_id),
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES ServiceUser(user_id)
);

CREATE TABLE IF NOT EXISTS Contest (
    contest_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    winner INT,
    FOREIGN KEY (created_by) REFERENCES ServiceUser(user_id),
    FOREIGN KEY (winner) REFERENCES ServiceUser(user_id)
);

CREATE TABLE IF NOT EXISTS ContestProblem (
    problem_id INT PRIMARY KEY,
    contest_id INT,
    FOREIGN KEY (contest_id) REFERENCES Contest(contest_id),
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id)
);

CREATE TABLE IF NOT EXISTS ContestParticipant (
    contest_id INT,
    participant_id INT,
    PRIMARY KEY (contest_id, participant_id),
    FOREIGN KEY (contest_id) REFERENCES Contest(contest_id),
    FOREIGN KEY (participant_id) REFERENCES ServiceUser(user_id)
);

CREATE TABLE IF NOT EXISTS ContestProblemSubmission (
    submission_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    participant_id INT,
    problem_id INT,
    submission TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id),
    FOREIGN KEY (participant_id) REFERENCES ServiceUser(user_id)
);

CREATE TABLE PopupResource (
    resource_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    resource_name VARCHAR(255) NOT NULL,
    resource_description TEXT,
    resource_url VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    homepage TEXT,
    size INT,
    stars INT,
    forks INT,
    issues INT,
    watchers INT,
    resource_language VARCHAR(255),
    license VARCHAR(255),
    topics TEXT,
    has_issues BOOLEAN,
    has_projects BOOLEAN,
    has_downloads BOOLEAN,
    has_wiki BOOLEAN,
    has_pages BOOLEAN,
    has_discussions BOOLEAN,
    is_fork BOOLEAN,
    is_archived BOOLEAN,
    is_template BOOLEAN,
    default_branch VARCHAR(255)
);

CREATE MATERIALIZED VIEW PopupResourcesView AS
SELECT 
    resource_id, 
    resource_name, 
    resource_description, 
    resource_url, 
    homepage,
    stars,
    resource_language,
    topics
FROM PopupResource;

CREATE INDEX idx_tag_type_content ON Tag (type, content);
CREATE INDEX idx_problem_tag_problem_id ON ProblemTag (problem_id);
CREATE INDEX idx_problem_tag_tag_id ON ProblemTag (tag_id);
CREATE INDEX idx_tag_tag_id ON Tag (tag_id);
CREATE INDEX idx_discussion_problem_discussion ON Discussion (problem_id, discussion_id);