import type { ProcessStep } from '../../types/lci';
import { localizeProcessStep } from '../../utils/lciLocale';

export default function ProcessStepsTimeline({steps}:{steps:ProcessStep[]}){const ordered=[...steps].sort((a,
b)=>a.step_order-b.step_order);
return <div className="steps-list">{ordered.map((step,
  index)=>
  <div className="step" key={step.step_id}>
    <div className="step-rail">
      <span>{String(step.step_order).padStart(2,
        '0')}
      </span>{index<ordered.length-1&&<i/>}
    </div>
    <div>
      <h3>{localizeProcessStep(step.step_name, step.description).name}
      </h3>
      <p>{localizeProcessStep(step.step_name, step.description).description}
      </p>
    </div>
  </div>)}
</div>}
