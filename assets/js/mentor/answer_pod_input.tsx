import { useDebouncedCallback } from 'use-debounce';
import React, { useState } from 'react';

interface Props {
  question_id: number;
  mentee_id: number;
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value || "");
  const [saveState, setSaveState] = useState<'' | 'saving' | 'success' | 'fail'>('');

  const save = useDebouncedCallback(() => {
    setSaveState('saving');

    fetch('/mentor/api/answers', {
      method: 'POST',
      body: JSON.stringify({ question_id: props.question_id, mentee_id: props.mentee_id, from_pod: value }),
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
    <>
      <textarea onChange={handleChange} value={value}></textarea>
      {saveState === 'success' && <span className="form-message success">✓ Saved</span>}
      {saveState === 'saving' && <span className="form-message">Saving...</span>}
      {saveState === 'fail' && <span className="form-message error">Unable to save</span>}
    </>
  );
};
