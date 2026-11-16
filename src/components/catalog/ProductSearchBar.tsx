import { Search } from 'lucide-react';
import { categoryColor, localizeCategoryLabel } from '../../utils/lciLocale';

interface Props {
  query: string;
  setQuery: (value: string) => void;
  categories: string[];
  category: string;
  setCategory: (value: string) => void;
}

export default function ProductSearchBar({ query, setQuery, categories, category, setCategory }: Props) {
  return (
    <div className="catalog-controls">
      <div className="searchbox">
        <Search size={17} />
        <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="ค้นหาผลิตภัณฑ์หรือวัตถุดิบ" />
        <kbd>↵</kbd>
      </div>
      <div className="category-chips">
        {categories.map((item) => (
          <button
            key={item}
            onClick={() => setCategory(item)}
            className={`chip ${category === item ? 'chip-active' : ''}`}
            style={{ '--chip': categoryColor(item) } as React.CSSProperties}
          >
            {localizeCategoryLabel(item)}
          </button>
        ))}
      </div>
    </div>
  );
}
