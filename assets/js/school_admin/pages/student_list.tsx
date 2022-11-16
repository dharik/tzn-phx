import {
  Skeleton,
  Table,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
  Link,
  Container,
  Heading,
  HStack,
  Text,
  Box,
  Tooltip,
} from '@chakra-ui/react';
import { Link as RouterLink } from 'react-router-dom';
import React from 'react';

import * as queries from '../queries';
import { useQuery } from 'react-query';

import { parseISO, formatRelative } from 'date-fns';
import { HiCheck, HiExclamation } from 'react-icons/hi';

const CohortStudentsTable = ({
  students,
}: {
  students: {
    id: number;
    name: string;
    mentorName: string | null;
    firstMeetingWithMentor: string | null;
    mostRecentMeetingWithMentor: string | null;
    hoursMentored: number;
    anyOpenFlags: boolean;
    currentPriority: string | null;
  }[];
}) => {
  return (
    <Table>
      <Thead>
        <Tr>
          <Th>Name</Th>
          <Th>Onboarded</Th>
          <Th>Latest Meeting With Mentor</Th>
          <Th>Current Priority</Th>
        </Tr>
      </Thead>
      <Tbody>
        {students.map((student) => (
          <Tr key={student.id}>
            <Td>
              <HStack>
                {student.anyOpenFlags && (
                  <span>
                    <HiExclamation />
                  </span>
                )}
                <Link as={RouterLink} to={`/students/${student.id}`}>
                  {student.name}
                </Link>
              </HStack>
            </Td>
            <Td>{student.mentorName && <HiCheck />}</Td>
            <Td>
              {student.mostRecentMeetingWithMentor &&
                formatRelative(parseISO(student.mostRecentMeetingWithMentor), new Date())}
            </Td>
            <Td>{student.currentPriority}</Td>
          </Tr>
        ))}
      </Tbody>
    </Table>
  );
};

export default function StudentList() {
  const cohortsAndStudentsQuery = useQuery('cohorts_and_students', queries.cohortsAndStudents, {
    staleTime: 1000 * 60 * 5,
  });

  if (cohortsAndStudentsQuery.isLoading) {
    return <Skeleton height="30px" />;
  }

  return (
    <Container maxW={'container.xl'}>
      {cohortsAndStudentsQuery.data.map((cohort) => (
        <Box key={cohort.id}>
          <Heading as="h2" size="md" my={3}>
            {cohort.name}
          </Heading>
          <CohortStudentsTable students={cohort.students} />
        </Box>
      ))}
    </Container>
  );
}
