import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { Search } from "lucide-react";
import { useState } from "react";
import { Input } from "@/components/ui/input";
import { ProductCard } from "@/components/product-card";
import { Button } from "@/components/ui/button";
import { categories } from "@/lib/market-data";
import { fetchProducts } from "@/lib/api";
export const Route = createFileRoute("/categories")({ head: () => ({ meta: [{ title: "Market Categories — Palengke.ph" }, { name: "description", content: "Browse fresh public-market products by category." }, { property: "og:title", content: "Market Categories — Palengke.ph" }, { property: "og:description", content: "Fresh produce, seafood, meat, rice and more from local vendors." }, { property: "og:type", content: "website" }, { name: "twitter:card", content: "summary_large_image" }] }), component: CategoriesPage });
function CategoriesPage() {
  const [active, setActive] = useState("All"); const [query, setQuery] = useState("");
  const { data: products = [] } = useQuery({ queryKey: ["products"], queryFn: () => fetchProducts() });
  const shown = products.filter((p) => (active === "All" || p.category === active) && p.name.toLowerCase().includes(query.toLowerCase()));
  return <div className="page-wrap"><p className="section-kicker">Browse the market</p><h1 className="section-title">All Categories</h1><div className="relative mt-5 max-w-lg"><Search className="absolute left-3 top-3 size-5 text-muted-foreground"/><Input className="h-11 pl-10" placeholder="Search products" value={query} onChange={(e) => setQuery(e.target.value)}/></div><div className="mt-6 flex gap-2 overflow-x-auto pb-2">{categories.map((item) => <Button key={item} variant={item === active ? "default" : "outline"} className="shrink-0 rounded-full" onClick={() => setActive(item)}>{item}</Button>)}</div><div className="mt-7 grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">{shown.map((p) => <ProductCard key={p.id} product={p}/>)}</div></div>;
}
