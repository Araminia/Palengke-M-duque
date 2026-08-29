import { Pool } from "pg";

const connectionString = process.env.DATABASE_URL;
const caCert = process.env.DATABASE_CA_CERT;

if (!connectionString) {
  throw new Error("DATABASE_URL is not set. Add your Aiven Postgres connection string.");
}

export const pool = new Pool({
  connectionString,
  ssl: caCert ? { ca: caCert, rejectUnauthorized: true } : { rejectUnauthorized: false },
  max: 10,
  idleTimeoutMillis: 30_000,
});

pool.on("error", (err) => console.error("Unexpected Postgres pool error", err));

export async function query<T extends Record<string, unknown> = Record<string, unknown>>(
  text: string,
  params?: unknown[],
) {
  const client = await pool.connect();
  try {
    return await client.query<T>(text, params);
  } finally {
    client.release();
  }
}
