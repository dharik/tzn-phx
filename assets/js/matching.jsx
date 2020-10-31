import { h, render, Component, Fragment } from "preact";
import { useState } from "preact/hooks";
import "preact/devtools";

export default () => {
  const data = JSON.parse(document.getElementById("matching-data").textContent);
  // utils
  const humanized_slugs = (string) => string + "_";

  // form stuff
  const options = data.options;
  const [careers, setCareers] = useState(new Set());
  const [schoolTiers, setSchoolTiers] = useState(new Set());
  const [genderPreference, setGenderPreference] = useState(null);
  const [learningDisability, setLearningDisability] = useState(false);
  const [socialFactor, setSocialFactor] = useState(null);
  const [hobbies, setHobbies] = useState(new Set());

  // Run the algorithm
  const mentors = data.mentors;

  const scoredMentors = mentors.map((mentor) => {
    let careerScore = 0;
    let tierScore = 0;
    let genderScore = 0;
    let disabilityScore = 0;
    let socialFactorScore = 0;
    let hobbiesScore = 0;

    mentor.career_interests.map((interest) => {
      if (careers.has(interest)) {
        careerScore += 40;
        console.log("mentor has matching career interest", interest);
      }
    });

    mentor.school_tiers.map((tier) => {
      if (schoolTiers.has(tier)) {
        tierScore += 40;
        console.log("mentor has matching school tier", tier);
      }
    });

    if (mentor.gender == genderPreference) {
      console.log("mentor has matching gender", genderPreference);
      genderScore += 10;
    }

    if (mentor.disability_experience && learningDisability) {
      console.log("mentor has experiece with learning disability");
      disabilityScore += 10;
    }

    if (mentor.social_factor == new String(socialFactor)) {
      console.log("mentor has matching social factor");
      socialFactorScore += 10;
    }

    mentor.hobbies.forEach((hobby) => {
      if (hobbies.has(hobby)) {
        hobbiesScore += 10;
        console.log("mentor has matching hobby", hobby);
      }
    });

    return {
      ...mentor,
      careerScore,
      tierScore,
      genderScore,
      disabilityScore,
      socialFactorScore,
      hobbiesScore,
      totalScore:
        careerScore +
        tierScore +
        genderScore +
        disabilityScore +
        socialFactorScore +
        hobbiesScore,
    };
  });

  console.table(scoredMentors);

  return (
    <div className="flex">
      <div className="flex-1">
        <strong>Prospective Major</strong>
        <br />
        {options.careers.map(([name, value]) => (
          <label key={value}>
            <input
              type="checkbox"
              checked={careers.has(value)}
              onClick={() => setCareers(toggleSetItem(careers, value))}
            />{" "}
            {name}
          </label>
        ))}
        <div className="space-m"></div>
        <strong>What tier of schools does the student want to apply to?</strong>
        <br />

        {options.school_tiers.map(([name, value]) => (
          <label key={value}>
            <input
              type="checkbox"
              checked={schoolTiers.has(value)}
              onClick={() => setSchoolTiers(toggleSetItem(schoolTiers, value))}
            />{" "}
            {name}
          </label>
        ))}

        <div className="space-m"></div>
        <strong>Gender preference</strong>
        <br />
        <label>
          <input
            type="radio"
            checked={genderPreference === "male"}
            onClick={() => setGenderPreference("male")}
          />{" "}
          Male
        </label>
        <label>
          <input
            type="radio"
            checked={genderPreference === "female"}
            onClick={() => setGenderPreference("female")}
          />{" "}
          Female
        </label>
        <label>
          <input
            type="radio"
            checked={genderPreference === "non_binary"}
            onClick={() => setGenderPreference("non_binary")}
          />{" "}
          Non-binary
        </label>
        <label>
          <input
            type="radio"
            checked={genderPreference === null}
            onClick={() => setGenderPreference(null)}
          />{" "}
          No preference
        </label>

        <div className="space-m"></div>

        <strong>Does student have a learning disability?</strong>
        <br />
        <label>
          <input
            type="radio"
            checked={learningDisability}
            onClick={() => setLearningDisability(true)}
          />{" "}
          Yes
        </label>
        <label>
          <input
            type="radio"
            checked={!learningDisability}
            onClick={() => setLearningDisability(false)}
          />{" "}
          No
        </label>

        <div className="space-m"></div>
        <strong>Social Factor Preference</strong>
        <br />
        <label>
          <input
            type="radio"
            checked={socialFactor === 1}
            onClick={() => setSocialFactor(1)}
          />{" "}
          1
        </label>
        <label>
          <input
            type="radio"
            checked={socialFactor === 2}
            onClick={() => setSocialFactor(2)}
          />{" "}
          2
        </label>
        <label>
          <input
            type="radio"
            checked={socialFactor === 3}
            onClick={() => setSocialFactor(3)}
          />{" "}
          3
        </label>
        <label>
          <input
            type="radio"
            checked={socialFactor === 4}
            onClick={() => setSocialFactor(4)}
          />{" "}
          4
        </label>
        <label>
          <input
            type="radio"
            checked={socialFactor === 5}
            onClick={() => setSocialFactor(5)}
          />{" "}
          5
        </label>
        <label>
          <input
            type="radio"
            checked={socialFactor === null}
            onClick={() => setSocialFactor(null)}
          />{" "}
          None
        </label>

        <div className="space-m"></div>
        <strong>Hobbies</strong>
        <br />
        {options.hobbies.map(([name, value]) => (
          <label key={value}>
            <input
              type="checkbox"
              checked={hobbies.has(value)}
              onClick={() => setHobbies(toggleSetItem(hobbies, value))}
            />{" "}
            {name}
          </label>
        ))}
      </div>
      <div className="flex-1">
        Suggested mentors
        {scoredMentors.map((mentor, idx) => (
          <div
            key={idx}
            className="box-shadow-s border-radius margin-vertical-s"
          >
            <h1 className="all-caps">{mentor.name}</h1>
            Score: {mentor.totalScore}
            {mentor.careerScore > 0 && (
              <div>Career interests: {mentor.career_interests.join(", ")}</div>
            )}
            {mentor.hobbiesScore > 0 && (
              <div>Hobbies: {mentor.hobbies.join(", ")}</div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

function toggleSetItem(set, value) {
  if (set.has(value)) {
    set.delete(value);
    return new Set(set);
  } else {
    set.add(value);
    return new Set(set);
  }
}
