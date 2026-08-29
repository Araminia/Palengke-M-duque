export type Vendor = {
  id: string;
  name: string;
  stall: string;
  section: string;
  categories: string[];
  rating: number;
  products: number;
  image: string;
  description: string;
};

export type Product = {
  id: string;
  vendorId: string;
  name: string;
  price: number;
  unit: string;
  stock: number;
  category: string;
  image: string;
  description: string;
  vendor: string;
  stall: string;
};

const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:4000";

async function handle<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.json().catch(() => ({}) as { error?: string });
    throw new Error(body.error ?? `Request failed: ${res.status}`);
  }
  return res.json() as Promise<T>;
}

export function fetchVendors(): Promise<Vendor[]> {
  return fetch(`${API_URL}/api/vendors`).then((res) => handle<Vendor[]>(res));
}

export function fetchVendor(id: string): Promise<Vendor> {
  return fetch(`${API_URL}/api/vendors/${id}`).then((res) => handle<Vendor>(res));
}

export function fetchProducts(params?: { category?: string; search?: string }): Promise<Product[]> {
  const query = new URLSearchParams();
  if (params?.category && params.category !== "All") query.set("category", params.category);
  if (params?.search) query.set("search", params.search);
  const qs = query.toString();
  return fetch(`${API_URL}/api/products${qs ? `?${qs}` : ""}`).then((res) => handle<Product[]>(res));
}

export function fetchProduct(id: string): Promise<Product> {
  return fetch(`${API_URL}/api/products/${id}`).then((res) => handle<Product>(res));
}

export type PlaceOrderInput = {
  customerName: string;
  customerPhone: string;
  fulfillment: "delivery" | "pickup";
  deliveryAddress?: string;
  paymentMethod: "cod" | "cash_pickup" | "gcash" | "digital";
  notes?: string;
  items: { productId: string; quantity: number }[];
};

export function placeOrder(input: PlaceOrderInput): Promise<{ orderId: string; total: number }> {
  return fetch(`${API_URL}/api/orders`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  }).then((res) => handle(res));
}

export type Order = {
  id: string;
  customer_name: string;
  customer_phone: string;
  fulfillment: "delivery" | "pickup";
  delivery_address: string | null;
  payment_method: "cod" | "cash_pickup" | "gcash" | "digital";
  notes: string | null;
  status: string;
  total: number;
  created_at: string;
};

export function fetchOrder(id: string): Promise<Order> {
  return fetch(`${API_URL}/api/orders/${id}`).then((res) => handle<Order>(res));
}
