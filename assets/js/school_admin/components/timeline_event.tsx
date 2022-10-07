import { Box, Flex, Square, Text } from '@chakra-ui/react';
import { h } from 'preact';
export function TimelineEvent({
  year,
  month,
  day,
  title,
  description,
  monthShortname,
  completed,
}: {
  year: number;
  month: number;
  day: number;
  title: string | null;
  description: string;
  monthShortname: string;
  completed: boolean | undefined;
}) {
  return (
    <Flex p={3}>
      <Square size="6rem" bg="white" color="" boxShadow="md" borderRadius="sm" textAlign="center">
        <Box>
          <Text fontSize={'md'} casing={'capitalize'} fontWeight="light">
            {monthShortname}
          </Text>
          <Text fontSize="xl">{day}</Text>
        </Box>
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
