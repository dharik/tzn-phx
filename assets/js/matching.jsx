import { h, render, Component, Fragment } from "preact";
import { useState } from "preact/hooks";

const PROSPECTIVE_MAJORS = [
  { value: "business", label: "Business, finance, entrepreneurship" },
  { value: "computer_science", label: "Computer science, coding" },
  { value: "engineering", label: "Engineering" },
  { value: "journalism", label: "Journalism, writing, marketing" },
  { value: "chemistry", label: "Chemistry, biology" },
  { value: "physics", label: "physics" },
  { value: "nursing", label: "Nursing" },
  { value: "premed", label: "Pre-med (close to chem and bio)" },
  { value: "sports_nutrition", label: "Sports nutrition" },
  { value: "economics", label: "Economics" },
  { value: "liberal_arts", label: "Undeclared/liberal arts, humanities" },
  { value: "math", label: "Math" },
  { value: "political_science", label: "Political science" },
];
const HOBBIES = [{ value: "", label: "" }];
export default () => {
  return (
    <div className="flex">
      <div className="flex-1">
        <strong>Prospective Major</strong>
        <br />
        {PROSPECTIVE_MAJORS.map((major) => (
          <label key={major.value}>
            <input type="checkbox" /> {major.label}
          </label>
        ))}
        <div className="space-m"></div>
        <strong>What tier of schools does the student want to apply to?</strong>
        <br />
        <label>
          <input type="checkbox" /> Ivy League
        </label>
        <label>
          <input type="checkbox" /> Top 20-50
        </label>
        <label>
          <input type="checkbox" /> Top 50-100
        </label>
        <label>
          <input type="checkbox" /> Top 100+
        </label>
        <div className="space-m"></div>
        <strong>Gender preference</strong>
        <br />
        <label>
          <input type="radio" /> Male
        </label>
        <label>
          <input type="radio" /> Female
        </label>
        <label>
          <input type="radio" /> Non-binary
        </label>
        <div className="space-m"></div>
        <strong>Does student have a learning disability?</strong>
        <br />
        <label>
          <input type="radio" /> Yes
        </label>
        <label>
          <input type="radio" /> No
        </label>

        <div className="space-m"></div>
        <strong>Social Factor</strong>
        <br />
        <label>
          <input type="range" min={1} max={5} step={1} size={3} />
        </label>

        <div className="space-m"></div>
        <strong>Hobbies</strong>
        <br />
        {HOBBIES.map((hobby) => (
          <label key={hobby.value}>
            <input type="checkbox" /> {hobby.label}
          </label>
        ))}
      </div>
      <div className="flex-1">Suggested mentors</div>
    </div>
  );
};
