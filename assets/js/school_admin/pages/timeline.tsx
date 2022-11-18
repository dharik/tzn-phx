import { useQuery as useReactQuery } from 'react-query';
import {
  Box,
  Button,
  Center,
  Container,
  Heading,
  Menu,
  MenuButton,
  MenuDivider,
  MenuGroup,
  MenuItem,
  MenuList,
  Select,
  Skeleton,
} from '@chakra-ui/react';
import { useNavigate, useParams } from 'react-router';
import { groupBy } from 'lodash-es';
import { TimelineEvent } from '../components/timeline_event';
import React, { useState } from 'react';
import { getCohort, getGeneralTimeline, getStudentTimeline } from '../queries';

export default function Timeline({ showSwitcher = true }) {
  const { cohortId, studentId } = useParams();
  const [selectedStudentId, setSelectedStudentId] = useState<number | string>(studentId || '');
  const cohortQuery = useReactQuery(['cohort', cohortId], () => getCohort(cohortId));

  const generalTimelineQuery = useReactQuery('generalTimelineFull', () => getGeneralTimeline(cohortId, 0, 'asc', 'n'), {
    staleTime: 1000 * 60 * 15,
    placeholderData: [],
  });

  const studentTimelineQuery = useReactQuery(
    ['studentTimeline', selectedStudentId],
    () => getStudentTimeline(selectedStudentId, 'asc', 'n'),
    {
      staleTime: 1000 * 60 * 1,
      enabled: selectedStudentId !== '',
    }
  );

  if (!cohortQuery.isSuccess || !generalTimelineQuery.isSuccess) {
    return null;
  }

  const allStudents = cohortQuery.data.students;
  
  let events = [];
  if (selectedStudentId == '') {
    events = generalTimelineQuery.data;
  } else {
    events = studentTimelineQuery.data;
  }
  
  const groupedByYear = groupBy(events, (event) => event.year);

  return (
    <Center>
      <Container maxW="container.lg" py={4}>
        {showSwitcher && (
          <Select
            value={selectedStudentId}
            onChange={(e) => {
              setSelectedStudentId(e.target.value);
            }}
            isDisabled={cohortQuery.isLoading || generalTimelineQuery.isLoading || studentTimelineQuery.isLoading}
          >
            <option value="">General Timeline</option>
            {allStudents.map((student) => (
              <option value={student.id} key={student.id}>
                {student.name}
              </option>
            ))}
          </Select>
        )}
        {Object.entries(groupedByYear).map(([year, events]) => {
          return (
            <>
              <Box my={5}>
                <Center>
                  <Heading as="h2" size="lg">
                    {year}
                  </Heading>
                </Center>
              </Box>
              {events.map((event) => (
                <TimelineEvent {...event} />
              ))}
            </>
          );
        })}
      </Container>
    </Center>
  );
}
