import {
  Flex,
  Box,
  Image,
  Button,
  Spacer,
  Grid,
  GridItem,
  Link,
  HStack,
  MenuButton,
  Menu,
  MenuList,
  MenuItem,
} from '@chakra-ui/react';
import { Outlet, useNavigate } from 'react-router';
import React from 'react';
import { NavLink, Link as RouterLink } from 'react-router-dom';
import { useQuery } from 'react-query';
import { getCohorts } from './queries';
function Nav() {
  const navigate = useNavigate();

  const cohortsQuery = useQuery('cohorts', getCohorts, {
    placeholderData: [],
  });

  return (
    <Flex bgColor={'#4169B2'}>
      <Box p="4">
        <Link as={RouterLink} to="/">
          <Image src="/images/cz_logo_white.svg" htmlWidth={180} />
        </Link>
      </Box>
      <Box px="16" py={4}>
        <HStack gap={5}>
          <NavLink to="/" end>
            {({ isActive }) =>
              isActive ? (
                <Button variant="link" onClick={() => (window.location.pathname = '/')} px={3} py={2} textColor="white">
                  Home
                </Button>
              ) : (
                <Button variant="link" onClick={() => navigate('/')} px={3} py={2} textColor="white">
                  Home
                </Button>
              )
            }
          </NavLink>

          <Menu>
            <MenuButton as={Button} variant="link" textColor={'white'}>
              Students
            </MenuButton>
            <MenuList>
              {cohortsQuery.data.map((cohort) => (
                <MenuItem key={cohort.id}>
                  <RouterLink to={`/cohort/${cohort.id}`}>{cohort.name}</RouterLink>
                </MenuItem>
              ))}
            </MenuList>
          </Menu>

          {cohortsQuery.data && cohortsQuery.data[0] && (
            <Button variant="link" px={3} py={2} textColor="white" onClick={() => navigate(`/cohort/${cohortsQuery.data[0].id}/timeline`)}>
              Timeline
            </Button>
          )}
        </HStack>
      </Box>
      <Spacer />
      <Box p="4">
        {/* <Button>
          <Link to="/">Log Out</Link>
        </Button> */}
      </Box>
    </Flex>
  );
}

export default function DefaultLayout({ children }) {
  return (
    <>
      <Nav />
      <Outlet />
    </>
  );
}
