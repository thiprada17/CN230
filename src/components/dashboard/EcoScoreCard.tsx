import type { ProductRecord } from '../../types/lci';

interface Metric {
  label: string;
  count: number;
  color: string;
}

export default function EcoScoreCard({ products }: { products: ProductRecord[] }) {
  const metrics: Metric[] = [
    { label: 'Production batches', count: products.reduce((sum, product) => sum + product.batches.length, 0), color: '#B7E1D1' },
    { label: 'ขั้นตอนการผลิต', count: products.reduce((sum, product) => sum + product.steps.length, 0), color: '#FFE59A' },
    { label: 'LCI exchanges', count: products.reduce((sum, product) => sum + product.exchanges.length, 0), color: '#A9D3FF' },
    { label: 'References', count: products.reduce((sum, product) => sum + product.sources.length, 0), color: '#FFB5C1' },
  ];
  const maximum = Math.max(...metrics.map((metric) => metric.count), 1);

  return (
    <article className="panel score-panel">
        <div className="panel-head">
        <div><div className="eyebrow">Data completeness</div><h3>ชุดข้อมูลที่มีในฐานข้อมูล</h3></div>
      </div>
      <div className="score-list">
        {metrics.map((metric) => (
          <div className="score-row" key={metric.label}>
            <div><span>{metric.label}</span><b>{metric.count}</b></div>
            <div className="score-track">
              <i style={{ width: `${(metric.count / maximum) * 100}%`, background: metric.color }} />
            </div>
          </div>
        ))}
      </div>
    </article>
  );
}
