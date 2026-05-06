-- ============================================================
-- LIVE CAR — Supabase SQL Schema
-- شغّل هذا الملف في Supabase SQL Editor
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 1. USERS
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id       UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL,
  phone         TEXT UNIQUE NOT NULL,
  avatar_url    TEXT,
  language      TEXT DEFAULT 'ar' CHECK (language IN ('ar', 'ur', 'en')),
  is_premium    BOOLEAN DEFAULT FALSE,
  premium_until TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 2. WORKSHOPS
CREATE TABLE workshops (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id           UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  name_en           TEXT,
  phone             TEXT NOT NULL,
  address           TEXT NOT NULL,
  city              TEXT NOT NULL DEFAULT 'الرياض',
  district          TEXT,
  lat               DOUBLE PRECISION,
  lng               DOUBLE PRECISION,
  location          GEOGRAPHY(POINT, 4326),
  logo_url          TEXT,
  cover_url         TEXT,
  gallery_urls      TEXT[] DEFAULT '{}',
  category          TEXT[] DEFAULT '{}',
  status            TEXT DEFAULT 'pending' CHECK (status IN ('pending','active','suspended','inactive')),
  is_verified       BOOLEAN DEFAULT FALSE,
  is_featured       BOOLEAN DEFAULT FALSE,
  partner_type      TEXT DEFAULT 'standard',
  subscription_plan TEXT DEFAULT 'free',
  rating_avg        DECIMAL(2,1) DEFAULT 0.0,
  rating_count      INTEGER DEFAULT 0,
  total_orders      INTEGER DEFAULT 0,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- 3. VEHICLES
CREATE TABLE vehicles (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vin             TEXT UNIQUE,
  plate_number    TEXT,
  make            TEXT NOT NULL,
  model           TEXT NOT NULL,
  year            INTEGER NOT NULL,
  color           TEXT,
  fuel_type       TEXT DEFAULT 'petrol',
  transmission    TEXT DEFAULT 'automatic',
  current_mileage INTEGER DEFAULT 0,
  last_oil_change_date DATE,
  last_oil_change_mileage INTEGER,
  oil_change_interval INTEGER DEFAULT 5000,
  image_url       TEXT,
  is_primary      BOOLEAN DEFAULT FALSE,
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 4. SERVICES
CREATE TABLE services (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workshop_id   UUID NOT NULL REFERENCES workshops(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  description   TEXT,
  category      TEXT NOT NULL,
  price_min     DECIMAL(8,2) NOT NULL,
  price_max     DECIMAL(8,2),
  duration_min  INTEGER,
  is_active     BOOLEAN DEFAULT TRUE,
  sort_order    INTEGER DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 5. AI DIAGNOSTICS
CREATE TABLE ai_diagnostics (
  id                           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id                      UUID NOT NULL REFERENCES users(id),
  vehicle_id                   UUID REFERENCES vehicles(id),
  conversation_history         JSONB DEFAULT '[]',
  severity                     TEXT CHECK (severity IN ('critical','medium','low')),
  diagnosis                    TEXT,
  possible_causes              TEXT[],
  recommended_service          TEXT,
  estimated_price_min          DECIMAL(8,2),
  estimated_price_max          DECIMAL(8,2),
  urgency_message              TEXT,
  requires_immediate_attention BOOLEAN DEFAULT FALSE,
  created_at                   TIMESTAMPTZ DEFAULT NOW()
);

-- 6. ORDERS
CREATE TABLE orders (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number    TEXT UNIQUE NOT NULL DEFAULT '',
  user_id         UUID NOT NULL REFERENCES users(id),
  workshop_id     UUID NOT NULL REFERENCES workshops(id),
  vehicle_id      UUID NOT NULL REFERENCES vehicles(id),
  diagnosis_id    UUID REFERENCES ai_diagnostics(id),
  description     TEXT,
  scheduled_at    TIMESTAMPTZ,
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','in_progress','completed','cancelled','disputed')),
  estimated_price DECIMAL(8,2),
  final_price     DECIMAL(8,2),
  platform_fee    DECIMAL(8,2),
  payment_status  TEXT DEFAULT 'pending',
  rating          INTEGER CHECK (rating BETWEEN 1 AND 5),
  review_text     TEXT,
  accepted_at     TIMESTAMPTZ,
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  cancelled_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ORDER ITEMS
CREATE TABLE order_items (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id    UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  service_id  UUID REFERENCES services(id),
  name        TEXT NOT NULL,
  quantity    INTEGER DEFAULT 1,
  unit_price  DECIMAL(8,2) NOT NULL,
  total_price DECIMAL(8,2) NOT NULL,
  item_type   TEXT DEFAULT 'service',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 8. REVIEWS
CREATE TABLE reviews (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id    UUID NOT NULL REFERENCES orders(id),
  user_id     UUID NOT NULL REFERENCES users(id),
  workshop_id UUID NOT NULL REFERENCES workshops(id),
  rating      INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  reply       TEXT,
  is_visible  BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 9. NOTIFICATIONS
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id),
  workshop_id UUID REFERENCES workshops(id),
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        TEXT NOT NULL,
  data        JSONB DEFAULT '{}',
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 10. PAYMENTS
CREATE TABLE payments (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id    UUID NOT NULL REFERENCES orders(id),
  user_id     UUID NOT NULL REFERENCES users(id),
  moyasar_id  TEXT UNIQUE,
  amount      DECIMAL(8,2) NOT NULL,
  currency    TEXT DEFAULT 'SAR',
  method      TEXT,
  status      TEXT DEFAULT 'initiated',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 11. MAINTENANCE LOGS
CREATE TABLE maintenance_logs (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehicle_id   UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  order_id     UUID REFERENCES orders(id),
  workshop_id  UUID REFERENCES workshops(id),
  service_type TEXT NOT NULL,
  description  TEXT,
  mileage      INTEGER,
  cost         DECIMAL(8,2),
  source       TEXT DEFAULT 'livecar',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_vehicles_user_id ON vehicles(user_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_workshop_id ON orders(workshop_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_notifications_user_id ON notifications(user_id) WHERE is_read = FALSE;
CREATE INDEX idx_workshops_city ON workshops(city);
CREATE INDEX idx_workshops_status ON workshops(status) WHERE status = 'active';
CREATE INDEX idx_workshops_location ON workshops USING GIST(location);

-- FUNCTIONS & TRIGGERS
CREATE OR REPLACE FUNCTION generate_order_number() RETURNS TRIGGER AS $$
DECLARE counter INTEGER;
BEGIN
  SELECT COUNT(*) + 1 INTO counter FROM orders;
  NEW.order_number := 'LC-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(counter::TEXT, 5, '0');
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_workshop_rating() RETURNS TRIGGER AS $$
BEGIN
  UPDATE workshops SET
    rating_avg   = (SELECT AVG(rating) FROM reviews WHERE workshop_id = NEW.workshop_id AND is_visible = TRUE),
    rating_count = (SELECT COUNT(*) FROM reviews WHERE workshop_id = NEW.workshop_id AND is_visible = TRUE)
  WHERE id = NEW.workshop_id;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trigger_workshops_updated_at BEFORE UPDATE ON workshops FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trigger_vehicles_updated_at BEFORE UPDATE ON vehicles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trigger_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trigger_orders_number BEFORE INSERT ON orders FOR EACH ROW EXECUTE FUNCTION generate_order_number();
CREATE TRIGGER trigger_workshop_rating AFTER INSERT OR UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_workshop_rating();

-- RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshops ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_diagnostics ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_own" ON users FOR ALL USING (auth.uid() = auth_id);
CREATE POLICY "vehicles_owner" ON vehicles FOR ALL USING (user_id IN (SELECT id FROM users WHERE auth_id = auth.uid()));
CREATE POLICY "orders_access" ON orders FOR ALL USING (
  user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
  OR workshop_id IN (SELECT id FROM workshops WHERE auth_id = auth.uid())
);
CREATE POLICY "workshops_public_read" ON workshops FOR SELECT USING (status = 'active');
CREATE POLICY "workshops_own" ON workshops FOR UPDATE USING (auth.uid() = auth_id);
CREATE POLICY "notifications_own" ON notifications FOR ALL USING (
  user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
  OR workshop_id IN (SELECT id FROM workshops WHERE auth_id = auth.uid())
);
CREATE POLICY "diagnostics_own" ON ai_diagnostics FOR ALL USING (user_id IN (SELECT id FROM users WHERE auth_id = auth.uid()));
CREATE POLICY "reviews_read" ON reviews FOR SELECT USING (is_visible = TRUE);
CREATE POLICY "reviews_write" ON reviews FOR INSERT WITH CHECK (user_id IN (SELECT id FROM users WHERE auth_id = auth.uid()));

-- REALTIME
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- VIEWS
CREATE VIEW workshop_daily_stats AS
SELECT workshop_id,
  COUNT(*) FILTER (WHERE status = 'pending')     AS pending_count,
  COUNT(*) FILTER (WHERE status = 'in_progress') AS in_progress_count,
  COUNT(*) FILTER (WHERE status = 'completed' AND DATE(completed_at) = CURRENT_DATE) AS completed_today,
  COALESCE(SUM(final_price) FILTER (WHERE status = 'completed' AND DATE(completed_at) = CURRENT_DATE), 0) AS revenue_today
FROM orders GROUP BY workshop_id;

-- SEED DATA
INSERT INTO workshops (id, name, name_en, phone, address, city, district, lat, lng, status, is_verified, partner_type, category, rating_avg, rating_count)
VALUES ('11111111-1111-1111-1111-111111111111', 'ورشة العماد للسيارات', 'Al-Emad Auto', '0501234567',
  'شارع الأمير محمد بن عبدالعزيز', 'الرياض', 'النزهة', 24.7136, 46.6753,
  'active', TRUE, 'featured', ARRAY['صيانة','زيوت','كفرات','فرامل'], 4.8, 124);

INSERT INTO services (workshop_id, name, category, price_min, price_max, duration_min) VALUES
  ('11111111-1111-1111-1111-111111111111', 'تغيير زيت + فلتر', 'زيوت', 120, 200, 30),
  ('11111111-1111-1111-1111-111111111111', 'تبديل إطارات (4)', 'كفرات', 500, 800, 60),
  ('11111111-1111-1111-1111-111111111111', 'فحص فرامل شامل', 'فرامل', 150, 350, 45),
  ('11111111-1111-1111-1111-111111111111', 'فحص شامل + صيانة', 'صيانة', 400, 900, 120),
  ('11111111-1111-1111-1111-111111111111', 'تغيير بطارية', 'كهرباء', 200, 500, 20);

-- ✅ Schema جاهز للتشغيل في Supabase SQL Editor
