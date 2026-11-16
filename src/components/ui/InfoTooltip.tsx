import { Info } from 'lucide-react';

interface Props {
  content: string;
}

export default function InfoTooltip({ content }: Props) {
  return (
    <span className="info-tooltip">
      <button
        className="info-tooltip-trigger"
        type="button"
        aria-label={`ข้อมูลเพิ่มเติม: ${content}`}
      >
        <Info size={14} aria-hidden="true" />
      </button>
      <span className="info-tooltip-content" role="tooltip">
        {content}
      </span>
    </span>
  );
}
