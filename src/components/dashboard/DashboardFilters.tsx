import { ChevronDown, Database, MapPin } from 'lucide-react';
import { localizeCategoryLabel, localizeLocation } from '../../utils/lciLocale';

interface Props {
  province: string;
  setProvince: (value: string) => void;
  year: string;
  setYear: (value: string) => void;
  provinces: string[];
  category: string;
  setCategory: (value: string) => void;
  categories: string[];
  years: string[];
}

export default function DashboardFilters({
  province, setProvince, year, setYear, provinces, category, setCategory, categories, years,
}: Props) {
  return (
    <div className="filters">
      <label>
        <Database size={14} />
        <select aria-label="หมวดผลิตภัณฑ์" value={category} onChange={(event) => setCategory(event.target.value)}>
          {categories.map((item) => <option key={item} value={item}>{localizeCategoryLabel(item)}</option>)}
        </select>
        <ChevronDown size={13} />
      </label>
      <label>
        <MapPin size={14} />
        <select aria-label="จังหวัด" value={province} onChange={(event) => setProvince(event.target.value)}>
          <option value="All provinces">ทุกจังหวัด</option>
          {provinces.map((item) => <option key={item} value={item}>{localizeLocation(item)}</option>)}
        </select>
        <ChevronDown size={13} />
      </label>
      <label>
        <Database size={14} />
        <select aria-label="ปีข้อมูล" value={year} onChange={(event) => setYear(event.target.value)}>
          {years.map((item) => <option key={item} value={item}>{item}</option>)}
          <option value="All years">ทุกปี</option>
        </select>
        <ChevronDown size={13} />
      </label>
    </div>
  );
}
