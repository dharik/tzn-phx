import { h, render, Component, Fragment } from 'preact';
import { useState } from 'preact/hooks';
import 'preact/devtools';

export default ({ mentors, options }) => {
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
        totalScore: careerScore + tierScore + genderScore + disabilityScore + socialFactorScore + hobbiesScore,
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
      <div className="background-light-100 padding-s">
        <strong>Prospective Major</strong>
      </div>
      <div className="margin-vertical-s padding-horizontal-m">
        {options.careers.map(([name, value]) => (
          <label key={value} className="control checkbox">
            <input
              type="checkbox"
              checked={careers.has(value)}
              onClick={() => setCareers(toggleSetItem(careers, value))}
            />
            <span class="control-indicator"></span>
            <span class="control-label">{name}</span>
          </label>
        ))}
      </div>
      <div className="space-m"></div>

      <div className="background-light-100 padding-s">
        <strong>Schools Tier</strong>
      </div>
      <div className="margin-vertical-s padding-horizontal-m">
        {options.school_tiers.map(([name, value]) => (
          <label key={value} className="control checkbox">
            <input
              type="checkbox"
              checked={schoolTiers.has(value)}
              onClick={() => setSchoolTiers(toggleSetItem(schoolTiers, value))}
            />
            <span class="control-indicator"></span>
            <span class="control-label">{name}</span>
          </label>
        ))}
      </div>
      <div className="space-m"></div>

      <div className="background-light-100 padding-s">
        <strong>Gender preference</strong>
      </div>
      <div className="margin-vertical-s padding-horizontal-m">
        <label class="control radio">
          <input type="radio" checked={genderPreference === 'male'} onClick={() => setGenderPreference('male')} />
          <span class="control-indicator"></span>
          <span class="control-label">Male</span>
        </label>
        <label class="control radio">
          <input type="radio" checked={genderPreference === 'female'} onClick={() => setGenderPreference('female')} />{' '}
          <span class="control-indicator"></span>
          <span class="control-label">Female</span>
        </label>
        <label class="control radio">
          <input
            type="radio"
            checked={genderPreference === 'non_binary'}
            onClick={() => setGenderPreference('non_binary')}
          />{' '}
          <span class="control-indicator"></span>
          <span class="control-label">Non-binary</span>
        </label>
        <label class="control radio">
          <input type="radio" checked={genderPreference === null} onClick={() => setGenderPreference(null)} />
          <span class="control-indicator"></span>
          <span class="control-label">No preference</span>
        </label>
      </div>
      <div className="space-m"></div>

      <div className="background-light-100 padding-s">
        <strong>Learning Disability</strong>
      </div>
      <div className="margin-vertical-s padding-horizontal-m">
        <label class="control radio">
          <input type="radio" checked={learningDisability} onClick={() => setLearningDisability(true)} />
          <span class="control-indicator"></span>
          <span class="control-label">Yes</span>
        </label>
        <label class="control radio">
          <input type="radio" checked={!learningDisability} onClick={() => setLearningDisability(false)} />
          <span class="control-indicator"></span>
          <span class="control-label">No</span>
        </label>
      </div>
      <div className="space-m"></div>

      <div className="background-light-100 padding-s">
        <strong>Social Factor</strong>
      </div>
      <div className="margin-vertical-s padding-horizontal-m">
        <label class="control radio">
          <input type="radio" checked={socialFactor === 1} onClick={() => setSocialFactor(1)} />
          <span class="control-indicator"></span>
          <span class="control-label">1</span>
        </label>
        <label class="control radio">
          <input type="radio" checked={socialFactor === 2} onClick={() => setSocialFactor(2)} />
          <span class="control-indicator"></span>
          <span class="control-label">2</span>
        </label>
        <label class="control radio">
          <input type="radio" checked={socialFactor === 3} onClick={() => setSocialFactor(3)} />
          <span class="control-indicator"></span>
          <span class="control-label">3</span>
        </label>
        <label class="control radio">
          <input type="radio" checked={socialFactor === 4} onClick={() => setSocialFactor(4)} />
          <span class="control-indicator"></span>
          <span class="control-label">4</span>
        </label>
        <label class="control radio">
          <input type="radio" checked={socialFactor === 5} onClick={() => setSocialFactor(5)} />
          <span class="control-indicator"></span>
          <span class="control-label">5</span>
        </label>
      </div>
      <div className="space-m"></div>

      <div className="background-light-100 padding-s">
        <strong>Hobbies</strong>
      </div>
      <div className="margin-vertical-s padding-horizontal-m">
        {options.hobbies.map(([name, value]) => (
          <label key={value} className="control checkbox">
            <input
              type="checkbox"
              checked={hobbies.has(value)}
              onClick={() => setHobbies(toggleSetItem(hobbies, value))}
            />
            <span class="control-indicator"></span>
            <span class="control-label">{name}</span>
          </label>
        ))}
      </div>
    </>
  );
  return (
    <div className="flex">
      <div className="flex-1 matching-result">
        {scoredMentors.slice(0, 5).map((mentor, idx) => (
          <div
            className="border border-radius margin-vertical-s padding-s transition-fast flex flex-column align-items-center text-align-center"
            key={idx}
          >
            <div>
              {mentor.photo_url ? (
                <img
                  src={mentor.photo_url}
                  className=""
                  style="height: 200px; width: 200px; border-radius: 50%; object-fit: cover;"
                />
              ) : (
                <svg
                  style="border-radius: 50%;"
                  class="background-light-50 fill-dark-50"
                  viewBox="0 0 24 24"
                  width="200"
                  height="200"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                </svg>
              )}
            </div>

            <p className="lead-xs">{mentor.name}</p>

            {mentor.careerScore > 0 && (
              <p>
                <span class="text-transform-uppercase color-grey font-size-s">Similar career interests</span>
                <br />
                {mentor.career_interests
                  .filter((career) => careers.has(career))
                  .map((career) => slugToLabel[career] || career)
                  .join(', ')}
              </p>
            )}

            {mentor.hobbiesScore > 0 && (
              <p>
                <span class="text-transform-uppercase color-grey font-size-s">Similar hobbies:</span>
                <br />
                {mentor.hobbies
                  .filter((hobby) => hobbies.has(hobby))
                  .map((hobby) => slugToLabel[hobby] || hobby)
                  .join(', ')}
              </p>
            )}
            {mentor.disabilityScore > 0 && (
              <p class="text-transform-uppercase color-grey font-size-s">Experience with learning disabilities</p>
            )}
            {mentor.tierScore > 0 && (
              <p class="text-transform-uppercase color-grey font-size-s">
                Experience with {mentor.school_tiers.map((tier) => slugToLabel[tier]).join(', ')} schools
              </p>
            )}

            <a
              href={`/admin/mentors/${mentor.id}`}
              className="text-decoration-none color-primary-500 font-weight-medium"
            >
              View profile
            </a>
          </div>
        ))}
        {/* {scoredMentorTable} */}
      </div>
      <div className="flex-1 padding-horizontal-m" style="max-width: 40rem">
        {form}
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
