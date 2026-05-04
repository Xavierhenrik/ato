-- Sprint 1 — Criação das tabelas da aplicação + colunas novas
-- Estratégia: CREATE TABLE IF NOT EXISTS em tudo; ADD COLUMN IF NOT EXISTS nas existentes.
-- NÃO dropa nenhuma tabela ETL (legal_articles, question_bank, etc.).
-- FK de simulado_questions/user_question_answered → questions é omitida por incompatibilidade
-- de tipos (questions.id é UUID no ETL; demais tabelas usam TEXT — padrão Prisma).

-- ── users ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "users" (
  "id"          TEXT        NOT NULL,
  "supabase_id" TEXT        NOT NULL,
  "email"       TEXT        NOT NULL,
  "created_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updated_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "users_supabase_id_key" ON "users"("supabase_id");
CREATE UNIQUE INDEX IF NOT EXISTS "users_email_key"        ON "users"("email");

-- ── profiles ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "profiles" (
  "id"                    TEXT        NOT NULL,
  "user_id"               TEXT        NOT NULL,
  "name"                  TEXT        NOT NULL,
  "avatar_url"            TEXT,
  "study_goal"            TEXT,
  "academic_phase"        TEXT,
  "daily_study_mins"      INTEGER,
  "selected_subjects"     JSONB,
  "onboarding_step"       INTEGER     NOT NULL DEFAULT 0,
  "onboarding_done"       BOOLEAN     NOT NULL DEFAULT false,
  "nivelamento_pendente"  BOOLEAN     NOT NULL DEFAULT false,
  "nivelamento_concluido" BOOLEAN     NOT NULL DEFAULT false,
  "nivelamento_path"      TEXT,
  "streak_days"           INTEGER     NOT NULL DEFAULT 0,
  "longest_streak"        INTEGER     NOT NULL DEFAULT 0,
  "last_study_date"       TIMESTAMPTZ,
  "notif_enabled"         BOOLEAN     NOT NULL DEFAULT true,
  "notif_time"            TEXT,
  "onesignal_player_id"   TEXT,
  "created_at"            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updated_at"            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "profiles_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "profiles_user_id_key" ON "profiles"("user_id");

-- ── study_plans ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "study_plans" (
  "id"           TEXT        NOT NULL,
  "user_id"      TEXT        NOT NULL,
  "goal"         TEXT        NOT NULL,
  "duration_days" INTEGER    NOT NULL,
  "daily_mins"   INTEGER     NOT NULL,
  "areas"        JSONB       NOT NULL,
  "generated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "study_plans_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "study_plans_user_id_key" ON "study_plans"("user_id");

-- ── subscriptions ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "subscriptions" (
  "id"            TEXT        NOT NULL,
  "user_id"       TEXT        NOT NULL,
  "plan"          TEXT        NOT NULL DEFAULT 'free',
  "revenuecat_id" TEXT,
  "status"        TEXT        NOT NULL DEFAULT 'active',
  "expires_at"    TIMESTAMPTZ,
  "activated_at"  TIMESTAMPTZ,
  "created_at"    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updated_at"    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "subscriptions_user_id_key"       ON "subscriptions"("user_id");
CREATE UNIQUE INDEX IF NOT EXISTS "subscriptions_revenuecat_id_key" ON "subscriptions"("revenuecat_id");

-- ── topics ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "topics" (
  "id"         TEXT        NOT NULL,
  "code"       TEXT        NOT NULL,
  "title"      TEXT        NOT NULL,
  "law_code"   TEXT        NOT NULL,
  "chapter"    TEXT,
  "content"    TEXT        NOT NULL,
  "order"      INTEGER     NOT NULL,
  "is_pro"     BOOLEAN     NOT NULL DEFAULT false,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "topics_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "topics_code_key"      ON "topics"("code");
CREATE INDEX        IF NOT EXISTS "topics_law_code_idx"  ON "topics"("law_code");

-- ── tutor_sessions ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "tutor_sessions" (
  "id"         TEXT        NOT NULL,
  "user_id"    TEXT        NOT NULL,
  "mode"       TEXT        NOT NULL,
  "topic_id"   TEXT,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "ended_at"   TIMESTAMPTZ,
  "msg_count"  INTEGER     NOT NULL DEFAULT 0,
  CONSTRAINT "tutor_sessions_pkey" PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "tutor_sessions_user_id_idx" ON "tutor_sessions"("user_id");

-- ── tutor_messages ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "tutor_messages" (
  "id"         TEXT        NOT NULL,
  "session_id" TEXT        NOT NULL,
  "role"       TEXT        NOT NULL,
  "content"    TEXT        NOT NULL,
  "sources"    JSONB,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "tutor_messages_pkey" PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "tutor_messages_session_id_idx" ON "tutor_messages"("session_id");

-- ── simulado_attempts ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "simulado_attempts" (
  "id"          TEXT        NOT NULL,
  "user_id"     TEXT        NOT NULL,
  "mode"        TEXT        NOT NULL,
  "status"      TEXT        NOT NULL DEFAULT 'in_progress',
  "subjects"    JSONB,
  "total_q"     INTEGER     NOT NULL,
  "correct_q"   INTEGER     NOT NULL DEFAULT 0,
  "score"       FLOAT,
  "started_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "completed_at" TIMESTAMPTZ,
  CONSTRAINT "simulado_attempts_pkey" PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "simulado_attempts_user_id_idx" ON "simulado_attempts"("user_id");

-- ── simulado_questions ────────────────────────────────────────────────────────
-- Nota: question_id é TEXT aqui (Prisma padrão); questions.id é UUID (ETL).
-- FK entre os dois é omitida propositalmente por incompatibilidade de tipos.
CREATE TABLE IF NOT EXISTS "simulado_questions" (
  "id"              TEXT        NOT NULL,
  "attempt_id"      TEXT        NOT NULL,
  "question_id"     TEXT        NOT NULL,
  "order"           INTEGER     NOT NULL,
  "student_answer"  TEXT,
  "is_correct"      BOOLEAN,
  "time_spent_secs" INTEGER,
  "answered_at"     TIMESTAMPTZ,
  CONSTRAINT "simulado_questions_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "simulado_questions_attempt_id_question_id_key"
  ON "simulado_questions"("attempt_id", "question_id");

-- ── user_question_answered ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "user_question_answered" (
  "id"          TEXT        NOT NULL,
  "user_id"     TEXT        NOT NULL,
  "question_id" TEXT        NOT NULL,
  "answered_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "user_question_answered_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "user_question_answered_user_id_question_id_key"
  ON "user_question_answered"("user_id", "question_id");
CREATE INDEX IF NOT EXISTS "user_question_answered_user_id_idx"
  ON "user_question_answered"("user_id");

-- ── annotations ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "annotations" (
  "id"          TEXT        NOT NULL,
  "user_id"     TEXT        NOT NULL,
  "topic_id"    TEXT,
  "law_code"    TEXT,
  "article_ref" TEXT,
  "content"     TEXT        NOT NULL,
  "highlight"   TEXT,
  "title"       TEXT,
  "tags"        JSONB,
  "subject"     TEXT,
  "created_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updated_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "annotations_pkey" PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "annotations_user_id_idx" ON "annotations"("user_id");

-- ── topic_reads ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS "topic_reads" (
  "id"       TEXT        NOT NULL,
  "user_id"  TEXT        NOT NULL,
  "topic_id" TEXT        NOT NULL,
  "read_at"  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT "topic_reads_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "topic_reads_user_id_topic_id_key"
  ON "topic_reads"("user_id", "topic_id");
CREATE INDEX IF NOT EXISTS "topic_reads_user_id_idx" ON "topic_reads"("user_id");

-- ── Sprint 1 — colunas novas em questions (ETL table existente) ───────────────
ALTER TABLE "questions"
  ADD COLUMN IF NOT EXISTS "type"     TEXT NOT NULL DEFAULT 'simulado',
  ADD COLUMN IF NOT EXISTS "source"   TEXT NOT NULL DEFAULT 'oab_exam',
  ADD COLUMN IF NOT EXISTS "topic_id" TEXT,
  ADD COLUMN IF NOT EXISTS "status"   TEXT NOT NULL DEFAULT 'active';

CREATE INDEX IF NOT EXISTS "questions_topic_id_idx" ON "questions"("topic_id");

-- ── FKs entre tabelas da aplicação ───────────────────────────────────────────
DO $$
BEGIN
  -- profiles → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'profiles_user_id_fkey') THEN
    ALTER TABLE "profiles" ADD CONSTRAINT "profiles_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- study_plans → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'study_plans_user_id_fkey') THEN
    ALTER TABLE "study_plans" ADD CONSTRAINT "study_plans_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- subscriptions → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'subscriptions_user_id_fkey') THEN
    ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- tutor_sessions → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'tutor_sessions_user_id_fkey') THEN
    ALTER TABLE "tutor_sessions" ADD CONSTRAINT "tutor_sessions_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- tutor_messages → tutor_sessions
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'tutor_messages_session_id_fkey') THEN
    ALTER TABLE "tutor_messages" ADD CONSTRAINT "tutor_messages_session_id_fkey"
      FOREIGN KEY ("session_id") REFERENCES "tutor_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- simulado_attempts → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'simulado_attempts_user_id_fkey') THEN
    ALTER TABLE "simulado_attempts" ADD CONSTRAINT "simulado_attempts_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- simulado_questions → simulado_attempts
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'simulado_questions_attempt_id_fkey') THEN
    ALTER TABLE "simulado_questions" ADD CONSTRAINT "simulado_questions_attempt_id_fkey"
      FOREIGN KEY ("attempt_id") REFERENCES "simulado_attempts"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- user_question_answered → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'user_question_answered_user_id_fkey') THEN
    ALTER TABLE "user_question_answered" ADD CONSTRAINT "user_question_answered_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- annotations → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'annotations_user_id_fkey') THEN
    ALTER TABLE "annotations" ADD CONSTRAINT "annotations_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- annotations → topics
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'annotations_topic_id_fkey') THEN
    ALTER TABLE "annotations" ADD CONSTRAINT "annotations_topic_id_fkey"
      FOREIGN KEY ("topic_id") REFERENCES "topics"("id") ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;

  -- topic_reads → users
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'topic_reads_user_id_fkey') THEN
    ALTER TABLE "topic_reads" ADD CONSTRAINT "topic_reads_user_id_fkey"
      FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;

  -- topic_reads → topics
  IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'topic_reads_topic_id_fkey') THEN
    ALTER TABLE "topic_reads" ADD CONSTRAINT "topic_reads_topic_id_fkey"
      FOREIGN KEY ("topic_id") REFERENCES "topics"("id") ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;
