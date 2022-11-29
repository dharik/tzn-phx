import { useDebouncedCallback } from 'use-debounce';
import React, { useState } from 'react';

interface Props {
  question_id: number;
  mentee_id: number;
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value || '');
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
    <div className="form-control">
      <textarea
        onChange={handleChange}
        value={value}
        className="textarea textarea-bordered w-full"
        placeholder="Type here..."
      ></textarea>
      <label className="label pl-0">
        <span className="label-text-alt">Parents can see this</span>
        {saveState === 'success' && <span className="label-text-alt text-success ">✓ Saved</span>}
        {saveState === 'saving' && <span className="label-text-alt ">Saving...</span>}
        {saveState === 'fail' && <span className="label-text-alt text-error ">Unable to save</span>}
      </label>
    </div>
  );
};
