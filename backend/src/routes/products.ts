import { Router } from "express";
import { query } from "../db.js";

export const productsRouter = Router();

type ProductRow = {
  id: string;
  vendor_id: string;
  name: string;
  price: string;
  unit: string;
  stock: number;
  category: string;
  image_url: string;
  description: string;
  vendor_name: string;
  vendor_stall: string;
};

const SELECT = `
  select p.id, p.vendor_id, p.name, p.price, p.unit, p.stock, p.category,
         p.image_url, p.description, v.name as vendor_name, v.stall as vendor_stall
  from products p
  join vendors v on v.id = p.vendor_id
`;

function toJson(row: ProductRow) {
  return {
    id: row.id,
    vendorId: row.vendor_id,
    name: row.name,
    price: Number(row.price),
    unit: row.unit,
    stock: row.stock,
    category: row.category,
    image: row.image_url,
    description: row.description,
    vendor: row.vendor_name,
    stall: row.vendor_stall,
  };
}

// GET /api/products?category=Vegetables&search=kamatis
productsRouter.get("/", async (req, res) => {
  const { category, search } = req.query;
  const conditions: string[] = [];
  const params: unknown[] = [];

  if (typeof category === "string" && category !== "All") {
    params.push(category);
    conditions.push(`p.category = $${params.length}`);
  }
  if (typeof search === "string" && search.trim()) {
    params.push(`%${search}%`);
    conditions.push(`p.name ilike $${params.length}`);
  }

  const where = conditions.length ? `where ${conditions.join(" and ")}` : "";
  const { rows } = await query<ProductRow>(`${SELECT} ${where} order by p.name asc`, params);
  res.json(rows.map(toJson));
});

// GET /api/products/:id
productsRouter.get("/:id", async (req, res) => {
  const { rows } = await query<ProductRow>(`${SELECT} where p.id = $1`, [req.params.id]);
  if (!rows[0]) return res.status(404).json({ error: "Product not found" });
  res.json(toJson(rows[0]));
});
