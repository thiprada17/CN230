import { Sprout } from 'lucide-react';

export default function Navbar({ onHome }: { onHome: () => void }) {
  return (
    <header className="topbar">
      <a className="brand" href="#top" onClick={onHome}>
        <span className="brand-icon"><Sprout size={20} /></span>
        <span>GROUP<span className="brand-light"> 2</span><small>Food &amp; Agro Processing</small></span>
      </a>
      <nav>
        <a href="#overview">แดชบอร์ด</a>
        <a href="#catalog">ผลิตภัณฑ์</a>
      </nav>
    </header>
  );
}
