import { Router } from "express";
import { query } from "../db.js";

export const vendorsRouter = Router();

type VendorRow = {
  id: string;
  name: string;
  stall: string;
  section: string;
  categories: string[];
  rating: string;
  image_url: string;
  description: string;
  product_count: string;
};

function select(where = "") {
  return `
    select v.id, v.name, v.stall, v.section, v.categories, v.rating, v.image_url, v.description,
           count(p.id) as product_count
    from vendors v
    left join products p on p.vendor_id = v.id
    ${where}
    group by v.id
  `;
}

function toJson(row: VendorRow) {
  return {
    id: row.id,
    name: row.name,
    stall: row.stall,
    section: row.section,
    categories: row.categories,
    rating: Number(row.rating),
    products: Number(row.product_count),
    image: row.image_url,
    description: row.description,
  };
}

// GET /api/vendors
vendorsRouter.get("/", async (_req, res) => {
  const { rows } = await query<VendorRow>(`${select()} order by v.name asc`);
  res.json(rows.map(toJson));
});

// GET /api/vendors/:id
vendorsRouter.get("/:id", async (req, res) => {
  const { rows } = await query<VendorRow>(select("where v.id = $1"), [req.params.id]);
  if (!rows[0]) return res.status(404).json({ error: "Vendor not found" });
  res.json(toJson(rows[0]));
});
