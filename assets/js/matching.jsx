import { h, render, Component, Fragment } from "preact";
import { useState } from "preact/hooks";
import "preact/devtools";

export default ({mentors, options}) => {
  const slugToLabel = {};

  if (options) {
    options.careers.forEach(([label, value]) => {
      slugToLabel[value] = label;
    });
    options.hobbies.forEach(([label, value]) => {
      slugToLabel[value] = label;
    });
    options.school_tiers.forEach(([label, value]) => {
      slugToLabel[value] = label;
    });
  }

  // form stuff
  const [careers, setCareers] = useState(new Set());
  const [schoolTiers, setSchoolTiers] = useState(new Set());
  const [genderPreference, setGenderPreference] = useState(null);
  const [learningDisability, setLearningDisability] = useState(false);
  const [socialFactor, setSocialFactor] = useState(null);
  const [hobbies, setHobbies] = useState(new Set());

  // Run the algorithm
  const scoredMentors = mentors
    .map((mentor) => {
      let careerScore = 0;
      let tierScore = 0;
      let genderScore = 0;
      let disabilityScore = 0;
      let socialFactorScore = 0;
      let hobbiesScore = 0;

      mentor.career_interests.map((interest) => {
        if (careers.has(interest)) {
          careerScore += 40;
        }
      });

      mentor.school_tiers.map((tier) => {
        if (schoolTiers.has(tier)) {
          tierScore += 40;
        }
      });

      if (genderPreference && mentor.gender == genderPreference) {
        genderScore += 10;
      }

      if (mentor.disability_experience && learningDisability) {
        disabilityScore += 10;
      }

      if (socialFactor && mentor.social_factor == new String(socialFactor)) {
        socialFactorScore += 10;
      }

      mentor.hobbies.forEach((hobby) => {
        if (hobbies.has(hobby)) {
          hobbiesScore += 10;
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
    })
    .sort((a, b) => b.totalScore - a.totalScore);

  const scoredMentorTable = (
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Career</th>
          <th>Tier</th>
          <th>Gender</th>
          <th>Disability</th>
          <th>Social Factor</th>
          <th>Hobbies</th>
          <th>Total</th>
        </tr>
      </thead>
      {scoredMentors.map((mentor, idx) => (
        <tr key={idx}>
          <td>{mentor.name}</td>
          <td>{mentor.careerScore}</td>
          <td>{mentor.tierScore}</td>
          <td>{mentor.genderScore}</td>
          <td>{mentor.disabilityScore}</td>
          <td>{mentor.socialFactorScore}</td>
          <td>{mentor.hobbiesScore}</td>
          <td>{mentor.totalScore}</td>
        </tr>
      ))}
    </table>
  );
  const form = (
    <>
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
    </>
  );
  return (
    <div className="flex">
      <div className="flex-1">{form}</div>
      <div className="flex-1">
        {scoredMentors.slice(0, 5).map((mentor, idx) => (
          <div
            className="box-shadow-s border-radius margin-vertical-s padding-s transition-fast"
            key={idx}
          >
            <a href={`/admin/mentors/${mentor.id}`}>
              <h1 className="all-caps">{mentor.name}</h1>
            </a>
            <div className="flex margin-vertical-xs">
              {mentor.photo_url ? (
                <img
                  src={mentor.photo_url}
                  width="120"
                  height="120"
                  className="margin-right-s"
                />
              ) : (
                <svg
                  fill="lavender"
                  viewBox="0 0 24 24"
                  width="120"
                  height="120"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                </svg>
              )}

              <div className="flex-1">
                {mentor.careerScore > 0 && (
                  <p>
                    Similar career interests:{" "}
                    {mentor.career_interests
                      .filter((career) => careers.has(career))
                      .map((career) => slugToLabel[career] || career)
                      .join(", ")}
                  </p>
                )}
                {mentor.hobbiesScore > 0 && (
                  <p>
                    Similar hobbies:{" "}
                    {mentor.hobbies
                      .filter((hobby) => hobbies.has(hobby))
                      .map((hobby) => slugToLabel[hobby] || hobby)
                      .join(", ")}
                  </p>
                )}
                {mentor.disabilityScore > 0 && (
                  <p>Experience with learning disabilities</p>
                )}
                {mentor.tierScore > 0 && (
                  <p>
                    Experience with{" "}
                    {mentor.school_tiers
                      .map((tier) => slugToLabel[tier])
                      .join(", ")}{" "}
                    schools
                  </p>
                )}
              </div>
            </div>
          </div>
        ))}
        {/* {scoredMentorTable} */}
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
