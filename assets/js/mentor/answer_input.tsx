import { h, render, Component, Fragment } from "preact";
import { useState } from "preact/hooks";
import { Textarea, Badge, ChakraProvider } from "@chakra-ui/react";
import { useDebouncedCallback } from "use-debounce";

interface Props {
  question_id: number;
  mentee_id: number;
  value: string;
}

export default (props: Props) => {
  let [value, setValue] = useState(props.value);
  const [saveState, setSaveState] = useState<"" | "saving" | "success" | "fail">("");

  const save = useDebouncedCallback(() => {
    setSaveState("saving");

    fetch("/mentor/api/answers", {
      method: "POST",
      body: JSON.stringify({ question_id: props.question_id, mentee_id: props.mentee_id, response: value }),
      headers: {
        "Content-Type": "application/json",
      },
    })
      .then((r) => r.json())
      .then(({ value }) => {
        setValue(value);
        setSaveState("success");
      })
      .catch((error) => {
        setSaveState("fail");
      });
  }, 1200);

  const handleChange = (e: unknown) => {
    let inputValue = e.target.value;
    setValue(inputValue);
    setSaveState("");
    save();
  };

  return (
    <ChakraProvider>
      <Fragment>
        <Textarea value={value} onChange={handleChange}></Textarea>
        {saveState === "success" && <Badge colorScheme="green">Saved</Badge>}
        {saveState === "saving" && <Badge>Saving...</Badge>}
        {saveState === "fail" && <Badge colorScheme="red">Unable to save</Badge>}
      </Fragment>
    </ChakraProvider>
  );
};
