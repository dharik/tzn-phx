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
  Skeleton,
} from '@chakra-ui/react';
import { useNavigate, useParams } from 'react-router';
import { groupBy } from 'lodash-es';
import { TimelineEvent } from '../components/timeline_event';
import React from 'react';
import { getGeneralTimeline, getStudentTimeline, getStudentTimelineList } from '../queries';
const StudentPicker = () => {
  const { studentId } = useParams();
  const navigate = useNavigate();
  const { isLoading, data } = useReactQuery('studentTimelineList', getStudentTimelineList, {
    staleTime: 1000 * 60 * 5,
  });

  if (isLoading) {
    return <Skeleton height="30px" width="120px"></Skeleton>;
  }

  const allStudents = data.flatMap((cohort) => cohort.students);
  const currentStudent = allStudents.find((s) => s.id == studentId);

  return (
    <Menu defaultIsOpen={false}>
      <MenuButton
        as={Button}
        rightIcon={
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth={1.5}
            stroke="currentColor"
            className="w-6 h-6"
          >
            <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
          </svg>
        }
      >
        {currentStudent && currentStudent.name}
        {!currentStudent && 'General Timeline'}
      </MenuButton>
      <MenuList>
        <MenuItem onClick={() => navigate(`/timeline/general`)}>General Timeline</MenuItem>
        <MenuDivider />
        {data.map((cohort) => (
          <MenuGroup title={cohort.name}>
            {cohort.students.map((student) => (
              <MenuItem onClick={() => navigate(`/timeline/${student.id}`)}>{student.name}</MenuItem>
            ))}
          </MenuGroup>
        ))}
      </MenuList>
    </Menu>
  );
};
export default function Timeline() {
  const { studentId } = useParams();

  const { isLoading: loadingGeneral, data: generalTimeline } = useReactQuery(
    'generalTimelineFull',
    () => getGeneralTimeline(0, 'asc', 'n'),
    {
      staleTime: 1000 * 60 * 15,
    }
  );

  const { isLoading: loadingStudent, data: studentTimeline } = useReactQuery(
    ['studentTimeline', studentId],
    () => getStudentTimeline(studentId, 0, 'asc', 'n'),
    {
      staleTime: 1000 * 60 * 1,
      enabled: !!studentId,
    }
  );

  if (loadingGeneral || loadingStudent) {
    return null;
  }

  let events;

  if (studentId && studentTimeline) {
    events = studentTimeline;
  } else if (generalTimeline) {
    events = generalTimeline;
  }

  const groupedByYear = groupBy(events, (event) => event.year);
  return (
    <Center>
      <Container maxW="container.lg">
        <Center my={5}>
          <StudentPicker />
        </Center>
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
