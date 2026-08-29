import { Link, useRouterState } from "@tanstack/react-router";
import { Bell, ClipboardList, Home, LayoutDashboard, Package, Search, ShoppingBasket, Store, UserRound } from "lucide-react";
import { useMarket } from "@/components/market-provider";
import { Button } from "@/components/ui/button";

export function MarketShell({ children }: { children: React.ReactNode }) {
  const { count } = useMarket();
  const path = useRouterState({ select: (state) => state.location.pathname });
  const vendorMode = path.startsWith("/vendor-dashboard");
  return <div className="min-h-screen bg-background text-foreground">
    <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-7xl items-center gap-5 px-4 sm:px-6">
        <Link to="/" className="flex items-center gap-2"><span className="grid size-9 place-items-center rounded-full bg-primary text-primary-foreground"><ShoppingBasket className="size-5" /></span><span className="font-display text-xl font-bold">Palengke<span className="text-primary">.ph</span></span></Link>
        <nav className="hidden flex-1 items-center justify-center gap-1 md:flex">
          {vendorMode ? <><Nav to="/vendor-dashboard" label="Dashboard" /><Nav to="/vendor-dashboard/products" label="Products" /><Nav to="/vendor-dashboard/orders" label="Orders" /><Nav to="/vendor-dashboard/inventory" label="Inventory" /><Nav to="/vendor-dashboard/sales" label="Sales" /></> : <><Nav to="/" label="Home" /><Nav to="/categories" label="Categories" /><Nav to="/vendors" label="Vendors" /><Nav to="/orders" label="Orders" /></>}
        </nav>
        <div className="ml-auto flex items-center gap-1"><Button variant="ghost" size="icon" aria-label="Notifications"><Bell /></Button><Button asChild variant="secondary" className="relative rounded-full"><Link to="/cart"><ShoppingBasket /> Basket {count > 0 && <span className="cart-count">{count}</span>}</Link></Button><Button asChild className="hidden rounded-full sm:inline-flex"><Link to="/auth"><UserRound /> Sign in</Link></Button></div>
      </div>
    </header>
    <main>{children}</main>
    <nav className="mobile-nav">
      {vendorMode ? <><MobileLink to="/vendor-dashboard" icon={LayoutDashboard} label="Dashboard" /><MobileLink to="/vendor-dashboard/products" icon={Package} label="Products" /><MobileLink to="/vendor-dashboard/orders" icon={ClipboardList} label="Orders" /><MobileLink to="/vendor-dashboard/profile" icon={UserRound} label="Profile" /></> : <><MobileLink to="/" icon={Home} label="Home" /><MobileLink to="/categories" icon={Search} label="Browse" /><MobileLink to="/vendors" icon={Store} label="Vendors" /><MobileLink to="/cart" icon={ShoppingBasket} label="Basket" badge={count} /><MobileLink to="/profile" icon={UserRound} label="Profile" /></>}
    </nav>
  </div>;
}

function Nav({ to, label }: { to: string; label: string }) { return <Link to={to} activeProps={{ className: "bg-accent text-accent-foreground" }} className="rounded-full px-4 py-2 text-sm font-semibold text-muted-foreground transition-colors hover:text-foreground">{label}</Link>; }
function MobileLink({ to, icon: Icon, label, badge }: { to: string; icon: typeof Home; label: string; badge?: number }) { return <Link to={to} activeProps={{ className: "text-primary" }} className="relative flex min-w-0 flex-col items-center gap-1 py-2 text-[10px] font-bold text-muted-foreground"><Icon className="size-5" />{label}{badge ? <span className="absolute right-2 top-0 grid size-4 place-items-center rounded-full bg-primary text-[9px] text-primary-foreground">{badge}</span> : null}</Link>; }