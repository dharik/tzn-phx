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
} from '@chakra-ui/react';
import { Link as RouterLink } from 'react-router-dom';
import React from 'react';
import { getDashboard } from '../queries';
import { useQuery } from 'react-query';
const CohortStudentsTable = ({
  students,
}: {
  students: {
    id: number;
    name: string;
    firstMeetingWithMentor: string;
    mostRecentMeetingWithMentor: string;
    hoursMentored: number;
  }[];
}) => {
  return (
    <Table>
      <Thead>
        <Tr>
          <Th>Name</Th>
          <Th>First Meeting With Mentor</Th>
          <Th>Latest Meeting With Mentor</Th>
          <Th>Hours Mentored</Th>
        </Tr>
      </Thead>
      <Tbody>
        {students.map((student) => (
          <Tr key={student.id}>
            <Td>
              <Link as={RouterLink} to={`/students/${student.id}`}>
                <HStack>
                  <Text>{student.name}</Text>
                </HStack>
              </Link>
            </Td>
            <Td>{student.firstMeetingWithMentor}</Td>
            <Td>{student.mostRecentMeetingWithMentor}</Td>
            <Td>{student.hoursMentored}</Td>
          </Tr>
        ))}
      </Tbody>
    </Table>
  );
};

export default function StudentList() {
  const { data, isLoading } = useQuery('dashboard', getDashboard, {
    staleTime: 1000 * 60 * 5,
  });

  if (isLoading) {
    return <Skeleton height="30px" />;
  }

  return (
    <Container maxW={'container.xl'}>
      {data.cohorts.map((cohort) => (
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
