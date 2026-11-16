import { useState } from 'react';
import { ArrowLeft, Globe2 } from 'lucide-react';
import type { ProductRecord } from '../../types/lci';
import DataSourceCard from './DataSourceCard';
import EnvironmentalImpactSection from './EnvironmentalImpactSection';
import LciExchangeTable from './LciExchangeTable';
import ProcessStepsTimeline from './ProcessStepsTimeline';
import ProductHeaderCard from './ProductHeaderCard';
import { localizeFunctionalUnit } from '../../utils/lciLocale';

interface Props {
  product: ProductRecord;
  onBack: () => void;
}

export default function ProductDetail({ product, onBack }: Props) {
  const [batchIndex, setBatchIndex] = useState(0);
  const batch = product.batches[batchIndex];
  const batchUnit = localizeFunctionalUnit(product.functionalUnit).replace(/^1\s*/, '');

  if (!batch) {
    return (
      <main className="detail-page">
        <button className="back-btn" onClick={onBack}><ArrowLeft size={15} /> กลับไปหน้าฐานข้อมูล</button>
        <ProductHeaderCard product={product} />
        <p className="empty-state">ผลิตภัณฑ์นี้ยังไม่มีข้อมูลชุดการผลิต</p>
      </main>
    );
  }

  const detailProduct = { ...product, location: batch.location || product.location };
  const exchanges = product.exchanges.filter((row) => row.batch_id === batch.batch_id);
  const exchangeSourceIds = new Set(exchanges.map((exchange) => exchange.source_id));
  const batchSources = product.sources.filter((source) => exchangeSourceIds.has(source.source_id));
  const displayedSource = batchSources[0] || product.sources[0];

  return (
    <main className="detail-page">
      <button className="back-btn" onClick={onBack}><ArrowLeft size={15} /> กลับไปหน้าฐานข้อมูล</button>
      <ProductHeaderCard product={detailProduct} />

      <div className="detail-toolbar">
        <div>
          <div className="eyebrow">ชุดการผลิต (product batch) </div>
          <b>
            ชุดที่ {batch.batch_id} · {batch.production_date} · {batch.production_quantity.toLocaleString('th-TH', { maximumFractionDigits: 2 })} {batchUnit}
            {batch.area_ha ? ` · ${batch.area_ha} เฮกตาร์` : ''}
          </b>
        </div>
        <select aria-label="เลือกชุดการผลิต" value={batchIndex} onChange={(event) => setBatchIndex(Number(event.target.value))}>
          {product.batches.map((item, index) => (
            <option key={item.batch_id} value={index}>ชุดที่ {item.batch_id} · {item.production_date}</option>
          ))}
        </select>
      </div>

      <div className="detail-columns">
        <section className="detail-section steps-section">
          <div className="detail-section-head"><h2>ขั้นตอนการผลิต</h2><span className="micro-pill">{product.steps.length} ขั้นตอน</span></div>
          <ProcessStepsTimeline steps={product.steps} />
          {displayedSource && <DataSourceCard source={displayedSource} />}
        </section>

        <section className="detail-section exchanges-section">
          <div className="detail-section-head"><h2>วัตถุดิบที่นำเข้าและผลผลิต</h2></div>
          <LciExchangeTable
            exchanges={exchanges}
            flows={product.flows}
          />
          <EnvironmentalImpactSection impacts={product.impacts.filter((impact) => impact.batch_id === batch.batch_id)} />
        </section>
      </div>


    </main>
  );
}
