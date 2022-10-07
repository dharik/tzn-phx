if (process.env.NODE_ENV === 'development') {
  // Must use require here as import statements are only allowed
  // to exist at top-level.
  require('preact/debug');
}

import { Route, createBrowserRouter, RouterProvider } from 'react-router-dom';

import { h, render } from 'preact';
import { ChakraProvider } from '@chakra-ui/react';

import { ApolloClient, InMemoryCache, ApolloProvider, gql, useQuery } from '@apollo/client';
import Dashboard from './pages/dashboard';
import StudentList from './pages/student_list';
import Timeline from './pages/timeline';
import StudentView from './pages/student_view';

const client = new ApolloClient({
  uri: '/gql',

  cache: new InMemoryCache(),
});

const router = createBrowserRouter(
  [
    {
      path: '/',
      element: <Dashboard />,
    },
    {
      path: '/students',
      element: <StudentList />,
    },
    {
      path: '/students/:studentId',
      element: <StudentView />,
    },
    {
      path: '/timeline/general',
      element: <Timeline />,
    },
    {
      path: '/timeline/:studentId',
      element: <Timeline />,
    },
    {
      path: '/stats',
      element: <StudentList />,
    },
  ],
  {
    basename: '/school_admin',
  }
);

function App() {
  return (
    <ApolloProvider client={client}>
      <ChakraProvider>
        <RouterProvider router={router} />
      </ChakraProvider>
    </ApolloProvider>
  );
}

render(<App />, document.getElementById('app'));
