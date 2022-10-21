import { Flex, Box, Image, Button, Spacer, Grid, GridItem, Link, HStack } from '@chakra-ui/react';
import { Outlet, useNavigate } from 'react-router';
import React from 'react';
import { NavLink, Link as RouterLink } from 'react-router-dom';
function Nav() {
  const navigate = useNavigate();

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
                <Button variant="link" onClick={() => window.location.pathname = '/'} px={3} py={2} textColor="white">
                  Home
                </Button>
              ) : (
                <Button variant="link" onClick={() => navigate('/')} px={3} py={2} textColor="white">
                  Home
                </Button>
              )
            }
          </NavLink>

          <Button variant="link" onClick={() => navigate('/students')} px={3} py={2} textColor="white">
            Students
          </Button>
          <Button variant="link" px={3} py={2} textColor="white" onClick={() => navigate('/timeline/general')}>
            Timeline
          </Button>
        </HStack>
      </Box>
      <Spacer />
      <Box p="4">
        {/* <Button>
          <Link to="/">Log Out</Link>
        </Button> */}
      </Box>
      {/* <Grid
        templateAreas={{
          base: `"header"
                  "nav"
                  "main"
                  "footer"`,
          md: `"header header"
          "nav main"
          "nav footer"`,
        }}
        gridTemplateRows={'50px 1fr 30px'}
        gridTemplateColumns={'150px 1fr'}
        h="200px"
        gap="1"
        color="blackAlpha.700"
        fontWeight="bold"
      >
        <GridItem pl="2" bg="orange.300" area={'header'}>
          Header
        </GridItem>
        <GridItem pl="2" bg="pink.300" area={'nav'}>
          Nav
        </GridItem>
        <GridItem pl="2" bg="green.300" area={'main'}>
          Main
        </GridItem>
        <GridItem pl="2" bg="blue.300" area={'footer'}>
          Footer
        </GridItem>
      </Grid> */}
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
