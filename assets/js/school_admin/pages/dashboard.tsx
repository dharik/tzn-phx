import { useQuery, useQueryClient } from 'react-query';
import { Center, Container, Heading } from '@chakra-ui/react';
import React, { useState } from 'react';

import * as queries from '../queries';
import CohortOverview from '../components/cohort_overview';

const fiveMinCache = {
  staleTime: 1000 * 60 * 5,
};

export default function Dashboard() {
  const [selectedCohortId, setSelectedCohortId] = useState<string>('');

  const myNameQuery = useQuery('myName', queries.myName, {
    ...fiveMinCache,
    placeholderData: '',
  });

  const cohortsQuery = useQuery('cohorts', queries.getCohorts, {
    placeholderData: [],
    onSuccess: (data) => {
      if (data[0]) {
        setSelectedCohortId(data[0].id);
      }
    },
  });

  return (
    <Center>
      <Container maxW="container.xl">
        <Heading as="h1" size="sm" my={3}>
          Welcome, {myNameQuery.data.myName}
        </Heading>
        <Center>{selectedCohortId !== '' && <CohortOverview cohortId={selectedCohortId} />}</Center>
      </Container>
    </Center>
  );
}
