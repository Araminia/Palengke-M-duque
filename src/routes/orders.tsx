import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { money } from "@/lib/market-data";
import { fetchOrder, type Order } from "@/lib/api";

export const Route = createFileRoute("/orders")({
  head: () => ({
    meta: [
      { title: "Order Confirmation — Palengke.ph" },
      { name: "description", content: "Your Palengke.ph order confirmation." },
    ],
  }),
  component: OrdersPage,
});

function OrdersPage() {
  const [order, setOrder] = useState<Order | null>(null);
  const [itemCount, setItemCount] = useState<number>(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const raw = window.sessionStorage.getItem("palengke-order");
    if (!raw) {
      setLoading(false);
      setError("No recent order found.");
      return;
    }
    const stored = JSON.parse(raw) as { id: string; total: number; status: string; items: number };
    setItemCount(stored.items);
    fetchOrder(stored.id)
      .then((data) => setOrder(data))
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load order"))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="page-wrap">
        <p className="text-sm text-muted-foreground">Loading your order…</p>
      </div>
    );
  }

  if (error || !order) {
    return (
      <div className="page-wrap text-center">
        <h1 className="section-title">No order to show</h1>
        <p className="mt-2 text-sm text-muted-foreground">{error ?? "We couldn't find that order."}</p>
        <Link to="/" className="mt-6 inline-block">
          <Button className="rounded-full">Back to Home</Button>
        </Link>
      </div>
    );
  }

  return (
    <div className="page-wrap max-w-2xl">
      <p className="section-kicker">Order placed</p>
      <h1 className="section-title">Salamat, {order.customer_name}!</h1>
      <p className="mt-2 text-sm text-muted-foreground">
        Your order has been received and is being processed.
      </p>

      <section className="mt-6 rounded-lg border bg-card p-5">
        <div className="flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Order ID</span>
          <span className="font-mono text-sm">{order.id}</span>
        </div>
        <div className="mt-2 flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Status</span>
          <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-semibold uppercase text-primary">
            {order.status}
          </span>
        </div>
        <div className="mt-2 flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Items</span>
          <span className="text-sm">{itemCount}</span>
        </div>
        <div className="mt-2 flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Fulfillment</span>
          <span className="text-sm capitalize">{order.fulfillment}</span>
        </div>
        {order.delivery_address && (
          <div className="mt-2 flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Delivery address</span>
            <span className="text-right text-sm">{order.delivery_address}</span>
          </div>
        )}
        <div className="mt-2 flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Payment method</span>
          <span className="text-sm uppercase">{order.payment_method}</span>
        </div>
        {order.notes && (
          <div className="mt-2 flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Notes</span>
            <span className="text-right text-sm">{order.notes}</span>
          </div>
        )}
        <div className="my-4 border-t" />
        <div className="flex items-center justify-between text-lg font-bold">
          <span>Total</span>
          <span className="text-primary">{money(order.total)}</span>
        </div>
      </section>

      <Link to="/" className="mt-6 inline-block">
        <Button className="rounded-full">Continue Shopping</Button>
      </Link>
    </div>
  );
}
