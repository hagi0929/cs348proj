-- DROP TABLE ServiceUser;
-- DROP TABLE Problem;
-- DROP TABLE TestCase;

CREATE TABLE ServiceUser (
    user_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE Problem (
    problem_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    difficulty INT CHECK (difficulty BETWEEN 0 AND 20) NOT NULL,
    created_by INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (created_by) REFERENCES ServiceUser(user_id) ON DELETE SET NULL
);

CREATE TABLE TestCase (
    testcase_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    problem_id INT NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    input TEXT NOT NULL,
    output TEXT NOT NULL,
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id) ON DELETE CASCADE
);

CREATE TABLE Contest (
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

CREATE TABLE ContestProblem (
    problem_id INT PRIMARY KEY,
    contest_id INT,
    FOREIGN KEY (contest_id) REFERENCES Contest(contest_id),
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id)
);

CREATE TABLE ContestParticipant (
    contest_id INT,
    participant_id INT,
    PRIMARY KEY (contest_id, participant_id),
    FOREIGN KEY (contest_id) REFERENCES Contest(contest_id),
    FOREIGN KEY (participant_id) REFERENCES ServiceUser(user_id)
);

CREATE TABLE ContestProblemSubmission (
    submission_id INT PRIMARY KEY,
    participant_id INT,
    problem_id INT,
    submission TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (problem_id) REFERENCES Problem(problem_id),
    FOREIGN KEY (participant_id) REFERENCES ServiceUser(user_id)
);
