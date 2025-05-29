USE itf_tournaments;

CREATE TABLE Gender (
    gender_id INT PRIMARY KEY,
    code VARCHAR(10),
    description VARCHAR(10)
);

CREATE TABLE Country (
    country_id INT PRIMARY KEY,
    code VARCHAR(20),
    description VARCHAR(20)
);

CREATE TABLE AgeCategory (
    age_category_id INT PRIMARY KEY,
    code INT NOT NULL,
    description VARCHAR(20),
    min_age INT,
    max_age INT
);

CREATE TABLE TournamentCategory (
    category_id INT PRIMARY KEY,
    description VARCHAR(20),
    CHECK (category_id BETWEEN 1 AND 6),
    CHECK (description IN ('MT100', 'MT200', 'MT400', 'MT700', 'MT1000', 'WC')),
    CHECK (BINARY code = UPPER(code))
);

CREATE TABLE Location (
    location_id INT PRIMARY KEY,
    country_id INT,
    city VARCHAR(50),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

CREATE TABLE Venue (
    venue_id INT PRIMARY KEY,
    location_id INT,
    venue_name VARCHAR(100),
   FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Players (
    player_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birth_year INT,
    gender INT NOT NULL,
    country_id  INT,
    FOREIGN KEY (gender) REFERENCES Gender(gender_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

CREATE TABLE PlayerStatus (
    status_id INT PRIMARY KEY,
    status_description VARCHAR(20)
);

CREATE TABLE StageResults (
    id INT PRIMARY KEY,
    code VARCHAR(20),
    description VARCHAR(20)
);

CREATE TABLE PointsRules (
    points_id INT PRIMARY KEY,
    category_id INT,
    stage_result_id INT,
    points INT,
    FOREIGN KEY (category_id) REFERENCES TournamentCategory(category_id),
    FOREIGN KEY (stage_result_id) REFERENCES StageResults(id)
);

CREATE TABLE SeedingRules (
    id INT PRIMARY KEY,
    min_players INT,
    max_players INT,
    num_seeds INT
);

CREATE TABLE MatchRound (
    round_id INT PRIMARY KEY,
    code VARCHAR(10),
    label VARCHAR(50)
);

CREATE TABLE Tournaments (
    tournament_id INT PRIMARY KEY,
    name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    tournament_year INT,
    tournament_week INT,
    venue_id INT,
    category_id INT,
    FOREIGN KEY (venue_id) REFERENCES Venue(venue_id),
    FOREIGN KEY (category_id) REFERENCES TournamentCategory(category_id),
    CHECK (end_date > start_date)
);

CREATE TABLE Draws (
    draw_id INT PRIMARY KEY AUTO_INCREMENT,
    tournament_id INT NOT NULL,
    age_category INT NOT NULL,
    gender INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    num_players INT NOT NULL,
    draw_status ENUM('Scheduled', 'Cancelled') DEFAULT 'Scheduled', 
    FOREIGN KEY (tournament_id) REFERENCES Tournaments(tournament_id),
    FOREIGN KEY (age_category) REFERENCES AgeCategory(age_category_id),
    FOREIGN KEY (gender) REFERENCES Gender(gender_id),
    CHECK (num_players BETWEEN 1 AND 128)
);

CREATE TABLE DrawPlayers (
    draw_id INT NOT NULL,
    player_id INT NOT NULL,
    PRIMARY KEY (draw_id, player_id),
    FOREIGN KEY (draw_id) REFERENCES Draws(draw_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

CREATE TABLE DrawSeed (
    draw_id INT,
    player_id INT,
    seed_number INT,
    is_actual_seeding BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (draw_id, player_id),
    UNIQUE (draw_id, seed_number),
    FOREIGN KEY (draw_id) REFERENCES Draws(draw_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

CREATE TABLE Matches (
    match_id INT PRIMARY KEY,
    draw_id INT,
    match_status ENUM('OK', 'Abandoned', 'Suspended') DEFAULT 'OK',
    round_id INT,
    player1_id INT,
    player2_id INT NULL,
    winner_id INT NULL,
    player1_status_id INT,
    player2_status_id INT NULL,
    set1_player1 INT,
    set1_player2 INT,
    set1_player1_tiebreak INT,
    set1_player2_tiebreak INT,
    set2_player1 INT,
    set2_player2 INT,
    set2_player1_tiebreak INT,
    set2_player2_tiebreak INT,
    supertiebreak_player1 INT DEFAULT NULL,
    supertiebreak_player2 INT DEFAULT NULL,
    match_date DATE NULL
    FOREIGN KEY (draw_id) REFERENCES Draws(draw_id),
    FOREIGN KEY (round_id) REFERENCES MatchRound(round_id),
    FOREIGN KEY (player1_id) REFERENCES Players(player_id),
    FOREIGN KEY (player2_id) REFERENCES Players(player_id),
    FOREIGN KEY (winner_id) REFERENCES Players(player_id),
    FOREIGN KEY (player1_status_id) REFERENCES PlayerStatus(status_id),
    FOREIGN KEY (player2_status_id) REFERENCES PlayerStatus(status_id),
    CHECK (supertiebreak_player1 IS NULL OR supertiebreak_player1 >= 0),
    CHECK (supertiebreak_player2 IS NULL OR supertiebreak_player2 >= 0)
);

CREATE TABLE InitialRanking (
  player_id INT NOT NULL,
  age_category_id INT NOT NULL,
  total_points INT NOT NULL,
  ranking_year INT NOT NULL,
  ranking_week INT NOT NULL,
  PRIMARY KEY (player_id, age_category_id, ranking_year, ranking_week),
  FOREIGN KEY (player_id) REFERENCES Players(player_id),
  FOREIGN KEY (age_category_id) REFERENCES AgeCategory(age_category_id)
);

CREATE TABLE WeeklyRanking (
  player_id INT NOT NULL,
  age_category_id INT NOT NULL,
  gender_id INT NOT NULL,
  ranking_year INT NOT NULL,
  ranking_week INT NOT NULL,
  total_points INT NOT NULL,
  rank_position INT NOT NULL,
  PRIMARY KEY (player_id, age_category_id, gender_id, ranking_year, ranking_week),
  FOREIGN KEY (player_id) REFERENCES Players(player_id),
  FOREIGN KEY (age_category_id) REFERENCES AgeCategory(age_category_id),
  FOREIGN KEY (gender_id) REFERENCES Gender(gender_id)
);

CREATE TABLE PointsHistory (
    id INT PRIMARY KEY,
    player_id INT NOT NULL,
    tournament_id INT NOT NULL,
    age_category_id INT NOT NULL,
    stage_result_id INT NOT NULL,
    FOREIGN KEY (age_category_id) REFERENCES AgeCategory(age_category_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
    FOREIGN KEY (tournament_id) REFERENCES Tournaments(tournament_id),
    FOREIGN KEY (stage_result_id) REFERENCES StageResults(id)
);


