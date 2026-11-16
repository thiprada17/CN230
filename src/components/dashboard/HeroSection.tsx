import { ArrowUpRight, Leaf } from 'lucide-react';

import PillButton from '../ui/PillButton';

export default function HeroSection(){return <section className="hero" id="overview">
  <div className="hero-copy">
    <h1>วัตถุดิบทุกชนิด<br/>มี <em>เรื่องราว
      </em>
    </h1>
    <p>A living inventory of the resources,
      processes and impact behind Thailand’s food & agro-processing products.
    </p>
    <div className="hero-actions">
      <PillButton href="#catalog">Explore products
      </PillButton>
    </div>
  </div>
  <div className="hero-art">
    <div className="art-orbit orbit-one"/>
    <div className="art-orbit orbit-two"/>
    <div className="art-sun"/>
    <div className="art-leaf leaf-a">🌿
    </div>
    <div className="art-leaf leaf-b">🌾
    </div>
    <div className="art-fruit">🍊
    </div>
    <div className="art-card">
      <span className="art-card-icon">
        <Leaf size={15}/>
      </span>
      <span>
        <b>Origin matters
        </b>
        <small>Surin,
          Thailand · 15.31°N
        </small>
      </span>
      <ArrowUpRight size={16}/>
    </div>
  </div>
  <div className="hero-index">01 <span>—
    </span> 04
  </div>
</section>}
