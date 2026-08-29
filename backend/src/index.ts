import express from "express";
import cors from "cors";
import { productsRouter } from "./routes/products.js";
import { vendorsRouter } from "./routes/vendors.js";
import { ordersRouter } from "./routes/orders.js";

const app = express();

app.use(cors()); // both web_app (browser) and flutter_app (mobile) call this API
app.use(express.json());

app.get("/health", (_req, res) => res.json({ status: "ok" }));

app.use("/api/products", productsRouter);
app.use("/api/vendors", vendorsRouter);
app.use("/api/orders", ordersRouter);

app.use((err: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  res.status(500).json({ error: "Internal server error" });
});

const port = Number(process.env.PORT) || 4000;
app.listen(port, () => console.log(`Palengke backend listening on :${port}`));
