import { TimelineEvent } from '../components/timeline_event';
import React from "react";
export default function UpcomingDeadlines({ deadlines }: { deadlines: any[] }) {
  return (
    <div>
      {deadlines.map((d) => {
        return <TimelineEvent {...d} />;
      })}
    </div>
  );
}
