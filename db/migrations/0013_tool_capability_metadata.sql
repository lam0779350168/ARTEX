-- Capability/risk/health metadata for the executable tool catalog.
ALTER TABLE tools ADD COLUMN IF NOT EXISTS capability TEXT NOT NULL DEFAULT '';
ALTER TABLE tools ADD COLUMN IF NOT EXISTS risk TEXT NOT NULL DEFAULT '';
ALTER TABLE tools ADD COLUMN IF NOT EXISTS timeout_sec INTEGER NOT NULL DEFAULT 120;
ALTER TABLE tools ADD COLUMN IF NOT EXISTS healthy BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE tools ADD COLUMN IF NOT EXISTS last_health TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS tools_capability_healthy_idx ON tools (capability, healthy);
