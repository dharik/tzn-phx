import {
  Container,
  Heading,
  SimpleGrid,
  Skeleton,
  Table,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
  Box,
  Text,
  HStack,
  Tabs,
  TabList,
  Tab,
  TabPanel,
  TabPanels,
} from '@chakra-ui/react';
import { useParams } from 'react-router';
import React from 'react';
import { useQuery } from 'react-query';
import * as queries from '../queries';
import { parseISO, formatRelative } from 'date-fns';
import Timeline from './timeline';

const fiveMinCache = {
  staleTime: 1000 * 60 * 5,
};

export default function StudentView() {
  const { studentId } = useParams();

  const { isLoading, data: student } = useQuery(
    ['student', studentId],
    () => queries.getStudent(studentId),
    fiveMinCache
  );

  if (isLoading) {
    return <Skeleton height="30px" />;
  }

  return (
    <Container maxW={'container.xl'} pt={4}>
      <Heading as="h1" size="xl">
        {student.name}
      </Heading>
      <Box maxW="container.sm" my={3}>
        <SimpleGrid columns={2} spacing={2}>
          <Box>
            <Text>Mentor:</Text>
          </Box>
          <HStack>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-5 h-5">
              <path
                fillRule="evenodd"
                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-5.5-2.5a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0zM10 12a5.99 5.99 0 00-4.793 2.39A6.483 6.483 0 0010 16.5a6.483 6.483 0 004.793-2.11A5.99 5.99 0 0010 12z"
                clipRule="evenodd"
              />
            </svg>

            <Text>{student.mentorName}</Text>
          </HStack>
          <Box>
            <Text>Hours Mentored:</Text>
          </Box>
          <Box>
            <Text>{student.hoursMentored}</Text>
          </Box>
        </SimpleGrid>
      </Box>

      <Tabs isFitted>
        <TabList>
          <Tab>Mentorship Log</Tab>
          <Tab>Timeline</Tab>
        </TabList>

        <TabPanels>
          <TabPanel>
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
          </TabPanel>
          <TabPanel>
            <Timeline showSwitcher={false} />
          </TabPanel>
        </TabPanels>
      </Tabs>
    </Container>
  );
}
