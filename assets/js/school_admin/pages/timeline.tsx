import { gql, useQuery } from '@apollo/client';
import { Fragment, h } from 'preact';
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
import DefaultLayout from '../default_layout';
import { groupBy } from 'lodash-es';
import { TimelineEvent } from '../components/timeline_event';

const StudentPicker = () => {
  const { studentId } = useParams();
  const navigate = useNavigate();
  const g = gql`
    query {
      cohorts {
        name
        students {
          id
          name
        }
      }
    }
  `;

  const { loading, error, data } = useQuery(g);

  if (loading) {
    return <Skeleton height="30px" width="120px"></Skeleton>;
  }

  const allStudents = data.cohorts.flatMap((cohort) => cohort.students);
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
        {data.cohorts.map((cohort) => (
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

  let q;

  if (studentId) {
    q = gql`
      query {
        studentTimeline(id: ${studentId}, includePast: true) {
          year
          month
          day
          description
          title
          monthShortname
          completed
        }
      }
    `;
  } else {
    q = gql`
      query {
        generalTimeline {
          year
          month
          day
          title
          description
          monthShortname
        }
      }
    `;
  }

  const { loading, error, data } = useQuery(q);

  if (loading) {
    return null;
  }

  let events;

  if (data.generalTimeline) {
    events = data.generalTimeline;
  } else if (data.studentTimeline) {
    events = data.studentTimeline;
  }

  const groupedByYear = groupBy(events, (event) => event.year);
  return (
    <DefaultLayout>
      <Center>
        <Container maxW="container.lg">
          <Center my={5}>
            <StudentPicker />
          </Center>
          {Object.entries(groupedByYear).map(([year, events]) => {
            return (
              <Fragment>
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
              </Fragment>
            );
          })}
        </Container>
      </Center>
    </DefaultLayout>
  );
}
