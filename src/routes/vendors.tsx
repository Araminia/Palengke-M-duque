import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { VendorCard } from "@/components/vendor-card";
import { fetchVendors } from "@/lib/api";
export const Route = createFileRoute("/vendors")({ head: () => ({ meta: [{ title: "Local Vendors — Palengke.ph" }, { name: "description", content: "Meet trusted vendors at Bagong Palengke ng San Jose." }, { property: "og:title", content: "Local Vendors — Palengke.ph" }, { property: "og:description", content: "Shop directly from verified local market stalls." }, { property: "og:type", content: "website" }, { name: "twitter:card", content: "summary_large_image" }] }), component: VendorsPage });
function VendorsPage() {
  const { data: vendors = [] } = useQuery({ queryKey: ["vendors"], queryFn: fetchVendors });
  return <div className="page-wrap"><p className="section-kicker">Bagong Palengke ng San Jose</p><h1 className="section-title">Our Market Vendors</h1><p className="mt-2 max-w-2xl text-sm text-muted-foreground">Kilalanin ang mga suki mong tindero and see exactly where to find their stalls.</p><div className="mt-7 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{vendors.map((v) => <VendorCard key={v.id} vendor={v}/>)}</div></div>;
}
