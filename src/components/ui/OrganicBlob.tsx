import type { ProductRecord } from '../../types/lci';
import { iconForCategory, localizeProductName } from '../../utils/lciLocale';

type CropKind = 'rice' | 'cassava' | 'maize' | 'sugar' | 'pineapple';

function ProductGlyph({ kind, name }: { kind: CropKind; name: string }) {
  const normalizedName = name.toLowerCase();
  const gold = '#E5B735';
  const green = '#519675';
  const line = { fill: 'none', strokeWidth: 5.5, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const };

  if (kind === 'rice') {
    if (/husk|เปลือก/.test(normalizedName)) return <g {...line} stroke={green}>
      <path d="M50 82V28M50 57C36 48 27 38 25 24c14 5 24 16 25 31ZM50 67c13-7 22-19 24-34-14 5-23 16-24 31Z" />
      <path stroke={gold} d="M49 33c-7-8-10-14-9-21m13 21c8-8 11-14 10-21" />
    </g>;
    if (/bran|รำ/.test(normalizedName)) return <g {...line} stroke={green}>
      <path d="M24 69c8-17 19-26 34-26 12 0 20 6 23 16-5 17-18 25-36 25-10 0-17-5-21-15Z" />
      <path stroke={gold} d="M34 65c11 2 22 7 32 14M41 53l22 25" />
    </g>;
    if (/broken|withered|ปลายข้าว|ลีบ/.test(normalizedName)) return <g {...line} stroke={gold}>
      <path d="M29 63c0-13 9-23 21-23s21 10 21 23-9 22-21 22-21-9-21-22Z" />
      <path stroke={green} d="m38 53 24 20m-24 0 24-20" />
    </g>;
    if (/milled|ขัดสี/.test(normalizedName)) return <g {...line} stroke={gold}>
      <path d="M31 69c0-5 7-9 19-9s19 4 19 9-7 9-19 9-19-4-19-9Zm5-13c0-5 6-9 14-9s14 4 14 9-6 9-14 9-14-4-14-9Zm9-13c0-4 2-7 5-7s5 3 5 7" />
    </g>;
    return <g {...line}>
      <path fill={green} stroke="none" d="M44 82V51c-12-2-19-9-21-21 13 1 21 8 24 19 5 9 13 14 26 16-4 12-13 18-29 17Z" />
      <path fill={gold} stroke="none" d="M44 18h19v7H51v6h14v7H51v6h12v7H44V18Zm16 18h16v7H67v6h10v7H60V36Z" />
      <path stroke={gold} d="M46 82V18m15 64V36m13 46V47" />
    </g>;
  }

  if (kind === 'cassava') {
    if (/starch|แป้ง/.test(normalizedName)) return <g {...line}>
      <path stroke={green} d="M28 71c9 6 35 6 44 0" />
      <path stroke={gold} d="M28 68c4-8 12-12 22-12s18 4 22 12c-4 6-12 9-22 9s-18-3-22-9Zm12-21 4-8m8 8 1-11m7 11 5-8" />
    </g>;
    return <g {...line}>
      <path fill={green} stroke="none" d="M47 51V23c-12 0-19-7-20-18 12 1 20 7 23 17C54 12 63 7 75 7c-2 10-8 17-21 18v26Z" />
      <path fill={gold} stroke="none" d="M46 47h10c-1 12 2 21 11 32l-6 7c-8-7-12-14-14-22-2 10-7 17-15 23l-6-7c11-10 16-20 15-33l5-3Z" />
    </g>;
  }

  if (kind === 'maize') {
    if (/residue|leaves|stalk|เศษซาก/.test(normalizedName)) return <g {...line}>
      <path stroke={gold} d="M49 83V25m8 58V43" />
      <path stroke={green} d="M49 48C35 48 26 40 23 28c14 0 23 7 26 17m8 14c14-1 22-9 24-21-13 1-21 8-24 18M49 66c-12 0-20-6-24-16 12 0 20 5 24 13" />
    </g>;
    return <g {...line}>
      <path stroke={green} d="M35 28c-9 10-12 27-7 43m37-43c9 10 12 27 7 43M31 65c9 8 29 8 38 0" />
      <path stroke={gold} d="M34 31c0-8 7-14 16-14s16 6 16 14v31c0 8-7 14-16 14s-16-6-16-14V31Z" />
      <path stroke={gold} d="M35 38h30M34 48h32M34 58h32m-21-39v55m10-55v55" />
    </g>;
  }

  if (kind === 'sugar') {
    if (/sugar$|น้ำตาล/.test(normalizedName)) return <g {...line} stroke={gold}>
      <path d="M31 39 50 28l19 11v23L50 73 31 62V39Zm19-11v22m19-11L50 50 31 39m19 11v23" />
      <path stroke={green} d="M50 27c-1-7 3-12 10-16m-10 16c-7-5-8-11-5-17" />
    </g>;
    if (/molasses|กากน้ำตาล/.test(normalizedName)) return <g {...line}>
      <path stroke={gold} d="M50 19c-9 13-19 24-19 37a19 19 0 0 0 38 0c0-13-10-24-19-37Z" />
      <path stroke={green} d="M39 59c2 7 7 10 14 10" />
    </g>;
    if (/bagasse|filter cake|ชานอ้อย|กากตะกอน/.test(normalizedName)) return <g {...line}>
      <path stroke={gold} d="m28 68 39-39m-34 49 43-42M23 58l36-36" />
      <path stroke={green} d="M25 75c12 4 28 3 49-5" />
    </g>;
    return <g {...line}>
      <path stroke={gold} strokeWidth="8" d="M39 82V26m12 56V19m12 63V29" />
      <path stroke={gold} strokeWidth="2.5" d="M35 43h8m4-11h8m4 23h8m-28 10h8m4-30h8m4 35h8" />
      <path fill={green} stroke="none" d="M39 42C28 40 22 33 21 23c11 1 18 6 21 16m20 10c12-1 19-8 21-18-12 1-19 7-22 16M50 70c-12-1-19-8-21-18 12 1 19 7 22 16" />
    </g>;
  }

  if (/canned|กระป๋อง/.test(normalizedName)) return <g {...line}>
    <path stroke={gold} d="M34 29c0-5 7-9 16-9s16 4 16 9v42c0 5-7 9-16 9s-16-4-16-9V29Zm0 0c0 5 7 9 16 9s16-4 16-9m-32 42c0 5 7 9 16 9s16-4 16-9" />
    <path stroke={green} d="M50 53c-7-6-7-12-1-17 7 5 7 11 1 17Zm0 0c7-6 7-12 1-17" />
  </g>;
  if (/residue|stems|crowns|เศษเหลือ|ลำต้น|จุก/.test(normalizedName)) return <g {...line}>
    <path fill={green} stroke="none" d="M48 43 30 21c11 0 19 5 22 15 0-14 8-23 20-26-1 13-8 23-19 29l17-14c1 11-4 19-16 23l-4 13h-8l-3-18Z" />
    <path stroke={gold} strokeWidth="7" d="M44 57v25m11-25v25" />
  </g>;
  if (/peel|เปลือก/.test(normalizedName)) return <g {...line}>
    <path fill={gold} stroke="none" d="M31 70c-8-13-5-31 8-41 12-9 27-7 34 2-13-3-24 2-29 12-5 9-4 17 2 25 5 7 14 11 24 9-11 10-29 8-39-7Z" />
    <path stroke={green} strokeWidth="3" d="m37 45 9 6m-11 5 12 7m-5-24 9 6m-4 21 11 7m-5-41 9 6m-8 25 11 6" />
  </g>;
  if (/core|แกน/.test(normalizedName)) return <g {...line}>
    <path fill={gold} stroke="none" d="M42 20h16l7 11v39l-7 11H42l-7-11V31l7-11Z" />
    <path stroke={green} strokeWidth="3" d="M43 28v45m14-45v45M37 37h26M37 62h26" />
  </g>;
  return <g {...line}>
    <path fill={green} stroke="none" d="M49 38c-9-5-13-13-12-24 9 4 14 10 14 19 2-12 9-19 20-21 0 12-7 21-19 26l-1 6h-3l1-6Z" />
    <path fill={gold} stroke="none" d="M39 39c-7 5-11 14-10 25 1 12 9 20 21 20s20-8 21-20c1-11-3-20-10-25H39Z" />
    <path stroke={green} strokeWidth="2.6" d="m35 48 30 31m-34-18 22 23m32-29L44 81m28-18L50 41" />
  </g>;
}

export default function OrganicBlob({
  category,
  productName,
  compact = false,
}: {
  category: ProductRecord['category'];
  productName: string;
  compact?: boolean;
}) {
  const kind = iconForCategory(category);
  return (
    <span className={`organic-blob${compact ? ' compact' : ''}`} role="img" aria-label={`ภาพประกอบ${localizeProductName(productName)}`}>
      <span className="organic-blob-icon">
        <svg viewBox="0 0 100 100" aria-hidden="true" className="crop-glyph">
          <ProductGlyph kind={kind} name={productName} />
        </svg>
      </span>
    </span>
  );
}
