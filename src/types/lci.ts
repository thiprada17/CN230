export interface ProductCategory {
  category_id: number;
  category_name: string;
  description: string | null;
}

export interface Unit {
  unit_id: number;
  unit_name: string;
  unit_symbol: string;
  unit_type: string;
  base_unit_id: number | null;
  conversion_factor_to_base: number;
}

export interface Product {
  product_id: number;
  product_name: string;
  category_id: number;
  description: string | null;
  unit_id: number;
}

export interface Material {
  material_id: number;
  material_name: string;
  material_type: string;
  unit_id: number;
  description: string | null;
}

export interface Location {
  location_id: number;
  province: string | null;
  district: string | null;
  country: string;
  latitude: number | null;
  longitude: number | null;
}

export interface Supplier {
  supplier_id: number;
  supplier_name: string;
  location_id: number;
  supplier_type: string | null;
  contact_info: string | null;
}

export interface DataSource {
  source_id: number;
  organization_name: string;
  document_name: string;
  publication_year: number;
  reference_url: string;
  access_date: string | null;
}

export interface MaterialSupplier {
  material_supplier_id: number;
  material_id: number;
  supplier_id: number;
  source_id: number;
}

export interface Process {
  process_id: number;
  process_name: string;
  description: string | null;
}

export interface ProcessStep {
  step_id: number;
  process_id: number;
  step_name: string;
  step_order: number;
  description: string | null;
}

export interface ProductionBatch {
  batch_id: number;
  product_id: number;
  production_date: string | null;
  production_quantity: number;
  unit_id: number;
  location_id: number;
  production_year?: number | null;
  area_ha?: number | null;
}

export interface BatchProcess {
  batch_process_id: number;
  batch_id: number;
  step_id: number;
  execution_order: number;
  location_id: number;
  started_at: string | null;
  completed_at: string | null;
}

export interface Flow {
  flow_id: number;
  flow_name: string;
  flow_type: string;
  material_id: number | null;
  product_id: number | null;
  unit_id: number;
}

export interface LciExchange {
  exchange_id: number;
  batch_process_id: number;
  flow_id: number;
  exchange_type: string;
  amount: number;
  unit_id: number;
  source_id: number;
  data_year: number;
}

export interface EnvironmentalImpact {
  impact_id: number;
  batch_process_id: number;
  impact_type: string;
  impact_amount: number;
  unit_id: number;
  source_id: number;
  data_year: number;
}

export interface ProductionBatchDTO extends ProductionBatch {
  process_id: number;
  production_date: string;
  location: Location;
}

export interface LciExchangeDTO extends LciExchange {
  process_id: number;
  batch_id: number;
  exchange_type: 'Input' | 'Output';
  unit_symbol?: string;
  base_unit_symbol?: string | null;
  conversion_factor_to_base?: number;
}

export interface EnvironmentalImpactDTO extends EnvironmentalImpact {
  process_id: number;
  batch_id: number;
}

export interface ProcessDTO extends Process {
  location_id: number;
  unit_id: number;
}

export interface ProductRecord extends Product {
  category: string;
  functionalUnit: string;
  location: Location;
  supplier: Supplier;
  process: ProcessDTO;
  steps: ProcessStep[];
  batches: ProductionBatchDTO[];
  flows: (Flow & { description: string })[];
  exchanges: LciExchangeDTO[];
  impacts: EnvironmentalImpactDTO[];
  sources: DataSource[];
  accent: string;
  glyph: string;
}

export interface DashboardSummary {
  totalProducts: number;
  totalInput: number;
  totalYield: number;
  totalGhg: number;
}
