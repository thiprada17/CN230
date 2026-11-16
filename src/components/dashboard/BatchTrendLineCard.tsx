import type { ProductRecord } from '../../types/lci';
import { isMainProductKgOutput } from '../../utils/lciMetrics';
import { localizeLocation } from '../../utils/lciLocale';

interface BatchOutput {
  id: string;
  place: string;
  year: string;
  amount: number;
}

function getBatchOutputs(products: ProductRecord[]): BatchOutput[] {
  return products.flatMap((product) => product.batches.map((batch) => {
    const amount = product.exchanges
      .filter((exchange) => exchange.batch_id === batch.batch_id
        && isMainProductKgOutput(product, exchange))
      .reduce((sum, exchange) => sum + exchange.amount, 0);

    return {
      id: `${product.product_id}-${batch.batch_id}`,
      place: localizeLocation(batch.location?.province || product.location.province || `ชุดการผลิต ${batch.batch_id}`),
      year: batch.production_year || batch.production_date?.slice(0, 4)
        ? `ปี ${batch.production_year || batch.production_date?.slice(0, 4)}`
        : 'ไม่มีข้อมูลปี',
      amount,
    };
  }));
}

export default function BatchTrendLineCard({ products }: { products: ProductRecord[] }) {
  const batches = getBatchOutputs(products)
    .filter((batch) => batch.amount > 0)
    .sort((left, right) => right.amount - left.amount);
  const total = batches.reduce((sum, batch) => sum + batch.amount, 0);
  const maxAmount = Math.max(...batches.map((batch) => batch.amount), 0);
  const visibleBatches = batches.slice(0, 5);

  return (
    <article className="panel trend-panel">
      <div className="panel-head">
        <div>
          <div className="eyebrow">product batch</div>
          <h3>ผลผลิตแยกตามพื้นที่</h3>
        </div>
      </div>

      {batches.length ? (
        <>
          <div className="trend-summary">
            <b>{total.toLocaleString('th-TH', { maximumFractionDigits: 1 })} <small>กก.</small></b>
          </div>

          <ul className="batch-output-list">
            {visibleBatches.map((batch) => (
              <li key={batch.id}>
                <div className="batch-output-label">
                  <b>{batch.place}</b>
                  <span>{batch.year}</span>
                </div>
                <div className="batch-output-value">
                <b>{batch.amount.toLocaleString('th-TH', { maximumFractionDigits: 2 })} <small>กก.</small></b>
                  <div
                    className="batch-output-track"
                    role="img"
                    aria-label={`สัดส่วนผลผลิต ${Math.round((batch.amount / maxAmount) * 100)} เปอร์เซ็นต์`}
                  >
                    <span style={{ width: `${(batch.amount / maxAmount) * 100}%` }} />
                  </div>
                </div>
              </li>
            ))}
          </ul>
        </>
      ) : (
        <div className="empty-state">ไม่พบข้อมูลผลผลิตจากชุดการผลิตที่เลือก</div>
      )}
    </article>
  );
}
