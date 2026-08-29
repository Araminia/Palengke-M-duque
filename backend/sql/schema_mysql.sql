-- Palengke.ph schema for Aiven MySQL.
-- Run once against your Aiven MySQL database, e.g.:
--   mysql --host=<host> --port=<port> --user=avnadmin -p --ssl-mode=REQUIRED palengke_db < sql/schema_mysql.sql

CREATE TABLE IF NOT EXISTS vendors (
  id           VARCHAR(64) PRIMARY KEY,
  name         TEXT NOT NULL,
  stall        VARCHAR(32) NOT NULL,
  section      VARCHAR(128) NOT NULL,
  categories   JSON NOT NULL,
  rating       DECIMAL(2,1) NOT NULL DEFAULT 5.0,
  image_url    TEXT NOT NULL,
  description  TEXT,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id           VARCHAR(64) PRIMARY KEY,
  vendor_id    VARCHAR(64) NOT NULL,
  name         TEXT NOT NULL,
  price        DECIMAL(10,2) NOT NULL,
  unit         VARCHAR(32) NOT NULL,
  stock        INT NOT NULL DEFAULT 0,
  category     VARCHAR(128) NOT NULL,
  image_url    TEXT NOT NULL,
  description  TEXT,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
  INDEX products_category_idx (category),
  INDEX products_vendor_idx (vendor_id)
);

CREATE TABLE IF NOT EXISTS orders (
  id                VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  customer_name     TEXT NOT NULL,
  customer_phone    VARCHAR(32) NOT NULL,
  fulfillment       VARCHAR(16) NOT NULL CHECK (fulfillment IN ('delivery', 'pickup')),
  delivery_address  TEXT,
  payment_method    VARCHAR(16) NOT NULL CHECK (payment_method IN ('cod', 'cash_pickup', 'gcash', 'digital')),
  notes             TEXT,
  status            VARCHAR(16) NOT NULL DEFAULT 'placed' CHECK (status IN ('placed', 'preparing', 'ready', 'completed', 'cancelled')),
  total             DECIMAL(10,2) NOT NULL,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
  id          VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
  order_id    VARCHAR(36) NOT NULL,
  product_id  VARCHAR(64) NOT NULL,
  quantity    INT NOT NULL CHECK (quantity > 0),
  unit_price  DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX order_items_order_idx (order_id)
);

INSERT IGNORE INTO vendors (id, name, stall, section, categories, rating, image_url, description) VALUES
  ('nena',    'Aling Nena''s Gulayan',   '42', 'Vegetable Section', JSON_ARRAY('Vegetables','Spices'), 4.9, '/assets/category-vegetables.jpg', 'Fresh vegetables delivered daily from Nueva Ecija farms.'),
  ('marites', 'Ate Marites Prutas',      '55', 'Fruit Section',     JSON_ARRAY('Fruits'),              4.8, '/assets/category-fruits.jpg',     'Seasonal local fruits, hand-picked every morning.'),
  ('karne',   'Karneng Bagong Katay',    '23', 'Meat Section',      JSON_ARRAY('Meat'),                4.7, '/assets/category-meat.jpg',       'Quality pork and beef cut to your preference.'),
  ('ramil',   'Kuya Ramil Seafood',      '08', 'Wet Section',       JSON_ARRAY('Fish and Seafood'),    4.9, '/assets/category-seafood.jpg',    'Fresh catch and seafood kept on ice daily.'),
  ('lito',    'Mang Lito''s Poultry',    '17', 'Poultry Section',   JSON_ARRAY('Poultry','Eggs'),      4.6, '/assets/category-poultry.jpg',    'Fresh chicken and farm eggs.'),
  ('ben',     'Tindahan ni Mang Ben',    '61', 'Dry Goods Section', JSON_ARRAY('Dry Goods','Rice and Grains'), 4.8, '/assets/category-dry-goods.jpg', 'Rice, spices, dry goods, and household staples.');

INSERT IGNORE INTO products (id, vendor_id, name, price, unit, stock, category, image_url, description) VALUES
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
  ('buko',     'ben',     'Buko Juice (1L)',     80,  'bottle', 0,  'Beverages',              '/assets/category-fruits.jpg',     'Fresh buko juice, chilled.');
