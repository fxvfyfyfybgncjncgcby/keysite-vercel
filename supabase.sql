-- Colle ce SQL dans Supabase > SQL Editor

CREATE TABLE keys (
  id           BIGSERIAL PRIMARY KEY,
  key_value    TEXT NOT NULL UNIQUE,
  hwid         TEXT,
  ip           TEXT NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now(),
  expires_at   TIMESTAMPTZ NOT NULL
);

CREATE TABLE pending_tokens (
  id           BIGSERIAL PRIMARY KEY,
  token        TEXT NOT NULL UNIQUE,
  ip           TEXT NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now(),
  expires_at   TIMESTAMPTZ NOT NULL
);

-- Index pour accélérer les requêtes
CREATE INDEX ON keys (key_value);
CREATE INDEX ON keys (ip);
CREATE INDEX ON pending_tokens (token);
