import { Factory, Droplets, Sprout, Zap } from 'lucide-react';
import InfoTooltip from '../ui/InfoTooltip';
import { formatCompact } from '../../utils/lciMetrics';

interface KpiItem {
  color: string;
  icon: React.ReactNode;
  number: string;
  title: string;
  info: string;
}

function Kpi({ color, icon, number, title, info }: KpiItem) {
  return (
    <article className={`kpi ${color}`}>
      <div className="kpi-top">
        <span className="kpi-icon">{icon}</span>
      </div>
      <div className="kpi-number">{number}</div>
      <div className="kpi-title">{title}</div>
      <div className="kpi-foot"><InfoTooltip content={info} /></div>
      <span className="kpi-decoration">✳</span>
    </article>
  );
}

interface Props {
  products: number;
  input: number;
  yieldKg: number;
  ghg: string;
  hasGhgData: boolean;
}

export default function KpiBentoRow({ products, input, yieldKg, ghg, hasGhgData }: Props) {
  return (
    <div className="kpi-grid">
      <Kpi
        color="blue"
        icon={<Factory />}
        number={String(products).padStart(2, '0')}
        title="จำนวนผลิตภัณฑ์"
        info="จำนวนผลิตภัณฑ์ทั้งหมดในหมวดหมู่ที่เลือก"
      />
      <Kpi
        color="yellow"
        icon={<Droplets />}
        number={`${formatCompact(input / 1000)} ตัน`}
          title="วัตถุดิบที่นำเข้า"
          info="มวลวัตถุดิบที่นำเข้ารวม โดยแปลงค่าจากกิโลกรัมเป็นตัน"
      />
      <Kpi
        color="mint"
        icon={<Sprout />}
        number={`${formatCompact(yieldKg / 1000)} ตัน`}
        title="ผลผลิต"
        info="มวลผลผลิตหลักรวม โดยแปลงค่าจากกิโลกรัมเป็นตัน"
      />
      <Kpi
        color="pink"
        icon={<Zap />}
        number={ghg}
        title="การปล่อยก๊าซเรือนกระจก"
        info={hasGhgData
          ? 'ค่าการปล่อยก๊าซเรือนกระจก หน่วยกิโลกรัมคาร์บอนไดออกไซด์เทียบเท่า'
          : 'แหล่งข้อมูลที่เลือกไม่มีการรายงานค่าผลกระทบด้านก๊าซเรือนกระจก'}
      />
    </div>
  );
}
