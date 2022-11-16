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
  Alert,
  AlertIcon,
  VStack,
  Progress,
  Flex,
  Spacer,
  Avatar,
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

      <VStack gap="2" mb="4">
        {student.flags.map((flag) => (
          <Alert status="warning" key={flag.id}>
            <AlertIcon />({flag.status}) {flag.description}
          </Alert>
        ))}
      </VStack>

      <SimpleGrid columns={2} spacing={2} minChildWidth="20rem">
        <SimpleGrid columns={2} spacing={2} alignItems="center">
          <Box>
            <Text>Mentor:</Text>
          </Box>
          <HStack>
            <Avatar name={student.mentorName} />
            <Text>{student.mentorName}</Text>
          </HStack>
          <Box>
            <Text>Hours Mentored:</Text>
          </Box>
          <Box>
            <Text>{student.hoursMentored}</Text>
          </Box>
        </SimpleGrid>
        <Flex flexDir="column" justifyContent="flex-end">
          {student.totalMilestones > 0 && (
            <>
              {student.completedMilestones} / {student.totalMilestones} milestones completed
              <Progress min={0} max={student.totalMilestones} value={student.completedMilestones} />
            </>
          )}
        </Flex>
      </SimpleGrid>

      <Tabs isFitted mt="4">
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
