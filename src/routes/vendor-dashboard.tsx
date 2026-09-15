import { createFileRoute, redirect } from "@tanstack/react-router";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/vendor-dashboard")({
  beforeLoad: async () => {
    const { data } = await supabase.auth.getSession();
    if (!data.session) {
      throw redirect({ to: "/auth" });
    }
  },
  head: () => ({
    meta: [{ title: "Vendor Dashboard - Palengke.mq" }],
  }),
  component: VendorDashboardPage,
});

function VendorDashboardPage() {
  return (
    <div className="mx-auto max-w-5xl px-4 py-10 sm:px-6">
      <h1 className="font-display text-2xl font-bold">Vendor Dashboard</h1>
      <p className="mt-2 text-sm text-muted-foreground">
        Welcome back! Products, Orders, Inventory, and Sales tabs go here next.
      </p>
    </div>
  );
}
