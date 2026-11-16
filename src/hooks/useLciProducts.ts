import { useEffect,
   useState } from 'react';

import type { ProductRecord } from '../types/lci';

import { lciService } from '../services/lciService';

export function useLciProducts(){const [records,
  setRecords]=useState<ProductRecord[]>([]);
useEffect(()=>{lciService.getProducts().then(setRecords).catch(error=>console.error('Unable to load LCI products',
  error))},
  []);
return records}
