DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS moves;

CREATE TABLE games (
  gameid INTEGER,
  row INT,
  col INT,
  p1token CHAR(1),
  p2token CHAR(1),
  p1pat CHAR(20),
  p2pat CHAR(20),
  p1id CHAR(20),
  -- player 2 can be empty
  p2id CHAR(20),
  finished INT,
  PRIMARY KEY(gameid)
);

CREATE TABLE players (
  uname CHAR(20),
  password CHAR(20),
  PRIMARY KEY(uname)
);

CREATE TABLE moves (
  gid INT,
  playerid CHAR(20),
  n INT,
  col INT,
  FOREIGN KEY (gid) REFERENCES Games(gameid)
);