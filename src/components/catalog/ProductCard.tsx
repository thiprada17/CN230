import { ArrowUpRight, MapPin } from 'lucide-react';
import type { ProductRecord } from '../../types/lci';
import PastelBadge from '../ui/PastelBadge';
import { categoryColor, emojiForCategory, localizeCategory, localizeLocation, localizeProductName } from '../../utils/lciLocale';

interface Props {
  product: ProductRecord;
  onOpen: (product: ProductRecord) => void;
}

export default function ProductCard({ product, onOpen }: Props) {
  const accent = categoryColor(product.category);

  return (
    <button className="product-card" onClick={() => onOpen(product)}>
      <div className="product-art" style={{ '--art': accent } as React.CSSProperties}>
        <svg className="product-contours" viewBox="0 0 320 230" aria-hidden="true">
          <path d="M160 27C211 25 255 55 261 103C267 155 228 195 171 199C116 204 66 170 63 119C61 68 99 32 160 27Z" />
          <path d="M159 49C203 49 233 77 235 115C237 153 204 177 166 178C125 180 90 155 87 119C85 83 116 51 159 49Z" />
        </svg>
        <span className="product-category-emoji" role="img" aria-label={localizeCategory(product.category)}>
          {emojiForCategory(product.category)}
        </span>
        <span className="art-line-art" aria-hidden="true">✳</span>
      </div>
      <div className="product-info">
        <div className="product-meta">
          <PastelBadge color={accent}>{localizeCategory(product.category)}</PastelBadge>
          <span className="unit-label">FUNCTIONAL UNIT: {product.functionalUnit}</span>
        </div>
        <h3>{localizeProductName(product.product_name)}</h3>
        <p>
          <MapPin size={13} />
          {localizeLocation(product.location.province)}, ประเทศไทย
        </p>
        <div className="product-foot">
          <span>View product LCI</span>
          <i><ArrowUpRight size={16} /></i>
        </div>
      </div>
    </button>
  );
}
