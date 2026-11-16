import { ArrowUpRight,
Database } from 'lucide-react';

import type { DataSource } from '../../types/lci';

export default function DataSourceCard({source}:{source:DataSource}){return <div className="source-card">
  <div className="source-mark">
    <Database size={17}/>
  </div>
  <div>
    <div className="eyebrow">แหล่งอ้างอิง
    </div>
    <h3>{source.organization_name}
    </h3>
    <p>{source.document_name} · {source.publication_year}
    </p>
  </div>
  <a href={source.reference_url} target="_blank" rel="noreferrer" aria-label="เปิดแหล่งอ้างอิง">
    <ArrowUpRight size={16}/>
  </a>
</div>}
