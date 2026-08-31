import { Link } from "@tanstack/react-router";
import { MapPin, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import type { Vendor } from "@/lib/api";

export function VendorCard({ vendor }: { vendor: Vendor }) {
  return <article className="vendor-card">
    <div className="relative h-28 overflow-hidden"><img src={vendor.image} alt={`${vendor.name} market stall`} loading="lazy" width={768} height={768} className="h-full w-full object-cover" /><span className="absolute right-2 top-2 rounded-full bg-market-green px-2 py-1 text-[10px] font-bold text-primary-foreground">Open</span></div>
    <div className="p-3"><div className="flex items-start justify-between gap-2"><div><h3 className="text-sm font-bold">{vendor.name}</h3><p className="mt-1 flex items-center gap-1 text-[10px] text-muted-foreground"><MapPin className="size-3" /> Stall {vendor.stall} · {vendor.section}</p></div><span className="flex items-center gap-1 text-xs font-bold text-market-gold"><Star className="size-3 fill-current" />{vendor.rating}</span></div>
      <div className="mt-3 flex items-center justify-between"><span className="text-[10px] text-muted-foreground">{vendor.products} available products</span><Button asChild size="sm" variant="secondary" className="rounded-full"><Link to="/vendors/$vendorId" params={{ vendorId: vendor.id }}>View Store</Link></Button></div>
    </div>
  </article>;
}
