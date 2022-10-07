import { Flex, Box, Image, Button, Spacer, Grid, GridItem, Link } from '@chakra-ui/react';
import { useNavigate } from 'react-router';
import React from "react";
function Nav() {
  const navigate = useNavigate();

  return (
    <Flex bgColor={'gray.100'}>
      <Box p="4">
        <Image src="/images/logo-small.png" htmlWidth={180} />
      </Box>
      <Box px="16" py="4">
        <Button variant="ghost" onClick={() => navigate('/')}>
          Home
        </Button>
        <Button variant="ghost" onClick={() => navigate('/students')}>
          Students
        </Button>
        <Button variant="ghost" onClick={() => navigate('/timeline/general')}>
          Timeline
        </Button>
        {/* <Button variant="ghost" onClick={() => navigate('/stats')}>
          Stats
        </Button> */}
      </Box>
      <Spacer />
      <Box p="4">
        <Button><Link to="/">Log Out</Link></Button>
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
      {children}
    </>
  );
}
