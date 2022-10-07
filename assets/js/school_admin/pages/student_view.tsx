import { gql, useQuery } from '@apollo/client';
import { Fragment, h } from 'preact';
import { Skeleton } from '@chakra-ui/react';
import DefaultLayout from '../default_layout';
import { useParams } from 'react-router';


export default function StudentView() {
  const {studentId} = useParams();

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
     {studentId}
    </DefaultLayout>
  );
}
