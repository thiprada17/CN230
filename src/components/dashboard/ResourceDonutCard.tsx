import type { ProductRecord } from '../../types/lci';
import { localizeFlowName } from '../../utils/lciLocale';

const colors = ['#A9D3FF', '#FFE59A', '#B7E1D1', '#FFB5C1'];

export default function ResourceDonutCard({ products }: { products: ProductRecord[] }) {
  const counts = products.flatMap((product) => product.exchanges
    .filter((exchange) => exchange.exchange_type === 'Input')
    .map((exchange) => localizeFlowName(product.flows.find((flow) => flow.flow_id === exchange.flow_id)?.flow_name || 'Other flows')))
    .reduce<Record<string, number>>((result, name) => {
      result[name] = (result[name] || 0) + 1;
      return result;
    }, {});
  const sorted = Object.entries(counts).sort((left, right) => right[1] - left[1]);
  const topItems = sorted.slice(0, 3);
  const otherCount = sorted.slice(3).reduce((sum, item) => sum + item[1], 0);
  if (otherCount) topItems.push(['รายการอื่น', otherCount]);
  const total = Object.values(counts).reduce((sum, count) => sum + count, 0);
  let cursor = 0;
  const gradient = topItems.map(([, count], index) => {
    const start = (cursor / total) * 100;
    cursor += count;
    return `${colors[index % colors.length]} ${start}% ${(cursor / total) * 100}%`;
  }).join(', ');

  return (
    <article className="panel resource-panel">
      <div className="panel-head">
      <div><div className="eyebrow">Input</div><h3>วัตถุดิบที่นำเข้าระบบ</h3></div>
      </div>
      {total ? (
        <div className="donut-wrap">
          <div className="donut" style={{ background: `conic-gradient(${gradient})` }}>
        <div className="donut-center"><b>{total}</b><small>จำนวนรายการวัตถุดิบ</small></div>
          </div>
          <div className="legend">
            {topItems.map(([name, count], index) => (
              <div className="legend-row" key={name}>
                <span className="legend-label"><i style={{ background: colors[index % colors.length] }} />{name}</span>
                <b>{Math.round((count / total) * 100)}%</b>
              </div>
            ))}
          </div>
        </div>
      ) : <div className="empty-state">ไม่มีรายการวัตถุดิบที่นำเข้าตามตัวกรอง</div>}
    </article>
  );
}
