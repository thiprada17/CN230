import type { ProductRecord } from '../../types/lci';
import ProductCard from './ProductCard';
import ProductSearchBar from './ProductSearchBar';

interface Props {
  products: ProductRecord[];
  query: string;
  setQuery: (value: string) => void;
  categories: string[];
  category: string;
  setCategory: (value: string) => void;
  onOpen: (product: ProductRecord) => void;
}

export default function ProductCatalogSection({
  products,
  query,
  setQuery,
  categories,
  category,
  setCategory,
  onOpen,
}: Props) {
  return (
    <section className="catalog" id="catalog">
      <div className="catalog-top">
        <div>
          <h2>PRODUCTS<span className="period">.</span></h2>
        </div>
        <div className="catalog-count">
          <b>{String(products.length).padStart(2, '0')}</b>
          <span>IN LIBRARY</span>
        </div>
      </div>

      <ProductSearchBar
        query={query}
        setQuery={setQuery}
        categories={categories}
        category={category}
        setCategory={setCategory}
      />

      <div className="product-grid">
        {products.map((product) => (
          <ProductCard
            key={product.product_id}
            product={product}
            onOpen={onOpen}
          />
        ))}
      </div>

      {!products.length && (
        <div className="empty-state">ไม่พบผลิตภัณฑ์ ลองเปลี่ยนคำค้นหาหรือหมวดหมู่</div>
      )}

      <div className="catalog-end">
        <span>แสดง {products.length} ผลิตภัณฑ์</span>
        <span>ฐานข้อมูลวัฏจักรชีวิตสินค้าเกษตรและอาหารไทย</span>
      </div>
    </section>
  );
}
