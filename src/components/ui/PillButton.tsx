import { ArrowRight } from 'lucide-react';

export default function PillButton({children,
onClick,
href,
variant='primary'}:{children:React.ReactNode;
onClick?:()=>void;
href?:string;
variant?:'primary'|'secondary'}){const content=<>{children}{variant==='primary'&&<span className="btn-icon">
  <ArrowRight size={15}/>
</span>}
</>;
return href?<a className={`btn ${variant==='primary'?'dark':'secondary'}`} href={href}>{content}
</a>:<button className={`btn ${variant==='primary'?'dark':'secondary'}`} onClick={onClick}>{content}
</button>}
