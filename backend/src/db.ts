import mysql from "mysql2/promise";

const connectionString = process.env.DATABASE_URL;
const caCert = process.env.DATABASE_CA_CERT;

if (!connectionString) {
  throw new Error("DATABASE_URL is not set. Add your Aiven MySQL connection string.");
}

export const pool = mysql.createPool({
  uri: connectionString,
  ssl: caCert ? { ca: caCert, rejectUnauthorized: true } : { rejectUnauthorized: false },
  connectionLimit: 10,
  idleTimeout: 30_000,
  namedPlaceholders: false,
});

pool.on("error" as any, (err: unknown) => console.error("Unexpected MySQL pool error", err));

export async function query<T extends Record<string, unknown> = Record<string, unknown>>(
  text: string,
  params?: unknown[],
) {
  const [rows] = await pool.query<mysql.RowDataPacket[]>(text, params);
  return { rows: rows as unknown as T[] };
}
