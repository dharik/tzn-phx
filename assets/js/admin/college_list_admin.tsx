import { h, render, Component, Fragment } from "preact";
import { useEffect, useState, useImperativeHandle } from "preact/hooks";
import "preact/devtools";
import {
  Badge,
  Box,
  Button,
  Center,
  ChakraProvider,
  Drawer,
  DrawerBody,
  DrawerCloseButton,
  DrawerContent,
  DrawerFooter,
  DrawerHeader,
  DrawerOverlay,
  FormControl,
  FormHelperText,
  FormLabel,
  Input,
  Stack,
  Switch,
  VStack,
} from "@chakra-ui/react";
import { Formik, FieldArray, Field } from "formik";

interface CollegeListQuestion {
  question: string;
  help: string;
  placeholder: string;
  parent_answer_required: boolean;
  active: boolean;
  id?: number;
}

export default () => {
  const [questions, setQuestions] = useState<CollegeListQuestion[]>([]);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState<number | null>(null);

  useEffect(() => {
    fetch("/admin/college_list_questions.json")
      .then((r) => r.json())
      .then(setQuestions);
  }, []);

  if (questions.length == 0) {
    return null;
  }

  return (
    <ChakraProvider>
      <Formik
        initialValues={{ questions: questions }}
        onSubmit={(values, bag) => {
          console.log(values);
        }}
      >
        {({ values, dirty, handleSubmit }) => {
          return (
            <FieldArray name="questions">
              {({ unshift, move }) => (
                <div>
                  {dirty && (
                    <Box>
                      <Button colorScheme="blue" onClick={handleSubmit}>
                        Save All Changes
                      </Button>
                    </Box>
                  )}
                  <Button
                    onClick={() => {
                      unshift({
                        question: "",
                        placeholder: "",
                        text: "",
                        parent_answer_required: false,
                        active: true,
                      });
                      setCurrentQuestionIndex(0);
                    }}
                  >
                    Add Question
                  </Button>
                  {values.questions.map((question, index) => (
                    <div key={index} className="border-bottom border-top">
                      <strong>{question.question} </strong>
                      <a onClick={() => setCurrentQuestionIndex(index)}>✏️</a>
                      <br />
                      <em>{question.help}</em> (edit)
                      <br />
                      <em>{question.placeholder}</em> (edit)
                      <br />
                      <Stack direction="row">
                        {question.parent_answer_required && <Badge>Parent response required</Badge>}
                        {question.active !== true && <Badge colorScheme="red">Inactive</Badge>}
                      </Stack>
                      <br />
                      <Button isDisabled={index == 0} onClick={() => move(index, index - 1)} variant="link">
                        ⬆️
                      </Button>
                      <Button
                        isDisabled={index == questions.length - 1}
                        onClick={() => move(index, index + 1)}
                        variant="link"
                      >
                        ⬇️
                      </Button>
                      <Drawer
                        isOpen={currentQuestionIndex == index}
                        onClose={() => setCurrentQuestionIndex(null)}
                        placement="right"
                        size="lg"
                      >
                        <DrawerContent>
                          <DrawerCloseButton />
                          <DrawerHeader>Add/edit question</DrawerHeader>
                          <DrawerBody>
                            <VStack spacing="24px">
                              <FormControl isRequired>
                                <FormLabel>Question</FormLabel>
                                <Field name={`questions.${index}.question`} type="text">
                                  {({ field }) => <Input type="text" {...field}></Input>}
                                </Field>
                              </FormControl>

                              <FormControl>
                                <FormLabel>Helper Text</FormLabel>
                                <Field name={`questions.${index}.help`} type="text">
                                  {({ field }) => <Input type="text" {...field}></Input>}
                                </Field>
                                <FormHelperText>
                                  This is the helper text displayed underneath the main question.
                                </FormHelperText>
                              </FormControl>

                              <FormControl>
                                <FormLabel>Placeholder</FormLabel>
                                <Field name={`questions.${index}.placeholder`} type="text">
                                  {({ field }) => <Input type="text" {...field}></Input>}
                                </Field>
                                <FormHelperText>
                                  This is the value that an empty text box will display. Use it as a sample response to
                                  help users understand the expected format and detail of their response.
                                </FormHelperText>
                              </FormControl>

                              <FormControl isRequired>
                                <FormLabel>Active?</FormLabel>
                                <Field name={`questions.${index}.active`}>
                                  {({ field }) => <Switch {...field} isChecked={question.active == true} />}
                                </Field>
                                <FormHelperText>
                                  Inactive questions will not be shown anymore to anybody filling out a college list.
                                </FormHelperText>
                              </FormControl>
                              <FormControl isRequired>
                                <FormLabel>Parent response required?</FormLabel>
                                <Field name={`questions.${index}.parent_answer_required`}>
                                  {({ field }) => (
                                    <Switch {...field} isChecked={question.parent_answer_required == true} />
                                  )}
                                </Field>
                              </FormControl>
                            </VStack>
                          </DrawerBody>
                        </DrawerContent>
                      </Drawer>
                    </div>
                  ))}
                </div>
              )}
            </FieldArray>
          );
        }}
      </Formik>
    </ChakraProvider>
  );
};
