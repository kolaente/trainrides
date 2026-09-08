CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL COLLATE NOCASE,
  password_hash TEXT,
  salt TEXT,
  iterations INTEGER,
  created_at TEXT NOT NULL,
  CHECK ((password_hash IS NULL AND salt IS NULL AND iterations IS NULL)
    OR (password_hash IS NOT NULL AND salt IS NOT NULL AND iterations > 0))
);
CREATE TABLE sessions (
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TEXT NOT NULL,
  expires_at TEXT NOT NULL
);
CREATE TABLE ride_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  color TEXT NOT NULL,
  created_at TEXT NOT NULL
);
CREATE TABLE rides (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES users(id),
  origin TEXT NOT NULL,
  destination TEXT NOT NULL,
  price REAL NOT NULL,
  type_id INTEGER REFERENCES ride_types(id) ON DELETE SET NULL,
  date TEXT NOT NULL,
  details TEXT,
  created_at TEXT NOT NULL
);
CREATE TABLE db_lounges (
  id INTEGER PRIMARY KEY,
  location TEXT NOT NULL,
  anchor TEXT NOT NULL
);
CREATE TABLE db_lounge_visits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL REFERENCES users(id),
  db_lounge_id INTEGER NOT NULL REFERENCES db_lounges(id),
  visited_at TEXT NOT NULL,
  created_at TEXT
);
CREATE INDEX rides_user_date ON rides(user_id, date DESC);
CREATE INDEX visits_user_lounge ON db_lounge_visits(user_id, db_lounge_id);
