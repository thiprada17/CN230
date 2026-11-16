export default function PastelBadge({children,
color='#FFE59A'}:{children:React.ReactNode;
color?:string}){return <span className="category-tag" style={{'--chip':color} as React.CSSProperties}>{children}
</span>}
