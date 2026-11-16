import type { ProductRecord } from '../../types/lci';
import PastelBadge from '../ui/PastelBadge';
import { categoryColor, emojiForCategory, localizeCategory, localizeFunctionalUnit, localizeLocation, localizeProductDescription, localizeProductName, localizeSupplier } from '../../utils/lciLocale';

export default function ProductHeaderCard({ product }: { product: ProductRecord }) {
  const origin = [localizeLocation(product.location.province), localizeLocation(product.location.district)]
    .filter(Boolean)
    .join(', ');
  const hasCoordinates = product.location.latitude != null && product.location.longitude != null;
  const coordinates = hasCoordinates
    ? `${product.location.latitude}°N, ${product.location.longitude}°E`
    : 'ไม่ได้ระบุพิกัด';
  const accent = categoryColor(product.category);

  return (
    <div className="detail-hero">
      <div className="detail-art" style={{ '--art': accent } as React.CSSProperties}>
        <span className="product-category-emoji detail-art-emoji" role="img" aria-label={localizeCategory(product.category)}>
          {emojiForCategory(product.category)}
        </span>
      </div>
      <div className="detail-intro">
        <PastelBadge color={accent}>{localizeCategory(product.category)}</PastelBadge>
        <h1>{localizeProductName(product.product_name)}</h1>
        <p>{localizeProductDescription(product.description)}</p>
        <div className="metadata-grid">
          <div><span>หน่วย</span><b>{localizeFunctionalUnit(product.functionalUnit)}</b></div>
          <div><span>แหล่งที่ผลิต</span><b>{origin || 'ไม่ได้ระบุพื้นที่'}</b></div>
          <div><span>พิกัด</span><b>{coordinates}</b></div>
          <div><span>ผู้จัดหา</span><b>{localizeSupplier(product.supplier.supplier_name)}</b></div>
        </div>
      </div>
    </div>
  );
}
