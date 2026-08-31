import { Check, ShoppingBasket } from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { useMarket } from "@/components/market-provider";
import { money } from "@/lib/market-data";
import type { Product } from "@/lib/api";

export function ProductCard({ product }: { product: Product }) {
  const { add } = useMarket();
  const [added, setAdded] = useState(false);
  const soldOut = product.stock <= 0;
  return <article className="product-card">
    <div className="relative aspect-[4/3] overflow-hidden bg-muted">
      <img src={product.image} alt={product.name} loading="lazy" width={768} height={768} className="h-full w-full object-cover transition-transform duration-300 hover:scale-[1.03]" />
      <span className="category-label">{product.category}</span>
      {soldOut && <span className="sold-label">Sold out</span>}
    </div>
    <div className="flex flex-1 flex-col p-3">
      <div className="flex items-start justify-between gap-2">
        <h3 className="text-sm font-bold leading-tight">{product.name}</h3>
        <div className="shrink-0 text-right"><b className="text-sm text-primary">{money(product.price)}</b><p className="text-[9px] text-muted-foreground">per {product.unit}</p></div>
      </div>
      <p className="mt-2 truncate text-[10px] text-muted-foreground">{product.vendor} · Stall {product.stall}</p>
      <p className="mt-1 text-[10px] font-semibold text-market-green">{soldOut ? "Unavailable today" : `Available: ${product.stock} ${product.unit}`}</p>
      <Button disabled={soldOut} className="mt-3 h-9 w-full rounded-full text-xs" onClick={() => { add(product); setAdded(true); window.setTimeout(() => setAdded(false), 900); }}>
        {added ? <Check /> : <ShoppingBasket />}{added ? "Added" : soldOut ? "Sold Out" : "Add to Basket"}
      </Button>
    </div>
  </article>;
}
