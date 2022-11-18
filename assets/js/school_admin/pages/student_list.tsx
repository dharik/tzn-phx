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
import { Link as RouterLink, useParams } from 'react-router-dom';
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
                  <Tooltip
                    label={`${student.mentorName} flagged this student. Open the student's profile to see more details.`}
                    aria-label="Warning"
                  >
                    <Text>⚠️</Text>
                  </Tooltip>
                )}
                <Link as={RouterLink} to={`student/${student.id}`}>
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
  const { cohortId } = useParams();
  const cohortQuery = useQuery(['cohort', cohortId], () => queries.getCohort(cohortId), {
    staleTime: 1000 * 60 * 5,
    enabled: !!cohortId,
  });

  if (cohortQuery.isLoading) {
    return <Skeleton height="30px" />;
  }

  const cohort = cohortQuery.data;

  return (
    <Container maxW={'container.xl'}>
      <Box>
        <Heading as="h2" size="md" my={3}>
          {cohort.name}
        </Heading>
        <CohortStudentsTable students={cohort.students} />
      </Box>
    </Container>
  );
}
