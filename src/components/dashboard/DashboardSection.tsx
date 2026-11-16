import type { ProductRecord } from '../../types/lci';
import DashboardFilters from './DashboardFilters';
import KpiBentoRow from './KpiBentoRow';
import ResourceDonutCard from './ResourceDonutCard';
import OutputRatioRingCard from './OutputRatioRingCard';
import BatchTrendLineCard from './BatchTrendLineCard';
import ProcessBarChartCard from './ProcessBarChartCard';
import EcoScoreCard from './EcoScoreCard';
import { sumInputKg, sumMainOutputKg } from '../../utils/lciMetrics';

interface Props {
  records: ProductRecord[];
  products: ProductRecord[];
  province: string;
  setProvince: (value: string) => void;
  year: string;
  setYear: (value: string) => void;
  category: string;
  setCategory: (value: string) => void;
  categories: string[];
}

export default function DashboardSection({
  records,
  products,
  province,
  setProvince,
  year,
  setYear,
  category,
  setCategory,
  categories,
}: Props) {
  const inputKg = sumInputKg(products);
  const outputKg = sumMainOutputKg(products);
  const impacts = products.flatMap((product) => product.impacts);
  const ghgRows = impacts.filter((impact) => /ghg|climate/i.test(impact.impact_type));
  const ghg = ghgRows.length
    ? `${ghgRows.reduce((sum, impact) => sum + impact.impact_amount, 0).toLocaleString('th-TH', { maximumFractionDigits: 1 })} กก. CO₂e`
    : '—';

  return (
    <section className="dashboard" id="overview">
      <div className="section-heading">
        <div>
          <div className="eyebrow">ภาพรวมของฐานข้อมูล <span className="eyebrow-line" /></div>
          <h2>Dashboard</h2>
        </div>
        <DashboardFilters
          province={province}
          setProvince={setProvince}
          year={year}
          setYear={setYear}
          provinces={[...new Set(records.map((product) => product.location.province).filter((value): value is string => Boolean(value)))]}
          category={category}
          setCategory={setCategory}
          categories={categories}
          years={[...new Set(records.flatMap((product) => product.batches.map((batch) => String(batch.production_year || batch.production_date.slice(0, 4)))))]}
        />
      </div>

      <KpiBentoRow
        products={products.length}
        input={inputKg}
        yieldKg={outputKg}
        ghg={ghg}
        hasGhgData={ghgRows.length > 0}
      />

      <div className="analytics-grid">
        <ResourceDonutCard products={products} />
        <OutputRatioRingCard products={products} />
        <BatchTrendLineCard products={products} />
      </div>
      <div className="analytics-grid bottom-analytics">
        <ProcessBarChartCard products={products} />
        <EcoScoreCard products={products} />
      </div>

    </section>
  );
}
