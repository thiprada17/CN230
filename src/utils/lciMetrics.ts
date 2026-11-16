import type { ProductRecord } from '../types/lci';

export function isMainProductKgOutput(
  product: ProductRecord,
  exchange: ProductRecord['exchanges'][number],
) {
  const flow = product.flows.find((item) => item.flow_id === exchange.flow_id);
  return exchange.exchange_type === 'Output'
    && exchange.unit_symbol === 'kg'
    && flow?.product_id === product.product_id;
}

export function sumInputKg(products: ProductRecord[]) {
  return products.reduce((total, product) => total + product.exchanges
    .filter((exchange) => exchange.exchange_type === 'Input' && exchange.unit_symbol === 'kg')
    .reduce((sum, exchange) => sum + exchange.amount, 0), 0);
}

export function sumMainOutputKg(products: ProductRecord[]) {
  return products.reduce((total, product) => total + product.exchanges
    .filter((exchange) => isMainProductKgOutput(product, exchange))
    .reduce((sum, exchange) => sum + exchange.amount, 0), 0);
}

export function formatCompact(value: number) {
  return new Intl.NumberFormat('en-US', {
    notation: 'compact',
    maximumFractionDigits: 1,
  }).format(value);
}
