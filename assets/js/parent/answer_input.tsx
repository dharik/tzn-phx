import { h, render, Component, Fragment } from 'preact';
import { useState } from 'preact/hooks';
import { useDebouncedCallback } from 'use-debounce';

interface Props {
  question_id: number;
  id: string;
  required: boolean;
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value);
  const isEmpty = value == null || value == '' || value.length < 2;

  const [saveState, setSaveState] = useState<'' | 'saving' | 'success' | 'fail'>('');

  const save = useDebouncedCallback(() => {
    setSaveState('saving');

    fetch('/college_list/' + props.id, {
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
    <Fragment>
      <textarea onChange={handleChange} required={props.required}>
        {value}
      </textarea>
      {props.required && isEmpty && <span class="form-message error">Required</span>}
      {saveState === 'success' && !isEmpty && <span class="form-message success">✓ Saved</span>}
      {saveState === 'saving' && !isEmpty && <span class="form-message">Saving...</span>}
      {saveState === 'fail' && !isEmpty && <span class="form-message error">Unable to save</span>}
    </Fragment>
  );
};
