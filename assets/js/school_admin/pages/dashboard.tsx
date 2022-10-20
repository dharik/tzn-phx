import { useQuery } from 'react-query';
import {
  Center,
  Container,
  Flex,
  Grid,
  GridItem,
  Heading,
  HStack,
  Link,
  LinkBox,
  List,
  ListItem,
  Skeleton,
  Square,
  Text,
} from '@chakra-ui/react';
import React from 'react';
import { Link as RouterLink } from 'react-router-dom';

import UpcomingDeadlines from '../components/upcoming_deadlines';
import * as queries from '../queries';

const fiveMinCache = {
  staleTime: 1000 * 60 * 5,
};

export default function Dashboard() {
  const myNameQuery = useQuery('myName', queries.myName, fiveMinCache);
  const numStudentsQuery = useQuery('numStudents', queries.numStudents, fiveMinCache);
  const hoursMentoredQuery = useQuery('hoursMentored', queries.hoursMentored, fiveMinCache);
  const studentHighlightsQuery = useQuery('studentHighlights', queries.getStudentHighlights, fiveMinCache);

  return (
    <Center>
      <Container maxW="container.xl">
        <Heading as="h1" size="sm" my={3}>
          Welcome, {myNameQuery.isSuccess ? myNameQuery.data.myName : ''}
        </Heading>
        <Center>
          <Grid templateRows="1fr" templateColumns="repeat(1fr)" gap={4}>
            <GridItem p={5}>
              <Center>
                <Flex>
                  <Square size="6rem">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      class="w-full h-full"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0l-1 3m8.5-3l1 3m0 0l.5 1.5m-.5-1.5h-9.5m0 0l-.5 1.5m.75-9l3-3 2.148 2.148A12.061 12.061 0 0116.5 7.605"
                      />
                    </svg>
                  </Square>
                  <Flex direction={'column'} justifyContent="center">
                    {hoursMentoredQuery.isSuccess && numStudentsQuery.isSuccess ? (
                      <>
                        {hoursMentoredQuery.data.hoursMentored} hours of mentoring across{' '}
                        {numStudentsQuery.data.numStudents} of your students
                      </>
                    ) : (
                      <Skeleton />
                    )}
                    <Link as={RouterLink} to="/students">
                      <HStack>
                        <Text>View my students</Text>
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          class="w-6 h-6"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"
                          />
                        </svg>
                      </HStack>
                    </Link>
                  </Flex>
                </Flex>
              </Center>
            </GridItem>
            <GridItem p={5}>
              <Flex justifyContent={'center'} alignItems={'center'}>
                {studentHighlightsQuery.isSuccess ? (
                  <List spacing={3}>
                    {studentHighlightsQuery.data.map((h) => (
                      <ListItem key={h.studentId}>
                        <LinkBox as={RouterLink} to={`/students/${h.studentId}`}>
                          {h.description}
                        </LinkBox>
                      </ListItem>
                    ))}
                  </List>
                ) : null}
              </Flex>
            </GridItem>
            <GridItem colSpan={2}>
              <Heading as="h2" size="md">
                Upcoming Deadlines
              </Heading>
              <UpcomingDeadlines />
            </GridItem>
          </Grid>
        </Center>
      </Container>
    </Center>
  );
}
