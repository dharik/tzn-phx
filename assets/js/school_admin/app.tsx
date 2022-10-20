import { ReactQueryDevtools } from 'react-query/devtools';
import { Route, createBrowserRouter, RouterProvider } from 'react-router-dom';
import React from 'react';
import ReactDOM from 'react-dom';
import { ChakraProvider, Spinner } from '@chakra-ui/react';

import Dashboard from './pages/dashboard';
import StudentList from './pages/student_list';
import Timeline from './pages/timeline';
import StudentView from './pages/student_view';
import DefaultLayout from './default_layout';
import { QueryClient, QueryClientProvider } from 'react-query';

const router = createBrowserRouter(
  [
    {
      path: '/',
      element: <DefaultLayout>{null}</DefaultLayout>,
      children: [
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
    },
  ],
  {
    basename: '/school_admin',
  }
);

function App() {
  const queryClient = new QueryClient();

  return (
    <QueryClientProvider client={queryClient}>
      <ChakraProvider>
        <RouterProvider
          router={router}
          fallbackElement={
            <DefaultLayout>
              <Spinner />
            </DefaultLayout>
          }
        />
      </ChakraProvider>
    </QueryClientProvider>
  );
}

ReactDOM.render(<App />, document.getElementById('app'));
