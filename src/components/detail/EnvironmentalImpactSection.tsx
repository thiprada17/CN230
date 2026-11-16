import { Droplets, Zap } from 'lucide-react';
import type { EnvironmentalImpact } from '../../types/lci';
import { localizeImpactType, localizeUnitId } from '../../utils/lciLocale';

export default function EnvironmentalImpactSection({ impacts }: { impacts: EnvironmentalImpact[] }) {
  if (impacts.length === 0) {
    return <div className="empty-state">แหล่งข้อมูลชุดนี้ไม่มีค่าผลกระทบสิ่งแวดล้อมที่รายงานไว้</div>;
  }

  return (
    <div className="impact-cards">
      {impacts.map((impact, index) => (
        <div className={`impact-card impact-${index}`} key={impact.impact_id}>
          <span className="impact-icon">{index === 0 ? <Zap size={16} /> : <Droplets size={16} />}</span>
          <span>
            <small>{localizeImpactType(impact.impact_type)}</small>
            <b>{impact.impact_amount.toLocaleString('th-TH', { maximumFractionDigits: 3 })}<em>{localizeUnitId(impact.unit_id)}</em></b>
            <small>ตามหน่วยหน้าที่ของผลิตภัณฑ์</small>
          </span>
        </div>
      ))}
    </div>
  );
}
