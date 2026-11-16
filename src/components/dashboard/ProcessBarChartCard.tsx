import type { ProductRecord } from '../../types/lci';
import { localizeImpactType, localizeUnitId } from '../../utils/lciLocale';

export default function ProcessBarChartCard({ products }: { products: ProductRecord[] }) {
  const impactCount = products.reduce((sum, product) => sum + product.impacts.length, 0);

  return (
    <article className="panel bar-panel">
      <div className="panel-head">
        <div><div className="eyebrow">Enviroment impact</div><h3>ผลกระทบต่อสิ่งแวดล้อม</h3></div>
      </div>
      {impactCount ? (
        <div className="impact-step-list">
          {products.flatMap((product) => product.impacts.map((impact) => (
            <div className="impact-step-row" key={impact.impact_id}>
              <span>{localizeImpactType(impact.impact_type)}</span>
              <b>{impact.impact_amount.toLocaleString('th-TH')} <small>{localizeUnitId(impact.unit_id)}</small></b>
            </div>
          )))}
        </div>
      ) : (
        <div className="impact-empty">
          <span className="impact-empty-icon">—</span>
          <b>ชุดข้อมูลนี้ไม่มีค่าผลกระทบที่รายงาน</b>
          <p>จะแสดงเฉพาะค่าที่มีในแหล่งข้อมูลเท่านั้น</p>
        </div>
      )}
    </article>
  );
}
