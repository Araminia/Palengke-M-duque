import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { useMarket } from "@/components/market-provider";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { money } from "@/lib/market-data";
import { placeOrder } from "@/lib/api";
export const Route = createFileRoute("/checkout")({ head: () => ({ meta: [{ title: "Checkout — Palengke.ph" }, { name: "description", content: "Choose delivery or pickup and place your market order." }, { property: "og:title", content: "Checkout — Palengke.ph" }, { property: "og:description", content: "Simple checkout for your public-market order." }, { property: "og:type", content: "website" }, { name: "twitter:card", content: "summary" }] }), component: CheckoutPage });

function CheckoutPage() {
  const { cart, total, clear } = useMarket();
  const navigate = useNavigate();
  const [fulfillment, setFulfillment] = useState<"delivery" | "pickup">("delivery");
  const [payment, setPayment] = useState<"cod" | "cash_pickup" | "gcash" | "digital">("cod");
  const [customerName, setCustomerName] = useState("");
  const [customerPhone, setCustomerPhone] = useState("");
  const [deliveryAddress, setDeliveryAddress] = useState("");
  const [notes, setNotes] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!cart.length) return <div className="page-wrap"><h1 className="section-title">Your basket is empty</h1></div>;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const { orderId, total: orderTotal } = await placeOrder({
        customerName,
        customerPhone,
        fulfillment,
        deliveryAddress: fulfillment === "delivery" ? deliveryAddress : undefined,
        paymentMethod: payment,
        notes: notes || undefined,
        items: cart.map((line) => ({ productId: line.product.id, quantity: line.quantity })),
      });
      window.sessionStorage.setItem("palengke-order", JSON.stringify({ id: orderId, total: orderTotal, status: "placed", items: cart.length }));
      clear();
      navigate({ to: "/orders" });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to place order");
    } finally {
      setSubmitting(false);
    }
  }

  return <div className="page-wrap"><p className="section-kicker">Almost there</p><h1 className="section-title">Checkout</h1><form className="mt-6 grid gap-6 lg:grid-cols-[1fr_340px]" onSubmit={handleSubmit}><div className="space-y-6"><section className="rounded-lg border bg-card p-5"><h2 className="font-bold">Contact details</h2><div className="mt-4 grid gap-4 sm:grid-cols-2"><Field label="Full name"><Input required placeholder="Juan Dela Cruz" value={customerName} onChange={(e) => setCustomerName(e.target.value)}/></Field><Field label="Contact number"><Input required type="tel" placeholder="09XX XXX XXXX" value={customerPhone} onChange={(e) => setCustomerPhone(e.target.value)}/></Field></div></section><section className="rounded-lg border bg-card p-5"><h2 className="font-bold">How would you like your order?</h2><div className="mt-4 grid grid-cols-2 gap-3">{([["delivery","Delivery"],["pickup","Market pickup"]] as const).map(([value,label]) => <Button key={value} type="button" variant={fulfillment === value ? "default" : "outline"} className="h-12" onClick={() => setFulfillment(value)}>{label}</Button>)}</div>{fulfillment === "delivery" && <div className="mt-4"><Field label="Delivery address"><Textarea required placeholder="House no., street, barangay, city" value={deliveryAddress} onChange={(e) => setDeliveryAddress(e.target.value)}/></Field></div>}<div className="mt-4"><Field label="Special instructions"><Textarea placeholder="e.g. Please remove fish scales" value={notes} onChange={(e) => setNotes(e.target.value)}/></Field></div></section><section className="rounded-lg border bg-card p-5"><h2 className="font-bold">Payment method</h2><div className="mt-4 grid gap-2 sm:grid-cols-2">{([["cod","Cash on Delivery"],["cash_pickup","Cash on Pickup"],["gcash","GCash"],["digital","Other digital payment"]] as const).map(([value,label]) => <Button key={value} type="button" variant={payment === value ? "default" : "outline"} onClick={() => setPayment(value)}>{label}</Button>)}</div></section></div><aside className="h-fit rounded-lg border bg-card p-5"><h2 className="font-display text-xl font-bold">Review order</h2><div className="mt-4 space-y-2">{cart.map((line) => <div key={line.product.id} className="flex justify-between text-sm"><span>{line.quantity}× {line.product.name}</span><span>{money(line.quantity * line.product.price)}</span></div>)}</div><div className="my-4 border-t"/><div className="flex justify-between text-lg font-bold"><span>Total</span><span className="text-primary">{money(total)}</span></div>{error && <p className="mt-3 text-sm text-destructive">{error}</p>}<Button type="submit" disabled={submitting} className="mt-5 h-12 w-full rounded-full">{submitting ? "Placing order…" : "Place Order"}</Button><p className="mt-3 text-center text-[10px] text-muted-foreground">Payment is collected based on your selected method.</p></aside></form></div>;
}
function Field({ label, children }: { label: string; children: React.ReactNode }) { return <div className="form-field"><Label>{label}</Label>{children}</div>; }
