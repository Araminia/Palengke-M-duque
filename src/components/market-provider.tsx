import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import type { Product } from "@/lib/api";

export type CartLine = { product: Product; quantity: number };
type MarketContextValue = { cart: CartLine[]; add: (product: Product) => void; update: (id: string, quantity: number) => void; remove: (id: string) => void; clear: () => void; count: number; total: number };
const MarketContext = createContext<MarketContextValue | undefined>(undefined);

export function MarketProvider({ children }: { children: ReactNode }) {
  const [cart, setCart] = useState<CartLine[]>([]);
  useEffect(() => {
    const saved = window.localStorage.getItem("palengke-cart");
    if (saved) setCart(JSON.parse(saved) as CartLine[]);
  }, []);
  useEffect(() => { window.localStorage.setItem("palengke-cart", JSON.stringify(cart)); }, [cart]);
  const value = useMemo(() => ({
    cart,
    add: (product: Product) => setCart((lines) => lines.some((line) => line.product.id === product.id) ? lines.map((line) => line.product.id === product.id ? { ...line, quantity: Math.min(line.quantity + 1, product.stock) } : line) : [...lines, { product, quantity: 1 }]),
    update: (id: string, quantity: number) => setCart((lines) => lines.map((line) => line.product.id === id ? { ...line, quantity: Math.max(1, Math.min(quantity, line.product.stock)) } : line)),
    remove: (id: string) => setCart((lines) => lines.filter((line) => line.product.id !== id)),
    clear: () => setCart([]),
    count: cart.reduce((sum, line) => sum + line.quantity, 0),
    total: cart.reduce((sum, line) => sum + line.quantity * line.product.price, 0),
  }), [cart]);
  return <MarketContext.Provider value={value}>{children}</MarketContext.Provider>;
}

export function useMarket() {
  const value = useContext(MarketContext);
  if (!value) throw new Error("useMarket must be used inside MarketProvider");
  return value;
}
