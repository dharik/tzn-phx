import { TimelineEvent } from '../components/timeline_event';
import React from 'react';
import { useQuery } from 'react-query';
import { getGeneralTimeline } from '../queries';
import { Skeleton, Stack } from '@chakra-ui/react';
export default function UpcomingDeadlines() {
  const { isLoading, data: deadlines } = useQuery('generalTimelineShort', () => getGeneralTimeline(5, 'asc', 'n'), {
    staleTime: 1000 * 60 * 15,
  });

  if (isLoading) {
    return (
      <Stack>
        <Skeleton height="120px" />
        <Skeleton height="120px" />
        <Skeleton height="120px" />
        <Skeleton height="120px" />
        <Skeleton height="120px" />
      </Stack>
    );
  }

  return (
    <div>
      {deadlines.map((d) => {
        return <TimelineEvent {...d} />;
      })}
    </div>
  );
}
