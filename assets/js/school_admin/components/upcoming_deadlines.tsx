import { h } from 'preact';
import { TimelineEvent } from '../components/timeline_event';

export default function UpcomingDeadlines({ deadlines }: { deadlines: any[] }) {
  return (
    <div>
      {deadlines.map((d) => {
        return <TimelineEvent {...d} />;
      })}
    </div>
  );
}
