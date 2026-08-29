import vegetables from "@/assets/category-vegetables.jpg";
import fruits from "@/assets/category-fruits.jpg";
import seafood from "@/assets/category-seafood.jpg";
import dryGoods from "@/assets/category-dry-goods.jpg";
import meat from "@/assets/category-meat.jpg";
import poultry from "@/assets/category-poultry.jpg";

export type Product = { id: string; name: string; price: number; unit: string; stock: number; category: string; vendorId: string; vendor: string; stall: string; image: string; description: string };
export type Vendor = { id: string; name: string; stall: string; section: string; categories: string[]; rating: number; products: number; image: string; description: string };

export const categories = ["All", "Vegetables", "Fruits", "Meat", "Fish and Seafood", "Poultry", "Eggs", "Rice and Grains", "Spices and Seasonings", "Dry Goods", "Beverages", "Other Market Products"];

export const vendors: Vendor[] = [
  { id: "nena", name: "Aling Nena's Gulayan", stall: "42", section: "Vegetable Section", categories: ["Vegetables", "Spices"], rating: 4.9, products: 18, image: vegetables, description: "Fresh vegetables delivered daily from Nueva Ecija farms." },
  { id: "marites", name: "Ate Marites Prutas", stall: "55", section: "Fruit Section", categories: ["Fruits"], rating: 4.8, products: 14, image: fruits, description: "Seasonal local fruits, hand-picked every morning." },
  { id: "karne", name: "Karneng Bagong Katay", stall: "23", section: "Meat Section", categories: ["Meat"], rating: 4.7, products: 12, image: meat, description: "Quality pork and beef cut to your preference." },
  { id: "ramil", name: "Kuya Ramil Seafood", stall: "08", section: "Wet Section", categories: ["Fish and Seafood"], rating: 4.9, products: 16, image: seafood, description: "Fresh catch and seafood kept on ice daily." },
  { id: "lito", name: "Mang Lito's Poultry", stall: "17", section: "Poultry Section", categories: ["Poultry", "Eggs"], rating: 4.6, products: 10, image: poultry, description: "Fresh chicken and farm eggs." },
  { id: "ben", name: "Tindahan ni Mang Ben", stall: "61", section: "Dry Goods Section", categories: ["Dry Goods", "Rice and Grains"], rating: 4.8, products: 24, image: dryGoods, description: "Rice, spices, dry goods, and household staples." },
];

export const products: Product[] = [
  { id: "kamatis", name: "Kamatis", price: 80, unit: "kilo", stock: 10, category: "Vegetables", vendorId: "nena", vendor: "Aling Nena's Gulayan", stall: "42", image: vegetables, description: "Hinog at sariwang kamatis, bagong pitas ngayong umaga." },
  { id: "sibuyas", name: "Sibuyas na Pula", price: 120, unit: "kilo", stock: 8, category: "Vegetables", vendorId: "nena", vendor: "Aling Nena's Gulayan", stall: "42", image: vegetables, description: "Lokal na pulang sibuyas." },
  { id: "sili", name: "Siling Labuyo", price: 20, unit: "pack", stock: 15, category: "Spices and Seasonings", vendorId: "nena", vendor: "Aling Nena's Gulayan", stall: "42", image: vegetables, description: "Maanghang at sariwa." },
  { id: "talong", name: "Talong", price: 60, unit: "kilo", stock: 12, category: "Vegetables", vendorId: "nena", vendor: "Aling Nena's Gulayan", stall: "42", image: vegetables, description: "Bagong pitas na talong." },
  { id: "saging", name: "Saging na Lakatan", price: 90, unit: "kilo", stock: 18, category: "Fruits", vendorId: "marites", vendor: "Ate Marites Prutas", stall: "55", image: fruits, description: "Matamis na hinog na lakatan." },
  { id: "mangga", name: "Manggang Carabao", price: 160, unit: "kilo", stock: 6, category: "Fruits", vendorId: "marites", vendor: "Ate Marites Prutas", stall: "55", image: fruits, description: "Matamis at mabangong mangga." },
  { id: "kasim", name: "Baboy Kasim", price: 310, unit: "kilo", stock: 20, category: "Meat", vendorId: "karne", vendor: "Karneng Bagong Katay", stall: "23", image: meat, description: "Fresh pork shoulder, bagong katay." },
  { id: "liempo", name: "Baboy Liempo", price: 330, unit: "kilo", stock: 14, category: "Meat", vendorId: "karne", vendor: "Karneng Bagong Katay", stall: "23", image: meat, description: "Fresh pork belly." },
  { id: "bangus", name: "Bangus", price: 180, unit: "kilo", stock: 9, category: "Fish and Seafood", vendorId: "ramil", vendor: "Kuya Ramil Seafood", stall: "08", image: seafood, description: "Fresh whole milkfish on ice." },
  { id: "tilapia", name: "Tilapia", price: 140, unit: "kilo", stock: 11, category: "Fish and Seafood", vendorId: "ramil", vendor: "Kuya Ramil Seafood", stall: "08", image: seafood, description: "Fresh local tilapia." },
  { id: "manok", name: "Whole Chicken", price: 195, unit: "kilo", stock: 13, category: "Poultry", vendorId: "lito", vendor: "Mang Lito's Poultry", stall: "17", image: poultry, description: "Fresh dressed chicken." },
  { id: "itlog", name: "Farm Eggs", price: 110, unit: "dozen", stock: 20, category: "Eggs", vendorId: "lito", vendor: "Mang Lito's Poultry", stall: "17", image: poultry, description: "Fresh medium brown eggs." },
  { id: "dinorado", name: "Bigas Dinorado", price: 65, unit: "kilo", stock: 50, category: "Rice and Grains", vendorId: "ben", vendor: "Tindahan ni Mang Ben", stall: "61", image: dryGoods, description: "Premium aromatic rice." },
  { id: "asukal", name: "Asukal Brown", price: 75, unit: "kilo", stock: 25, category: "Dry Goods", vendorId: "ben", vendor: "Tindahan ni Mang Ben", stall: "61", image: dryGoods, description: "Brown sugar sold by kilo." },
  { id: "buko", name: "Buko Juice (1L)", price: 80, unit: "bottle", stock: 0, category: "Beverages", vendorId: "ben", vendor: "Tindahan ni Mang Ben", stall: "61", image: fruits, description: "Fresh buko juice, chilled." },
];

export const money = (value: number) => new Intl.NumberFormat("en-PH", { style: "currency", currency: "PHP" }).format(value);