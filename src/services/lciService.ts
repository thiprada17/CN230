import type { DashboardSummary, ProductRecord } from '../types/lci';
import { products } from '../data/mockLciData';

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || '/api';
const useMockData = import.meta.env.VITE_USE_MOCK_DATA !== 'false';

async function request<T>(path: string, fallback: T): Promise<T> {
  if (useMockData) return fallback;

  const response = await fetch(`${apiBaseUrl}${path}`);
  if (!response.ok) {
    throw new Error(`LCI API error: ${response.status}`);
  }

  return response.json() as Promise<T>;
}

export const lciService = {
  getProducts: () => request<ProductRecord[]>('/products', products),

  getProduct: (id: number) => request<ProductRecord>(
    `/products/${id}/lci`,
    products.find((product) => product.product_id === id)!,
  ),

  getSummary: () => request<DashboardSummary>('/dashboard/summary', {
    totalProducts: products.length,
    totalInput: products.length * 4.2,
    totalYield: products.length * 1.3,
    totalGhg: products.reduce(
      (sum, product) => sum + product.impacts[0].impact_amount,
      0,
    ),
  }),

  getBatches: (id: number) => request(
    `/batches?product_id=${id}`,
    products.find((product) => product.product_id === id)?.batches || [],
  ),
};
