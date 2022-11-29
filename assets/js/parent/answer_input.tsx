import { useDebouncedCallback } from 'use-debounce';
import React, { useState } from 'react';

interface Props {
  question_id: number;
  id: string;
  required: boolean;
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value || "");
  const isEmpty = value == null || value == '' || value.length < 2;

  const [saveState, setSaveState] = useState<'' | 'saving' | 'success' | 'fail'>('');

  const save = useDebouncedCallback(() => {
    setSaveState('saving');

    fetch('/research_list/' + props.id, {
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
    <>
      <textarea onChange={handleChange} required={props.required} value={value} className="textarea textarea-bordered w-full"></textarea>
      {props.required && isEmpty && <div className="text-sm text-error">Required</div>}
      {saveState === 'success' && !isEmpty && <div className="text-sm text-success">✓ Saved</div>}
      {saveState === 'saving' && !isEmpty && <div className="text-sm text-grey">Saving...</div>}
      {saveState === '' && <div className="text-sm text-grey">&nbsp;</div>}
      {saveState === 'fail' && !isEmpty && <div className="text-sm text-error">Unable to save</div>}
    </>
  );
};
