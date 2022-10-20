import { Container, Heading, Link, Skeleton, Table, Tbody, Td, Th, Thead, Tr } from '@chakra-ui/react';
import { useParams } from 'react-router';
import React from 'react';
import { useQuery } from 'react-query';
import { getStudent } from '../queries';
import { Link as RouterLink } from 'react-router-dom';
import { parseISO, formatRelative } from 'date-fns';

export default function StudentView() {
  const { studentId } = useParams();

  const { isLoading: isLoadingTimeline, data: student } = useQuery(
    ['student', studentId],
    () => getStudent(studentId),
    {
      staleTime: 1000 * 60 * 5,
    }
  );

  if (isLoadingTimeline) {
    return <Skeleton height="30px" />;
  }

  return (
    <Container maxW={'container.xl'} pt={4}>
      <Heading as="h1" size="xl">
        {student.name}
      </Heading>
      <Heading as="h2" size="md">
        Mentor: {student.mentorName}
      </Heading>
      <Heading as="h2" size="sm">
        Hours Mentored: {student.hoursMentored}
      </Heading>

      <Link as={RouterLink} to={`/timeline/${student.id}`}>
        See {student.name}'s Timeline
      </Link>

      <Heading as="h3" size="sm">
        Recent Activity:
      </Heading>
      <Table>
        <Thead>
          <Tr>
            <Th>Date</Th>
            <Th>Category</Th>
            <Th>Notes</Th>
          </Tr>
        </Thead>
        <Tbody>
          {student.timesheetEntries.map((tse) => (
            <Tr>
              <Td>{formatRelative(parseISO(tse.startedAt), new Date())}</Td>
              <Td>{tse.category}</Td>
              <Td dangerouslySetInnerHTML={{ __html: tse.notes }}></Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    </Container>
  );
}
