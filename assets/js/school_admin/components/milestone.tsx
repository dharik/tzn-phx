import { Box, Flex, Square, Text } from '@chakra-ui/react';
import React from 'react';
import { HiOutlineStar, HiStar } from 'react-icons/hi';
export function Milestone({
  title,
  description,
  completed,
  isPriority,
}: {
  title: string | null;
  description: string;
  completed: boolean;
  isPriority: boolean;
}) {
  return (
    <Flex p={3}>
      <Square size="6rem" bg="white" color="" boxShadow="md" borderRadius="sm">
        {isPriority ? <HiStar size="40%" color="#FFD25E" /> : <HiStar color="#FFD25E" size={'40%'} opacity=".2" />}
      </Square>

      <Box flex={1} ml={3}>
        {title && (
          <Box mb={2}>
            <Text as="b">{title}</Text>
          </Box>
        )}
        {completed ? (
          <Text as="s">
            <div dangerouslySetInnerHTML={{ __html: description }} />
          </Text>
        ) : (
          <div dangerouslySetInnerHTML={{ __html: description }} />
        )}
      </Box>
    </Flex>
  );
}
