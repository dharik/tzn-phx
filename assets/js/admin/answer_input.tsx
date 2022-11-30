import { useDebouncedCallback } from 'use-debounce';
import React, { Fragment, useState } from 'react';
interface Props {
  question_id: number;
  mentee_id: number;
  answer_from: 'from_pod' | 'from_parent' | 'internal';
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value || "");
  const [saveState, setSaveState] = useState<'' | 'saving' | 'success' | 'fail'>('');

  const save = useDebouncedCallback(() => {
    setSaveState('saving');

    fetch('/admin/api/answers', {
      method: 'POST',
      body: JSON.stringify({ question_id: props.question_id, mentee_id: props.mentee_id, [props.answer_from]: value }),
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
      <textarea onChange={handleChange} value={value} className="textarea textarea-bordered w-full"></textarea>
      <br />
      &nbsp;
      {saveState === 'success' && <span className="text-sm text-success">✓ Saved</span>}
      {saveState === 'saving' && <span className="text-sm text-grey">Saving...</span>}
      {saveState === 'fail' && <span className="text-sm text-error">Unable to save</span>}
    </Fragment>
  );
};
