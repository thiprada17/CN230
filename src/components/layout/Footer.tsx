import { Sprout,
ArrowUpRight } from 'lucide-react';

export default function Footer(){return <footer id="method">
  <div className="footer-main">
    <div className="brand footer-brand">
      <span className="brand-icon">
        <Sprout size={20}/>
      </span>
      <span>LCI<span className="brand-light"> ATLAS
        </span>
        <small>THAI FOOD & AGRO
        </small>
      </span>
    </div>
    <p>Making the invisible impact of food production visible — one product at a time.
    </p>
    <a href="#top" className="to-top">Back to top <ArrowUpRight size={14}/>
    </a>
  </div>
  <div className="footer-bottom">
    <span>© 2026 LCI ATLAS · TEAM S2-G02
    </span>
    <nav className="footer-sources" aria-label="แหล่งข้อมูลอ้างอิง">
      <span>แหล่งอ้างอิง</span>
      <a href="https://www.nationthailand.com/news/policy/40059019" target="_blank" rel="noreferrer">Nation Thailand</a>
      <a href="https://li01.tci-thaijo.org/index.php/anres/article/view/241279" target="_blank" rel="noreferrer">ANRES</a>
      <a href="https://doi.org/10.1007/s11356-018-1961-y" target="_blank" rel="noreferrer">Environmental Science and Pollution Research</a>
      <a href="https://doi.org/10.15244/pjoes/69442" target="_blank" rel="noreferrer">PJOES</a>
      <a href="https://www.mdpi.com/2624-7402/5/1/26" target="_blank" rel="noreferrer">AgriEngineering</a>
      <span className="footer-star" aria-hidden="true">✳</span>
    </nav>
  </div>
</footer>}
