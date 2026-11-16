import { useMemo, useState } from 'react';
import type { ProductRecord } from './types/lci';
import Navbar from './components/layout/Navbar';
import DashboardSection from './components/dashboard/DashboardSection';
import ProductCatalogSection from './components/catalog/ProductCatalogSection';
import ProductDetail from './components/detail/ProductDetail';
import { useLciProducts } from './hooks/useLciProducts';
import { localizeProductName } from './utils/lciLocale';

export default function App() {
  const records = useLciProducts();
  const [active, setActive] = useState<ProductRecord | null>(null);
  const [query, setQuery] = useState('');
  const [category, setCategory] = useState('All');
  const [province, setProvince] = useState('All provinces');
  const [year, setYear] = useState('All years');
  const categories = ['All', ...new Set(records.map((product) => product.category))];
  const filtered = useMemo(() => records.filter((product) =>
    (category === 'All' || product.category === category)
    && (province === 'All provinces' || product.location.province === province)
    && (year === 'All years' || product.batches.some((batch) => batch.production_date.startsWith(year)))
    && `${product.product_name} ${localizeProductName(product.product_name)}`.toLowerCase().includes(query.toLowerCase())),
  [records, category, province, year, query]);
  const scrollTop = () => window.scrollTo({ top: 0, behavior: 'smooth' });
  const openProduct = (product: ProductRecord) => { setActive(product); scrollTop(); };
  const goBack = () => { setActive(null); scrollTop(); };

  return <>
    <Navbar onHome={goBack} />
    {active ? <ProductDetail product={active} onBack={goBack} /> : <main id="top">
      <DashboardSection records={records} products={filtered} province={province} setProvince={setProvince} year={year} setYear={setYear} category={category} setCategory={setCategory} categories={categories} />
      <ProductCatalogSection products={filtered} query={query} setQuery={setQuery} categories={categories} category={category} setCategory={setCategory} onOpen={openProduct} />
    </main>}
  </>;
}
