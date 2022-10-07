import { gql, useQuery } from '@apollo/client';
import { Fragment, h } from 'preact';
import { Skeleton, Table, Tbody, Td, Th, Thead, Tr, Link, Container, Heading, HStack, Text } from '@chakra-ui/react';
import DefaultLayout from '../default_layout';
import { useParams } from 'react-router';
import { Link as RouterLink } from 'react-router-dom';
import { HiOutlineArrowRight } from 'react-icons/hi';

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
              {/* <Link as={RouterLink} to={`/students/${student.id}`}> */}
              {student.name}
              {/* </Link> */}
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
  const { studentId } = useParams();
  const g = gql`
    query {
      cohorts {
        id
        name
        students {
          id
          name
          firstMeetingWithMentor
          mostRecentMeetingWithMentor
          hoursMentored
        }
        schoolAdmins {
          name
        }
      }
    }
  `;

  const { loading, error, data } = useQuery(g);

  if (loading) {
    return <Skeleton height="30px" />;
  }

  return (
    <DefaultLayout>
      <Container maxW={'container.xl'}>
        {data.cohorts.map((cohort) => (
          <Fragment>
            <Heading as="h2" size="md" my={3}>
              {cohort.name}
            </Heading>
            <CohortStudentsTable students={cohort.students} />
          </Fragment>
        ))}
      </Container>
    </DefaultLayout>
  );
}
