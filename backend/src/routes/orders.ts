import { Router } from "express";
import { pool, query } from "../db.js";

export const ordersRouter = Router();

type PlaceOrderBody = {
  customerName: string;
  customerPhone: string;
  fulfillment: "delivery" | "pickup";
  deliveryAddress?: string;
  paymentMethod: "cod" | "cash_pickup" | "gcash" | "digital";
  notes?: string;
  items: { productId: string; quantity: number }[];
};

// POST /api/orders
ordersRouter.post("/", async (req, res) => {
  const body = req.body as PlaceOrderBody;

  if (!body?.items?.length) {
    return res.status(400).json({ error: "Cannot place an order with no items" });
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const productIds = body.items.map((item) => item.productId);
    const { rows: products } = await client.query<{ id: string; price: string; stock: number }>(
      "select id, price, stock from products where id = any($1::text[]) for update",
      [productIds],
    );

    const priceById = new Map(products.map((p) => [p.id, Number(p.price)]));
    const stockById = new Map(products.map((p) => [p.id, p.stock]));

    let total = 0;
    for (const item of body.items) {
      const price = priceById.get(item.productId);
      const stock = stockById.get(item.productId);
      if (price === undefined || stock === undefined) {
        throw new Error(`Unknown product: ${item.productId}`);
      }
      if (item.quantity > stock) {
        throw new Error(`Not enough stock for ${item.productId}`);
      }
      total += price * item.quantity;
    }

    const { rows: orderRows } = await client.query<{ id: string }>(
      `insert into orders
         (customer_name, customer_phone, fulfillment, delivery_address, payment_method, notes, total)
       values ($1, $2, $3, $4, $5, $6, $7)
       returning id`,
      [
        body.customerName,
        body.customerPhone,
        body.fulfillment,
        body.deliveryAddress ?? null,
        body.paymentMethod,
        body.notes ?? null,
        total,
      ],
    );
    const orderId = orderRows[0]!.id;

    for (const item of body.items) {
      const price = priceById.get(item.productId)!;
      await client.query(
        `insert into order_items (order_id, product_id, quantity, unit_price) values ($1, $2, $3, $4)`,
        [orderId, item.productId, item.quantity, price],
      );
      await client.query("update products set stock = stock - $1 where id = $2", [
        item.quantity,
        item.productId,
      ]);
    }

    await client.query("COMMIT");
    res.status(201).json({ orderId, total });
  } catch (error) {
    await client.query("ROLLBACK");
    const message = error instanceof Error ? error.message : "Failed to place order";
    res.status(400).json({ error: message });
  } finally {
    client.release();
  }
});

// GET /api/orders/:id
ordersRouter.get("/:id", async (req, res) => {
  const { rows } = await query(
    `select id, customer_name, customer_phone, fulfillment, delivery_address,
            payment_method, notes, status, total, created_at
     from orders where id = $1`,
    [req.params.id],
  );
  if (!rows[0]) return res.status(404).json({ error: "Order not found" });
  res.json(rows[0]);
});
