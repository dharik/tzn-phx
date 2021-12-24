import { h, render, Component, Fragment } from 'preact';
import { useState } from 'preact/hooks';
import { useDebouncedCallback } from 'use-debounce';

interface Props {
  question_id: number;
  mentee_id: number;
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value);
  const [saveState, setSaveState] = useState<'' | 'saving' | 'success' | 'fail'>('');

  const save = useDebouncedCallback(() => {
    setSaveState('saving');

    fetch('/mentor/api/answers', {
      method: 'POST',
      body: JSON.stringify({ question_id: props.question_id, mentee_id: props.mentee_id, internal: value }),
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
      <textarea onChange={handleChange}>{value}</textarea>
      {saveState === 'success' && <span class="form-message success">✓ Saved</span>}
      {saveState === 'saving' && <span class="form-message">Saving...</span>}
      {saveState === 'fail' && <span class="form-message error">Unable to save</span>}
    </Fragment>
  );
};