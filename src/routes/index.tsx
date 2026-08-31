import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { ArrowRight, Bike, MapPin, Search, ShieldCheck, ShoppingBasket } from "lucide-react";
import { useState } from "react";
import hero from "@/assets/palengke-hero.jpg";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ProductCard } from "@/components/product-card";
import { VendorCard } from "@/components/vendor-card";
import { categories } from "@/lib/market-data";
import { fetchProducts, fetchVendors } from "@/lib/api";

export const Route = createFileRoute("/")({
  head: () => ({ meta: [{ title: "Palengke.ph — Fresh from San Jose Market" }, { name: "description", content: "Shop fresh produce, meat, seafood and local goods from trusted public-market vendors." }, { property: "og:title", content: "Palengke.ph — Fresh from San Jose Market" }, { property: "og:description", content: "Your local public market, now online for easy pickup and delivery." }, { property: "og:type", content: "website" }, { name: "twitter:card", content: "summary_large_image" }] }),
  component: Index,
});

function Index() {
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("All");
  const { data: products = [] } = useQuery({ queryKey: ["products"], queryFn: () => fetchProducts() });
  const { data: vendors = [] } = useQuery({ queryKey: ["vendors"], queryFn: fetchVendors });
  const visible = products.filter((product) => (category === "All" || product.category === category) && product.name.toLowerCase().includes(query.toLowerCase()));
  return (
    <>
      <section className="relative min-h-[520px] overflow-hidden bg-foreground sm:min-h-[570px]">
        <img src={hero} alt="Fresh produce at Bagong Palengke ng San Jose" width={1536} height={1024} className="absolute inset-0 h-full w-full object-cover opacity-60" />
        <div className="absolute inset-0 bg-gradient-to-r from-foreground/90 via-foreground/60 to-transparent" />
        <div className="relative mx-auto flex min-h-[520px] max-w-7xl flex-col justify-center px-4 pb-24 pt-14 sm:min-h-[570px] sm:px-6">
          <p className="mb-3 flex items-center gap-2 text-xs font-extrabold uppercase text-market-cream"><MapPin className="size-4" /> Bagong Palengke ng San Jose</p>
          <h1 className="max-w-3xl font-display text-4xl font-bold leading-tight text-primary-foreground sm:text-6xl">Sariwang pagkain,<br/><span className="text-market-gold">diretso sa palengke.</span></h1>
          <p className="mt-4 max-w-xl text-sm leading-6 text-primary-foreground/85 sm:text-base">Mamili mula sa mga suki mong tindero. Fresh, affordable, and ready for pickup or delivery.</p>
          <form className="mt-7 flex max-w-2xl gap-2 rounded-lg bg-background p-2 shadow-xl" onSubmit={(event) => event.preventDefault()}>
            <Search className="ml-2 mt-3 size-5 shrink-0 text-muted-foreground" /><Input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Hanapin ang kamatis, bangus, bigas..." className="h-11 border-0 shadow-none focus-visible:ring-0" /><Button type="submit" className="h-11 rounded-md px-5">Search</Button>
          </form>
        </div>
      </section>
      <div className="relative z-10 mx-auto -mt-12 grid max-w-5xl grid-cols-1 gap-2 px-4 sm:grid-cols-3">
        {[{ icon: ShoppingBasket, title: "Madaling mamili", copy: "Lahat ng suki sa isang app" }, { icon: Bike, title: "Pickup o delivery", copy: "Ikaw ang pumili" }, { icon: ShieldCheck, title: "Trusted vendors", copy: "Verified market stalls" }].map(({ icon: Icon, title, copy }) => <div key={title} className="flex items-center gap-3 rounded-lg border bg-card p-4 shadow-md"><span className="grid size-10 place-items-center rounded-full bg-secondary text-primary"><Icon className="size-5" /></span><div><b className="text-sm">{title}</b><p className="text-xs text-muted-foreground">{copy}</p></div></div>)}
      </div>
      <section className="page-wrap pt-14">
        <div className="flex items-end justify-between"><div><p className="section-kicker">Fresh today</p><h2 className="section-title">Shop by Category</h2></div><Button asChild variant="ghost"><Link to="/categories">View all <ArrowRight /></Link></Button></div>
        <div className="mt-5 flex gap-2 overflow-x-auto pb-2">{categories.slice(0, 8).map((item) => <Button key={item} variant={category === item ? "default" : "outline"} className="shrink-0 rounded-full" onClick={() => setCategory(item)}>{item}</Button>)}</div>
        <div className="mt-7 flex items-end justify-between"><div><p className="section-kicker">From local stalls</p><h2 className="section-title">{query ? `Results for "${query}"` : "Popular Products"}</h2></div></div>
        <div className="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">{visible.slice(0, 10).map((product) => <ProductCard key={product.id} product={product} />)}</div>
        {visible.length === 0 && <div className="my-12 text-center text-muted-foreground">No products found. Try another search.</div>}
      </section>
      <section className="border-y bg-market-cream"><div className="page-wrap py-12"><div className="flex items-end justify-between"><div><p className="section-kicker">Meet your suki</p><h2 className="section-title">Shop by Vendor</h2></div><Button asChild variant="ghost"><Link to="/vendors">All vendors <ArrowRight /></Link></Button></div><div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{vendors.slice(0, 3).map((vendor) => <VendorCard key={vendor.id} vendor={vendor} />)}</div></div></section>
      <footer className="bg-foreground text-background"><div className="mx-auto grid max-w-7xl gap-8 px-4 py-10 sm:grid-cols-3 sm:px-6"><div><h2 className="font-display text-xl font-bold">Palengke<span className="text-market-gold">.ph</span></h2><p className="mt-2 text-xs text-background/70">Ang bagong paraan ng pamamalengke.</p></div><div><b className="text-sm">Bagong Palengke ng San Jose</b><p className="mt-2 text-xs text-background/70">Open daily · 5:00 AM–7:00 PM<br/>San Jose City, Nueva Ecija</p></div><div><b className="text-sm">For vendors</b><p className="mt-2 text-xs text-background/70">Grow your stall online and reach more suki.</p><Button asChild size="sm" className="mt-3"><Link to="/vendor-dashboard">Vendor dashboard</Link></Button></div></div></footer>
    </>
  );
}
