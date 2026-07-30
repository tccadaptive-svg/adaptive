/*
  # AdaptiveMove - Security Fix + Bot Messages Table

  ## 1. Fix privilege-escalation gap
  The existing "Users can update own profile" policy only checks row
  ownership (auth.uid() = id), not which columns changed. That means any
  authenticated user could call:
    supabase.from('users').update({ role: 'admin' }).eq('id', user.id)
  and grant themselves admin access, since RLS has no column-level check.

  Fix: a BEFORE UPDATE trigger silently reverts `role` back to its previous
  value unless the acting user already has the 'admin' role. This preserves
  every other self-service profile update (name, bio, avatar, plan_id for
  the demo "subscribe" flow, accessibility settings, etc.) while closing the
  escalation path.

  ## 2. Bot messages table
  The Messages page ships with 3 virtual assistant "bots"
  (bot-assistant / bot-coach / bot-nutrition) that only exist as frontend
  constants — they were never rows in `users`. The `messages` table has
  `sender_id`/`receiver_id uuid NOT NULL REFERENCES users(id)`, so every
  attempt to persist a message to/from a bot fails at the database level
  (invalid uuid / FK violation), and the UI swallows the error, so bot
  conversations silently do nothing.

  Rather than fabricating fake `users`/`auth.users` rows for bots (which
  would require inserting into Supabase's managed `auth.users` table), this
  adds a dedicated `bot_messages` table — the same pattern already used for
  `ai_chat_messages` — decoupled from the human-to-human `messages` FK
  constraints.
*/

-- =====================
-- 1. PREVENT SELF-SERVICE ROLE ESCALATION
-- =====================
CREATE OR REPLACE FUNCTION prevent_role_self_escalation()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    IF NOT EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ) THEN
      NEW.role := OLD.role;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS enforce_no_role_self_escalation ON users;
CREATE TRIGGER enforce_no_role_self_escalation
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION prevent_role_self_escalation();

-- =====================
-- 2. BOT MESSAGES TABLE
-- =====================
CREATE TABLE IF NOT EXISTS bot_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  bot_id text NOT NULL CHECK (bot_id IN ('bot-assistant', 'bot-coach', 'bot-nutrition')),
  role text NOT NULL CHECK (role IN ('user', 'bot')),
  content text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS bot_messages_user_bot_idx ON bot_messages (user_id, bot_id, created_at);

ALTER TABLE bot_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own bot messages"
  ON bot_messages FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bot messages"
  ON bot_messages FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bot messages"
  ON bot_messages FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
