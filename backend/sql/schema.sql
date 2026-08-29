-- Palengke.ph schema for Aiven Postgres.
-- Run once against your Aiven database, e.g.:
--   psql "$DATABASE_URL" -f sql/schema.sql

CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for gen_random_uuid()

CREATE TABLE IF NOT EXISTS vendors (
  id           text PRIMARY KEY,
  name         text NOT NULL,
  stall        text NOT NULL,
  section      text NOT NULL,
  categories   text[] NOT NULL DEFAULT '{}',
  rating       numeric(2,1) NOT NULL DEFAULT 5.0,
  image_url    text NOT NULL,
  description  text NOT NULL DEFAULT '',
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS products (
  id           text PRIMARY KEY,
  vendor_id    text NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  name         text NOT NULL,
  price        numeric(10,2) NOT NULL,
  unit         text NOT NULL,
  stock        integer NOT NULL DEFAULT 0,
  category     text NOT NULL,
  image_url    text NOT NULL,
  description  text NOT NULL DEFAULT '',
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS products_category_idx ON products(category);
CREATE INDEX IF NOT EXISTS products_vendor_idx ON products(vendor_id);

CREATE TABLE IF NOT EXISTS orders (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name   text NOT NULL,
  customer_phone  text NOT NULL,
  fulfillment     text NOT NULL CHECK (fulfillment IN ('delivery', 'pickup')),
  delivery_address text,
  payment_method  text NOT NULL CHECK (payment_method IN ('cod', 'cash_pickup', 'gcash', 'digital')),
  notes           text,
  status          text NOT NULL DEFAULT 'placed' CHECK (status IN ('placed', 'preparing', 'ready', 'completed', 'cancelled')),
  total           numeric(10,2) NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id  text NOT NULL REFERENCES products(id),
  quantity    integer NOT NULL CHECK (quantity > 0),
  unit_price  numeric(10,2) NOT NULL -- price snapshot at time of order
);
CREATE INDEX IF NOT EXISTS order_items_order_idx ON order_items(order_id);

-- ---- Seed data (matches src/lib/market-data.ts) ----

INSERT INTO vendors (id, name, stall, section, categories, rating, image_url, description) VALUES
  ('nena',    'Aling Nena''s Gulayan',   '42', 'Vegetable Section', '{Vegetables,Spices}', 4.9, '/assets/category-vegetables.jpg', 'Fresh vegetables delivered daily from Nueva Ecija farms.'),
  ('marites', 'Ate Marites Prutas',      '55', 'Fruit Section',     '{Fruits}',             4.8, '/assets/category-fruits.jpg',     'Seasonal local fruits, hand-picked every morning.'),
  ('karne',   'Karneng Bagong Katay',    '23', 'Meat Section',      '{Meat}',               4.7, '/assets/category-meat.jpg',       'Quality pork and beef cut to your preference.'),
  ('ramil',   'Kuya Ramil Seafood',      '08', 'Wet Section',       '{"Fish and Seafood"}', 4.9, '/assets/category-seafood.jpg',    'Fresh catch and seafood kept on ice daily.'),
  ('lito',    'Mang Lito''s Poultry',    '17', 'Poultry Section',   '{Poultry,Eggs}',       4.6, '/assets/category-poultry.jpg',    'Fresh chicken and farm eggs.'),
  ('ben',     'Tindahan ni Mang Ben',    '61', 'Dry Goods Section', '{"Dry Goods","Rice and Grains"}', 4.8, '/assets/category-dry-goods.jpg', 'Rice, spices, dry goods, and household staples.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO products (id, vendor_id, name, price, unit, stock, category, image_url, description) VALUES
  ('kamatis',  'nena',    'Kamatis',            80,  'kilo',   10, 'Vegetables',             '/assets/category-vegetables.jpg', 'Hinog at sariwang kamatis, bagong pitas ngayong umaga.'),
  ('sibuyas',  'nena',    'Sibuyas na Pula',     120, 'kilo',   8,  'Vegetables',             '/assets/category-vegetables.jpg', 'Lokal na pulang sibuyas.'),
  ('sili',     'nena',    'Siling Labuyo',       20,  'pack',   15, 'Spices and Seasonings',  '/assets/category-vegetables.jpg', 'Maanghang at sariwa.'),
  ('talong',   'nena',    'Talong',              60,  'kilo',   12, 'Vegetables',             '/assets/category-vegetables.jpg', 'Bagong pitas na talong.'),
  ('saging',   'marites', 'Saging na Lakatan',   90,  'kilo',   18, 'Fruits',                 '/assets/category-fruits.jpg',     'Matamis na hinog na lakatan.'),
  ('mangga',   'marites', 'Manggang Carabao',    160, 'kilo',   6,  'Fruits',                 '/assets/category-fruits.jpg',     'Matamis at mabangong mangga.'),
  ('kasim',    'karne',   'Baboy Kasim',         310, 'kilo',   20, 'Meat',                   '/assets/category-meat.jpg',       'Fresh pork shoulder, bagong katay.'),
  ('liempo',   'karne',   'Baboy Liempo',        330, 'kilo',   14, 'Meat',                   '/assets/category-meat.jpg',       'Fresh pork belly.'),
  ('bangus',   'ramil',   'Bangus',              180, 'kilo',   9,  'Fish and Seafood',       '/assets/category-seafood.jpg',    'Fresh whole milkfish on ice.'),
  ('tilapia',  'ramil',   'Tilapia',             140, 'kilo',   11, 'Fish and Seafood',       '/assets/category-seafood.jpg',    'Fresh local tilapia.'),
  ('manok',    'lito',    'Whole Chicken',       195, 'kilo',   13, 'Poultry',                '/assets/category-poultry.jpg',    'Fresh dressed chicken.'),
  ('itlog',    'lito',    'Farm Eggs',           110, 'dozen',  20, 'Eggs',                   '/assets/category-poultry.jpg',    'Fresh medium brown eggs.'),
  ('dinorado', 'ben',     'Bigas Dinorado',      65,  'kilo',   50, 'Rice and Grains',        '/assets/category-dry-goods.jpg',  'Premium aromatic rice.'),
  ('asukal',   'ben',     'Asukal Brown',        75,  'kilo',   25, 'Dry Goods',              '/assets/category-dry-goods.jpg',  'Brown sugar sold by kilo.'),
  ('buko',     'ben',     'Buko Juice (1L)',     80,  'bottle', 0,  'Beverages',              '/assets/category-fruits.jpg',     'Fresh buko juice, chilled.')
ON CONFLICT (id) DO NOTHING;
