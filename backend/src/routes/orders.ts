import { randomUUID } from "node:crypto";
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

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const productIds = body.items.map((item) => item.productId);
    const [products] = await conn.query<any[]>(
      "select id, price, stock from products where id in (?) for update",
      [productIds],
    );

    const priceById = new Map(products.map((p: any) => [p.id, Number(p.price)]));
    const stockById = new Map(products.map((p: any) => [p.id, p.stock]));

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

    // MySQL has no RETURNING clause, so generate the id ourselves before inserting.
    const orderId = randomUUID();
    await conn.query(
      `insert into orders
         (id, customer_name, customer_phone, fulfillment, delivery_address, payment_method, notes, total)
       values (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        orderId,
        body.customerName,
        body.customerPhone,
        body.fulfillment,
        body.deliveryAddress ?? null,
        body.paymentMethod,
        body.notes ?? null,
        total,
      ],
    );

    for (const item of body.items) {
      const price = priceById.get(item.productId)!;
      await conn.query(
        `insert into order_items (id, order_id, product_id, quantity, unit_price) values (?, ?, ?, ?, ?)`,
        [randomUUID(), orderId, item.productId, item.quantity, price],
      );
      await conn.query("update products set stock = stock - ? where id = ?", [
        item.quantity,
        item.productId,
      ]);
    }

    await conn.commit();
    res.status(201).json({ orderId, total });
  } catch (error) {
    await conn.rollback();
    const message = error instanceof Error ? error.message : "Failed to place order";
    res.status(400).json({ error: message });
  } finally {
    conn.release();
  }
});

// GET /api/orders/:id
ordersRouter.get("/:id", async (req, res) => {
  const { rows } = await query(
    `select id, customer_name, customer_phone, fulfillment, delivery_address,
            payment_method, notes, status, total, created_at
     from orders where id = ?`,
    [req.params.id],
  );
  if (!rows[0]) return res.status(404).json({ error: "Order not found" });
  res.json(rows[0]);
});
