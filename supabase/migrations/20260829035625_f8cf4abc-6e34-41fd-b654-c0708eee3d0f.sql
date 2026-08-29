CREATE TYPE public.app_role AS ENUM ('customer', 'vendor', 'admin');
CREATE TYPE public.order_status AS ENUM ('placed', 'confirming', 'accepted', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'completed', 'rejected', 'cancelled');
CREATE TYPE public.fulfillment_type AS ENUM ('delivery', 'pickup');
CREATE TYPE public.payment_method AS ENUM ('cod', 'cash_pickup', 'gcash', 'digital');

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,
  full_name text NOT NULL,
  phone text,
  avatar_url text,
  default_address text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_read_own" ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT TO authenticated WITH CHECK (id = auth.uid());
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  role public.app_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "roles_read_own" ON public.user_roles FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;
GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated;

CREATE TABLE public.categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.categories TO anon, authenticated;
GRANT ALL ON public.categories TO service_role;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_public_read" ON public.categories FOR SELECT TO anon, authenticated USING (true);

CREATE TABLE public.vendors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid,
  store_name text NOT NULL,
  description text,
  market_name text NOT NULL,
  stall_number text NOT NULL,
  market_section text NOT NULL,
  general_location text NOT NULL,
  image_url text,
  rating numeric(2,1) NOT NULL DEFAULT 0,
  review_count integer NOT NULL DEFAULT 0,
  is_open boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.vendors TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.vendors TO authenticated;
GRANT ALL ON public.vendors TO service_role;
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "vendors_public_read" ON public.vendors FOR SELECT TO anon, authenticated USING (is_open OR owner_id = auth.uid());
CREATE POLICY "vendors_insert_own" ON public.vendors FOR INSERT TO authenticated WITH CHECK (owner_id = auth.uid() AND public.has_role(auth.uid(), 'vendor'));
CREATE POLICY "vendors_update_own" ON public.vendors FOR UPDATE TO authenticated USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
CREATE POLICY "vendors_delete_own" ON public.vendors FOR DELETE TO authenticated USING (owner_id = auth.uid());

CREATE TABLE public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id uuid NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
  category_id uuid NOT NULL REFERENCES public.categories(id),
  name text NOT NULL,
  description text,
  image_url text,
  price numeric(10,2) NOT NULL CHECK (price >= 0),
  unit text NOT NULL,
  quantity numeric(10,2) NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  is_available boolean NOT NULL DEFAULT true,
  is_featured boolean NOT NULL DEFAULT false,
  popularity integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.products TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.products TO authenticated;
GRANT ALL ON public.products TO service_role;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "products_public_read" ON public.products FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "products_vendor_insert" ON public.products FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.vendors v WHERE v.id = vendor_id AND v.owner_id = auth.uid()));
CREATE POLICY "products_vendor_update" ON public.products FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.vendors v WHERE v.id = vendor_id AND v.owner_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.vendors v WHERE v.id = vendor_id AND v.owner_id = auth.uid()));
CREATE POLICY "products_vendor_delete" ON public.products FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.vendors v WHERE v.id = vendor_id AND v.owner_id = auth.uid()));

CREATE TABLE public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL,
  customer_name text NOT NULL,
  contact_number text NOT NULL,
  delivery_address text,
  instructions text,
  fulfillment public.fulfillment_type NOT NULL,
  payment public.payment_method NOT NULL,
  status public.order_status NOT NULL DEFAULT 'placed',
  total numeric(10,2) NOT NULL CHECK (total >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.orders TO authenticated;
GRANT ALL ON public.orders TO service_role;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "orders_customer_read" ON public.orders FOR SELECT TO authenticated USING (customer_id = auth.uid());
CREATE POLICY "orders_customer_insert" ON public.orders FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid());
CREATE POLICY "orders_customer_cancel" ON public.orders FOR UPDATE TO authenticated USING (customer_id = auth.uid() AND status IN ('placed','confirming')) WITH CHECK (customer_id = auth.uid());

CREATE TABLE public.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id),
  vendor_id uuid NOT NULL REFERENCES public.vendors(id),
  product_name text NOT NULL,
  quantity numeric(10,2) NOT NULL CHECK (quantity > 0),
  unit text NOT NULL,
  unit_price numeric(10,2) NOT NULL CHECK (unit_price >= 0),
  subtotal numeric(10,2) NOT NULL CHECK (subtotal >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.order_items TO authenticated;
GRANT ALL ON public.order_items TO service_role;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "items_customer_read" ON public.order_items FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid()));
CREATE POLICY "items_customer_insert" ON public.order_items FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid()));
CREATE POLICY "items_vendor_read" ON public.order_items FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.vendors v WHERE v.id = vendor_id AND v.owner_id = auth.uid()));

CREATE POLICY "orders_vendor_read" ON public.orders FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.order_items oi JOIN public.vendors v ON v.id = oi.vendor_id WHERE oi.order_id = orders.id AND v.owner_id = auth.uid()));
CREATE POLICY "orders_vendor_update" ON public.orders FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.order_items oi JOIN public.vendors v ON v.id = oi.vendor_id WHERE oi.order_id = orders.id AND v.owner_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.order_items oi JOIN public.vendors v ON v.id = oi.vendor_id WHERE oi.order_id = orders.id AND v.owner_id = auth.uid()));

CREATE TABLE public.reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL,
  vendor_id uuid NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
  order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (customer_id, order_id, vendor_id)
);
GRANT SELECT ON public.reviews TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.reviews TO authenticated;
GRANT ALL ON public.reviews TO service_role;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "reviews_public_read" ON public.reviews FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "reviews_customer_insert" ON public.reviews FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid() AND EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid() AND o.status = 'completed'));
CREATE POLICY "reviews_customer_update" ON public.reviews FOR UPDATE TO authenticated USING (customer_id = auth.uid()) WITH CHECK (customer_id = auth.uid());
CREATE POLICY "reviews_customer_delete" ON public.reviews FOR DELETE TO authenticated USING (customer_id = auth.uid());

CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  message text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notifications_read_own" ON public.notifications FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "notifications_update_own" ON public.notifications FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "notifications_delete_own" ON public.notifications FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.set_updated_at() RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER vendors_updated_at BEFORE UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

INSERT INTO public.categories (name, slug) VALUES
('Vegetables','vegetables'),('Fruits','fruits'),('Meat','meat'),('Fish and Seafood','fish-seafood'),('Poultry','poultry'),('Eggs','eggs'),('Rice and Grains','rice-grains'),('Spices and Seasonings','spices-seasonings'),('Dry Goods','dry-goods'),('Snacks','snacks'),('Beverages','beverages'),('Other Market Products','other');

INSERT INTO public.vendors (id, store_name, description, market_name, stall_number, market_section, general_location, image_url, rating, review_count) VALUES
('10000000-0000-4000-8000-000000000001','Aling Nena''s Gulayan','Fresh vegetables delivered daily from Nueva Ecija farms.','Bagong Palengke ng San Jose','42','Vegetable Section','Brgy. San Roque, San Jose City','https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=900&q=80',4.9,128),
('10000000-0000-4000-8000-000000000002','Ate Marites Prutas','Seasonal local fruits, hand-picked every morning.','Bagong Palengke ng San Jose','55','Fruit Section','Brgy. San Roque, San Jose City','https://images.unsplash.com/photo-1619566636858-adf3ef46400b?auto=format&fit=crop&w=900&q=80',4.8,94),
('10000000-0000-4000-8000-000000000003','Karneng Bagong Katay','Quality pork and beef cut to your preference.','Bagong Palengke ng San Jose','23','Meat Section','Brgy. San Roque, San Jose City','https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?auto=format&fit=crop&w=900&q=80',4.7,81),
('10000000-0000-4000-8000-000000000004','Kuya Ramil Seafood','Fresh catch and seafood on ice daily.','Bagong Palengke ng San Jose','08','Wet Section','Brgy. San Roque, San Jose City','https://images.unsplash.com/photo-1534482421-64566f976cfa?auto=format&fit=crop&w=900&q=80',4.9,156),
('10000000-0000-4000-8000-000000000005','Mang Lito''s Poultry','Fresh chicken and farm eggs.','Bagong Palengke ng San Jose','17','Poultry Section','Brgy. San Roque, San Jose City','https://images.unsplash.com/photo-1587593810167-a84920ea0781?auto=format&fit=crop&w=900&q=80',4.6,67),
('10000000-0000-4000-8000-000000000006','Tindahan ni Mang Ben','Rice, spices, dry goods, and household staples.','Bagong Palengke ng San Jose','61','Dry Goods Section','Brgy. San Roque, San Jose City','https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=900&q=80',4.8,112);

INSERT INTO public.products (vendor_id, category_id, name, description, image_url, price, unit, quantity, is_featured, popularity)
SELECT v.id, c.id, p.name, p.description, p.image_url, p.price, p.unit, p.quantity, p.featured, p.popularity
FROM (VALUES
('Aling Nena''s Gulayan','Vegetables','Kamatis','Hinog at sariwang kamatis.','https://images.unsplash.com/photo-1546470427-e26264be0b0d?auto=format&fit=crop&w=800&q=80',80.00,'kilo',10.00,true,96),
('Aling Nena''s Gulayan','Vegetables','Sibuyas na Pula','Lokal na pulang sibuyas.','https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&w=800&q=80',120.00,'kilo',8.00,true,88),
('Aling Nena''s Gulayan','Spices and Seasonings','Siling Labuyo','Maanghang at sariwa.','https://images.unsplash.com/photo-1583119022894-919a68a3d0e3?auto=format&fit=crop&w=800&q=80',20.00,'pack',15.00,false,72),
('Aling Nena''s Gulayan','Vegetables','Talong','Bagong pitas na talong.','https://images.unsplash.com/photo-1659261200833-ec8761558af7?auto=format&fit=crop&w=800&q=80',60.00,'kilo',12.00,true,84),
('Ate Marites Prutas','Fruits','Saging na Lakatan','Matamis na hinog na lakatan.','https://images.unsplash.com/photo-1603833665858-e61d17a86224?auto=format&fit=crop&w=800&q=80',90.00,'kilo',18.00,true,91),
('Ate Marites Prutas','Fruits','Manggang Carabao','Matamis na mangga mula Guimaras.','https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=800&q=80',160.00,'kilo',6.00,true,95),
('Karneng Bagong Katay','Meat','Baboy Kasim','Fresh pork shoulder, bagong katay.','https://images.unsplash.com/photo-1602470520998-f4a52199a3d6?auto=format&fit=crop&w=800&q=80',310.00,'kilo',20.00,true,99),
('Karneng Bagong Katay','Meat','Baboy Liempo','Fresh pork belly.','https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=800&q=80',330.00,'kilo',14.00,false,87),
('Karneng Bagong Katay','Meat','Baka Sirloin','Tender local beef sirloin.','https://images.unsplash.com/photo-1588168333986-5078d3ae3976?auto=format&fit=crop&w=800&q=80',450.00,'kilo',5.00,false,78),
('Kuya Ramil Seafood','Fish and Seafood','Bangus','Fresh whole milkfish on ice.','https://images.unsplash.com/photo-1510130387422-82bed34b37e9?auto=format&fit=crop&w=800&q=80',180.00,'kilo',9.00,true,98),
('Kuya Ramil Seafood','Fish and Seafood','Tilapia','Fresh local tilapia.','https://images.unsplash.com/photo-1498654200943-1088dd4438ae?auto=format&fit=crop&w=800&q=80',140.00,'kilo',11.00,true,93),
('Mang Lito''s Poultry','Poultry','Whole Chicken','Fresh dressed chicken.','https://images.unsplash.com/photo-1587593810167-a84920ea0781?auto=format&fit=crop&w=800&q=80',195.00,'kilo',13.00,false,86),
('Mang Lito''s Poultry','Eggs','Farm Eggs','Fresh medium brown eggs.','https://images.unsplash.com/photo-1506976785307-8732e854ad03?auto=format&fit=crop&w=800&q=80',110.00,'dozen',20.00,false,80),
('Tindahan ni Mang Ben','Dry Goods','Asukal Brown','Brown sugar sold by kilo.','https://images.unsplash.com/photo-1581441363689-1f3c3c414635?auto=format&fit=crop&w=800&q=80',75.00,'kilo',25.00,false,66),
('Tindahan ni Mang Ben','Rice and Grains','Bigas Dinorado','Premium aromatic rice.','https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80',65.00,'kilo',50.00,true,97),
('Tindahan ni Mang Ben','Rice and Grains','Bigas Sinandomeng','Everyday quality rice.','https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?auto=format&fit=crop&w=800&q=80',58.00,'kilo',60.00,false,92),
('Tindahan ni Mang Ben','Beverages','Buko Juice 1L','Fresh buko juice, chilled.','https://images.unsplash.com/photo-1525385133512-2f3bdd039054?auto=format&fit=crop&w=800&q=80',80.00,'bottle',7.00,false,74),
('Tindahan ni Mang Ben','Dry Goods','Toyo at Suka Set','One bottle each of soy sauce and vinegar.','https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=800&q=80',95.00,'set',12.00,false,61),
('Tindahan ni Mang Ben','Other Market Products','Walis Tambo','Handmade household broom.','https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',150.00,'piece',8.00,false,54)
) AS p(vendor_name, category_name, name, description, image_url, price, unit, quantity, featured, popularity)
JOIN public.vendors v ON v.store_name = p.vendor_name
JOIN public.categories c ON c.name = p.category_name;