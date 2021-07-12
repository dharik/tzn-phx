import { h, render, Component, Fragment } from "preact";
import { useEffect, useState } from "preact/hooks";
import "preact/devtools";

export default () => {
  const [mentors, setMentors] = useState([]);
  const [shouldShowArchived, setShouldShowArchived] = useState(false);

  useEffect(() => {
    fetch("/admin/api/mentors")
      .then((r) => r.json())
      .then(setMentors)
  }, []);


  const filteredMentors = mentors.filter(mentor => {
    if (shouldShowArchived && mentor.archived) {
      return true;
    } else if (!shouldShowArchived && !mentor.archived) {
      return true;
    }
  })

  return (
    <>
      <div className="text-align-right">
        <label>
          <input
            type="checkbox"
            checked={shouldShowArchived}
            onClick={() => setShouldShowArchived(!shouldShowArchived)}
          />
          Show archived?
        </label>
      </div>
      <table>
        <thead>
          <tr>
            <th width="15%">Name</th>
            <th width="15%">Hours</th>
            <th width="70%">Mentees</th>
          </tr>
        </thead>
        <tbody>
          {filteredMentors.map((mentor) => {
            const latestMonthCount = mentor.counts.reverse()[0];
            return (
              <tr>
                <td>
                  <a href={mentor.admin_path}>{mentor.name}</a>
                </td>
                <td>{latestMonthCount && <>
                  {latestMonthCount.hours} in {latestMonthCount.month_name} {latestMonthCount.year}
                </>}</td>
                <td>{mentor.mentee_names}</td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </>
  );
};
