import { useState } from 'react';
import type { Flow, LciExchangeDTO } from '../../types/lci';
import { localizeFlowName, localizeUnit } from '../../utils/lciLocale';

interface Props {
  exchanges: LciExchangeDTO[];
  flows: (Flow & { description: string })[];
}

type ExchangeTab = 'All' | 'Input' | 'Output';
const roleLabel = (value: string) => value === 'Input' ? 'วัตถุดิบที่นำเข้า' : 'ผลผลิต';
const flowTypeLabel = (value: string) => {
  switch (value.toUpperCase()) {
    case 'INPUT': return 'วัตถุดิบหรือทรัพยากร';
    case 'OUTPUT': return 'ผลิตภัณฑ์';
    case 'EMISSION': return 'การปล่อยมลพิษสู่อากาศ';
    case 'WATER_EMISSION': return 'มลพิษทางน้ำ';
    default: return value;
  }
};
const directionLabel = (value: string) => value === 'Input' ? 'นำเข้า' : 'ส่งออก';

function unitFor(exchange: LciExchangeDTO) {
  if (exchange.unit_symbol) return localizeUnit(exchange.unit_symbol);
  return exchange.unit_id === 1 ? 'กก.' : `หน่วย ${exchange.unit_id}`;
}

export default function LciExchangeTable({ exchanges, flows }: Props) {
  const [tab, setTab] = useState<ExchangeTab>('All');
  const shown = exchanges.filter((exchange) => tab === 'All' || exchange.exchange_type === tab);
  const totals = shown.reduce<Record<string, number>>((result, exchange) => {
    const flow = flows.find((item) => item.flow_id === exchange.flow_id);
    if (!flow) return result;
    const label = `${roleLabel(exchange.exchange_type)} · ${unitFor(exchange)}`;
    result[label] = (result[label] || 0) + exchange.amount;
    return result;
  }, {});

  return (
    <>
      <div className="table-tabs">
        {(['All', 'Input', 'Output'] as const).map((value) => (
          <button key={value} className={tab === value ? 'selected' : ''} onClick={() => setTab(value)}>
            {value === 'All' ? 'ทั้งหมด' : roleLabel(value)}
          </button>
        ))}
      </div>
      <div className="table-scroll">
        <table>
          <thead><tr><th>รายการ</th><th>ประเภทข้อมูล</th><th>นำเข้า/ส่งออก</th><th>ปริมาณ</th><th>หน่วยฐาน</th></tr></thead>
          <tbody>
            {shown.map((exchange) => {
              const flow = flows.find((item) => item.flow_id === exchange.flow_id);
              if (!flow) return null;
              const unitSymbol = unitFor(exchange);
              const factor = exchange.conversion_factor_to_base ?? 1;
              const standardizedUnit = localizeUnit(exchange.base_unit_symbol || exchange.unit_symbol || unitSymbol);
              const color = exchange.exchange_type === 'Output' ? '#FFE59A' : '#B7E1D1';
              return (
                <tr key={exchange.exchange_id}>
                  <td><b>{localizeFlowName(flow.flow_name)}</b><small>{flowTypeLabel(flow.flow_type)}</small></td>
                  <td><span className="flow-badge" style={{ '--chip': color } as React.CSSProperties}>{flowTypeLabel(flow.flow_type)}</span></td>
                  <td><span className={`exchange-type ${exchange.exchange_type.toLowerCase()}`}>{directionLabel(exchange.exchange_type)}</span></td>
                  <td>{exchange.amount.toLocaleString('th-TH')} <small>{unitSymbol}</small></td>
                  <td><b>{(exchange.amount * factor).toLocaleString('th-TH')}</b><small> {standardizedUnit}</small></td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <div className="group-totals">
        {Object.entries(totals).map(([label, amount]) => <span key={label}>{label}<b>{amount.toLocaleString('th-TH')}</b></span>)}
      </div>
      <div className="table-total">
        <span>แสดง {shown.length} รายการ</span>
      </div>
    </>
  );
}
