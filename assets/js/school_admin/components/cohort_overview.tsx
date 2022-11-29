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
  Stack,
  Text,
} from '@chakra-ui/react';
import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import { HiArrowRight, HiOutlinePresentationChartLine } from 'react-icons/hi';
import { getCohort, getCohortHighlights, getGeneralTimeline } from '../queries';
import { TimelineEvent } from './timeline_event';

const fiveMinCache = {
  staleTime: 1000 * 60 * 5,
};

export default function CohortOverview({ cohortId }) {
  const cohortQuery = useQuery(['cohort', cohortId], () => getCohort(cohortId), {
    enabled: !!cohortId,
  });

  if (cohortQuery.isLoading) {
    return null;
  }

  const cohort = cohortQuery.data;

  return (
    <Container maxW="container.xl">
      <Heading as="h2" size="md" my={3}>
        {cohort.name}
      </Heading>
      <Grid templateRows="1fr" templateColumns="repeat(1fr)" gap={4}>
        <GridItem py={5}>
          <Flex>
            <Square size="6rem">
              <HiOutlinePresentationChartLine size={80} />
            </Square>
            <Flex direction={'column'} justifyContent="center" pl={4}>
              {cohort.students.length} Students
              <Link as={RouterLink} to={`/cohort/${cohort.id}`}>
                <HStack>
                  <Text>View my students</Text>
                  <HiArrowRight />
                </HStack>
              </Link>
            </Flex>
          </Flex>
        </GridItem>
        <GridItem p={5}>
          <CohortHighlights cohortId={cohortId} />
        </GridItem>
        <GridItem colSpan={2}>
          <Heading as="h2" size="md">
            Upcoming Deadlines
          </Heading>
          <UpcomingDeadlines cohortId={cohortId} />
        </GridItem>
      </Grid>
    </Container>
  );
}

function CohortHighlights({ cohortId }) {
  const cohortHighlightsQuery = useQuery(['cohortHighlights', cohortId], () => getCohortHighlights(cohortId), {
    ...fiveMinCache,
    placeholderData: [],
  });

  if (cohortHighlightsQuery.isLoading) {
    return null;
  }

  const highlights = cohortHighlightsQuery.data;

  if(highlights.length == 0 && cohortHighlightsQuery.isFetched) {
    return <Flex alignItems={"center"} height="100%">
      We are in the process of onboarding your students! After that, we'll have some highlights for you here.
    </Flex>
  }

  return (
    <Flex>
      <List spacing={3}>
        {highlights.map((h) => (
          <ListItem key={h.studentId}>
            <LinkBox as={RouterLink} to={`/cohort/${cohortId}/student/${h.studentId}`}>
              {h.description}
            </LinkBox>
          </ListItem>
        ))}
      </List>
    </Flex>
  );
}

function UpcomingDeadlines({ cohortId }) {
  const { isLoading, data: deadlines } = useQuery(
    'generalTimelineShort',
    () => getGeneralTimeline(cohortId, 5, 'asc', 'n'),
    {
      staleTime: 1000 * 60 * 15,
    }
  );

  if (isLoading) {
    return (
      <Stack>
        <Skeleton height="120px" />
        <Skeleton height="120px" />
        <Skeleton height="120px" />
        <Skeleton height="120px" />
        <Skeleton height="120px" />
      </Stack>
    );
  }

  return (
    <div>
      {deadlines.map((d, idx) => {
        return <TimelineEvent {...d} key={idx} />;
      })}
    </div>
  );
}
