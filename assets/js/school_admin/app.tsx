import { ReactQueryDevtools } from 'react-query/devtools';
import { Route, createBrowserRouter, RouterProvider } from 'react-router-dom';
import React from 'react';
import ReactDOM from 'react-dom';
import { ChakraProvider, extendTheme, Spinner } from '@chakra-ui/react';

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
    <ChakraProvider
      theme={extendTheme({
        styles: {
          global: {
            body: {
              backgroundImage: "url('/images/rhombii.png')",
              backgroundPosition: 'center top',
              backgroundSize: 'cover',
              backgroundRepeat: 'no-repeat',
              backgroundAttachment: 'fixed',
              minHeight: '100vh',
            },
          },
        },
      })}
    >
      <QueryClientProvider client={queryClient}>
        <RouterProvider
          router={router}
          fallbackElement={
            <DefaultLayout>
              <Spinner />
            </DefaultLayout>
          }
        />
      </QueryClientProvider>
    </ChakraProvider>
  );
}

ReactDOM.render(<App />, document.getElementById('app'));
