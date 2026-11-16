import type { ProductRecord } from '../../types/lci';
import { isMainProductKgOutput } from '../../utils/lciMetrics';

export default function OutputRatioRingCard({ products }: { products: ProductRecord[] }) {
  const outputExchanges = products.flatMap((product) => product.exchanges
    .filter((exchange) => isMainProductKgOutput(product, exchange)));
  const totalOutput = outputExchanges.reduce((sum, exchange) => sum + exchange.amount, 0);

  return (
    <article className="panel yield-panel">
      <div className="panel-head">
        <div><div className="eyebrow">Output</div><h3>ผลผลิต</h3></div>
      </div>
      <div className="output-ring-wrap">
        <span className="output-ring output-ring-outer" aria-hidden="true" />
        <span className="output-ring output-ring-inner" aria-hidden="true" />
        <div className="output-metric">
          <b>{(totalOutput / 1000).toLocaleString('th-TH', { maximumFractionDigits: 1 })}<small> ตัน</small></b>
          <span>จำนวนผลผลิต</span>
        </div>
      </div>
      <div className="output-unit-note">
        {totalOutput.toLocaleString('th-TH', { maximumFractionDigits: 2 })} กก. · 1 ตัน = 1,000 กก.
      </div>
    </article>
  );
}
