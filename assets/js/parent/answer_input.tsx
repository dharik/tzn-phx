import { h, render, Component, Fragment } from 'preact';
import { useState } from 'preact/hooks';
import { Textarea, Badge, ChakraProvider } from '@chakra-ui/react';
import { useDebouncedCallback } from 'use-debounce';

interface Props {
  question_id: number;
  access_key: string;
  required: boolean;
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value);
  const isEmpty = value == null || value == '' || value.length < 2;

  const [saveState, setSaveState] = useState<'' | 'saving' | 'success' | 'fail'>('');

  const save = useDebouncedCallback(() => {
    setSaveState('saving');

    fetch('/college_list/' + props.access_key, {
      method: 'POST',
      body: JSON.stringify({ question_id: props.question_id, response: value }),
      headers: {
        'Content-Type': 'application/json',
      },
    })
      .then((r) => r.json())
      .then(({ value }) => {
        setValue(value);
        setSaveState('success');
      })
      .catch((error) => {
        setSaveState('fail');
      });
  }, 1200);

  const handleChange = (e: unknown) => {
    let inputValue = e.target.value;
    setValue(inputValue);
    setSaveState('');
    save();
  };

  return (
    <ChakraProvider>
      <Fragment>
        <Textarea value={value} onChange={handleChange} isRequired={props.required}></Textarea>
        {props.required && isEmpty && <Badge colorScheme="red">Required</Badge>}
        {saveState === 'success' && !isEmpty && <Badge colorScheme="green">Saved</Badge>}
        {saveState === 'saving' && !isEmpty && <Badge>Saving...</Badge>}
        {saveState === 'fail' && !isEmpty && <Badge colorScheme="red">Unable to save</Badge>}
      </Fragment>
    </ChakraProvider>
  );
};
