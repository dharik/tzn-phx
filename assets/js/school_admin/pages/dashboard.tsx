import { gql, useQuery } from '@apollo/client';
import { Box, Center, Container, Flex, Grid, GridItem, Heading, Link, Skeleton, Square } from '@chakra-ui/react';
import { h } from 'preact';
import { Link as RouterLink } from 'react-router-dom';

import UpcomingDeadlines from '../components/upcoming_deadlines';
import DefaultLayout from '../default_layout';

export default function Dashboard() {
  const g = gql`
    query {
      myName
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
      generalTimeline(limit: 5) {
        year
        month
        day
        title
        description
        monthShortname
      }
    }
  `;

  const { loading, error, data } = useQuery(g);

  if (data) {
    return (
      <DefaultLayout>
        <Center>
          <Container maxW="container.xl">
            <Heading as="h1" size="sm" my={3}>
              Welcome, {data.myName}
            </Heading>
            <Center>
              <Grid templateRows="1fr" templateColumns="repeat(1fr)" gap={4}>
                {/* <GridItem bg="papayawhip">
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
                      <Flex direction={"column"}>
                        23.5 hours of mentoring across 16 of your students
                        <Link as={RouterLink} to="/students">
                          View my students
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
                        </Link>
                      </Flex>
                    </Flex>
                  </Center>
                </GridItem>
                <GridItem bg="green">
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
                      d="M12 10.5v3.75m-9.303 3.376C1.83 19.126 2.914 21 4.645 21h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 4.88c-.866-1.501-3.032-1.501-3.898 0L2.697 17.626zM12 17.25h.007v.008H12v-.008z"
                    />
                  </svg>{' '}
                  <a href="#">Sponge Robert</a> has missed 3 meetings in a row with their mentor.
                </GridItem> */}
                <GridItem colSpan={2}>
                  <Heading as="h2" size="md">
                    Upcoming Deadlines
                  </Heading>
                  <UpcomingDeadlines deadlines={data.generalTimeline} />
                </GridItem>
              </Grid>
            </Center>
          </Container>
        </Center>
      </DefaultLayout>
    );
  } else {
    return (
      <DefaultLayout>
        <Skeleton />
      </DefaultLayout>
    );
  }
}
