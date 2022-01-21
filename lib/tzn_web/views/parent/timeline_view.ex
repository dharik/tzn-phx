defmodule TznWeb.Parent.TimelineView do
  use TznWeb, :view

  def default_timeline(%Tzn.Transizion.Mentee{} = mentee) do
    case mentee.grade do
      "middle_school" -> "Middle School Topics"
      "rising_freshman"  -> "Freshman"
      "freshman" -> "Freshman"
      "rising sophomore" -> "Sophomore"
      "sophomore" -> "Sophomore"
      "rising junior" -> "Junior"
      "junior" -> "Junior"
      "rising senior" -> "Senior"
      "senior" -> "Senior"
    end
  end

  def timeline_order do
    ["Middle School Topics", "Freshman", "Sophomore", "Junior", "Senior"]
  end

  def timeline_data do
    %{
      "Middle School Topics": [
        %{
          monthName: "Summer",
          content: ~S"""
          <ul>
            <li>Encourage students to explore activities they love</li>
            <li>Think about activities to participate in while in school</li>
            <li>(6th) Work with your child to determine organizational strategies for managing multiple teachers and classes</li>
            <li>(7th/8th) Spend time with your child evaluating organizational systems from previous years and making changes as needed</li>
          </ul>
          """,
          colorClass: "background-primary-50"
        },
        %{
          monthName: "Early Fall",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester
              <ul>
                <li>Identify your child's needs, be it better study habits or a tutor</li>
                <li>Teach your child how to talk to teachers about grades and ask for extra credit assignments</li>
              </ul>
            </li>
            <li>Discuss possible careers with your child, based on their interests and the classes they do the best in</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Late Fall",
          content: ~S"""
          <ul>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Follow up on any needs identified at the beginning of the semester and ensure the solutions are working well</li>
            <li>Discuss plans for winter break with your child, including holiday travel and possible extracurricular activities</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Early Spring",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Evaluate organizational systems from last semester with your child.
              <ul>
                <li>What worked? What didn't? What do you want to try this semester?</li>
              </ul>
            </li>
            <li>Continue career discussions with your child, as appropriate</li>
            <li>Ask your child's mentor about doing YouScience or STRONG testing to identify academic aptitudes and areas of interest</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
        %{
          monthName: "Late Spring",
          content: ~S"""
          <ul>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Work on study skills and test-taking strategies with your child, as state EOGs are approaching</li>
            <li>Encourage your child to explore activities related to career interests</li>
            <li>Decide on courses for next year in conjunction with your child and their mentor</li>
            <li>Explore summer plans with your child, including travel, summer camps, and passion projects</li>
            <li>Help your child study for the 8/9th grade PSAT</li>
          </ul>
          """,
          colorClass: "background-success-50"
        }
      ],
      Freshman: [
        %{
          monthName: "Summer",
          content: ~S"""
          <ul>
            <li>Work with your child an their mentor to help pick a high school</li>
            <li>Continue discussing your child's interests as they choose classes and clubs to get involved in</li>
            <li>Help your child understand that all grades from this point onward are part of their college application</li>
          </ul>
          """,
          colorClass: "background-primary-50"
        },
        %{
          monthName: "Early Fall",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester
              <ul>
                <li>Identify your child's needs, be it better study habits or a tutor</li>
                <li>Consider whether your child should drop classes, as appropriate</li>
              </ul>
            </li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Encourage your child to greet their school's college guidance counselor</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Late Fall",
          content: ~S"""
          <ul>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Follow up on any needs identified at the beginning of the semester and ensure the solutions are working well</li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Work with your child to fill out a summer activites audit in preparation for applications in the Spring</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Early Spring",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester.
              <ul>
                <li>Identify your child's needs, be it better study habits or a tutor</li>
                <li>Consider whether your child should drop classes, as appropriate</li>
              </ul>
            </li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Work with your child and their mentor to examine summer opportunities and start applying to several</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
        %{
          monthName: "Late Spring",
          content: ~S"""
          <ul>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Help your child pick clases for the subsequent year with advice from their mentor</li>
            <li>Encourage your child to stop by their school college guidance counselor's office and say, "Hello!"</li>
            <li>Finalize summer applications and make plans with your child according to the responses</li>
            <li>Ensure your child has the time to study for their final exams</li>
          </ul>
          """,
          colorClass: "background-success-50"
        }
      ],
      Sophomore: [
        %{
          monthName: "Summer",
          content: ~S"""
          <ul>
            <li>Discuss the PSAT with your child, if they are interested in becoming a merit scholar they should start studying now</li>
            <li>Consider helping your child start a long-term volunteering or capstone project, based on their interests</li>
            <li>Depending on their age, your child may also consider a part-time job</li>
            <li>Help your child write their first resume</li>
          </ul>
          """,
          colorClass: "background-primary-50"
        },
        %{
          monthName: "Early Fall",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester
              <ul>
                <li>Identify your child's needs, be it better study habits or a tutor</li>
                <li>Consider whether your child should drop classes, as appropriate</li>
              </ul>
            </li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Encourage your child to greet their college guidance counselor at school</li>
            <li>Discuss SAT and ACT plans with your child. Ideally, they should take both and then study for the one they score better on.</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Late Fall",
          content: ~S"""
          <ul>
            <li>Your child should take the PSAT; ensure they get testing accomodations, including extra time, if eligible </li>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Discuss working on an independent capstone project, if not already started</li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Work with your child to fill out a summer activites audit in prepartion for applications in the Spring</li>
            <li>Consider meeting with Transizion's financial expert to learn about your child's options for paying for college</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Early Spring",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester.
              <ul>
                <li>Identify your child's needs, be it better study habits or a tutor</li>
              </ul>
            </li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Work with your child and their mentor to examine summer opportunities and start applying to several</li>
            <li>Develop a study plan for the SAT or ACT, including taking the test at least once over the summer</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
        %{
          monthName: "Late Spring",
          content: ~S"""
          <ul>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Help your child pick clases for the subsequent year with advice from their mentor</li>
            <li>Encourage your child to stop by their school college guidance counselor's office and say, "Hello!"</li>
            <li>Work with your child and their mentor to assemble a preliminary college list</li>
            <li>Make summer plans with your child, considering summer programs, college tours, and any family travel plans</li>
            <li>Ensure your child has the time to study for their final exams</li>
          </ul>
          """,
          colorClass: "background-success-50"
        }
      ],
      Junior: [
        %{
          monthName: "Summer",
          content: ~S"""
          <ul>
            <li>Visit college campuses with your child</li>
            <li>Help your child update their resume</li>
            <li>Discuss the PSAT with your child, if they are interested in becoming a merit scholar, they should start studying now</li>
            <li>Your child should take either the SAT or the ACT this summer; ensure they get testing accomodations, including extra time, if eligible </li>
          </ul>
          """,
          colorClass: "background-primary-50"
        },
        %{
          monthName: "Early Fall",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester
              <ul>
                <li>Identify your child's needs, be it better study habits or a tutor</li>
                <li>Consider whether your child should drop classes, as appropriate</li>
              </ul>
            </li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Encourage your child to set up a meeting with their school's college guidance counselor to discuss potential colleges and universities</li>
            <li>Help your child schedule and attend college information sessions for schools they are interested in attending</li>
            <li>Discuss ongoing SAT or ACT testing with your child. Do they already have a good score? Do they need a tutor? When are they taking it again?</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Late Fall",
          content: ~S"""
          <ul>
            <li>Your child should take the PSAT; ensure they get testing accomodations, including extra time, if eligible </li>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Discuss working on an independent capstone project, if not already started</li>
            <li>Work with your child to fill out a summer activites audit in prepartion for applications in the Spring</li>
            <li>Discuss ongoing SAT or ACT testing with your child. They should plan on having a score they are happy with by the end of Junior year.</li>
            <li>Encourage your child to pick teachers they will ask for letters of recommendation and start spending time in their "office hours" starting now.</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "Early Spring",
          content: ~S"""
          <ul>
            <li>Set SMART goals for the semester with your child</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester.
              <ul>
                <li>Identify your child's needs, be it better study habits or a tutor</li>
              </ul>
            </li>
            <li>Ask your child about their current extracurriculars. What do they like or dislike?  Why?  Help them refine their activities.</li>
            <li>Work with your child and their mentor to examine summer opportunities and start applying to several</li>
            <li>Help your child adhere to the SAT or ACT plan developed earlier in the year.</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
        %{
          monthName: "Late Spring",
          content: ~S"""
          <ul>
            <li>Check in on your child's SMART goals and grades and make adjustments as necessary to meet those goals</li>
            <li>Help your child pick clases for the subsequent year with advice from their mentor</li>
            <li>Encourage your child to stop by their school college guidance counselor's office and ask if they have a brag sheet to help teachers write letters of recommendation.  If not, your child's mentor can provide one.</li>
            <li>Work with your child and their mentor to assemble a final college list</li>
            <li>Help your child adhere to the SAT or ACT plan developed earlier in the year, including taking the ACT or SAT again, if needed.</li>
            <li>Make summer plans with your child, considering summer programs, college tours, and any family travel plans</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
        %{
          monthName: "May",
          content: ~S"""
          <ul>
            <li>At the end of the school year, remind your child to ask teachers if they would write them a letter of recommendation next fall</li>
            <li>Help your child start working on their personal essay, activities list, and filling out personal information on Common App</li>
            <li>Ensure your child has the time to study for their final exams</li>
          </ul>
          """,
          colorClass: "background-success-50"
        }
      ],
      Senior: [
        %{
          monthName: "June",
          content: ~S"""
          <ul>
            <li>Continue working with your child to complete the personal essay, activities list, and personal information on Common App</li>
            <li>If your child is applying to schools in Texas, work on the Apply Texas applicaiton, as some open in July</li>
            <li>Consider meeting with Transizion's financial expert to learn about your child's options for paying for college</li>
            <li>Help your child finish any independent capstone projects</li>
          </ul>
          """,
          colorClass: "background-primary-50"
        },
        %{
          monthName: "July",
          content: ~S"""
          <ul>
            <li><b>Apply Texas opens</b></li>
            <li>Finish Common App essay, activities list, and filling out personal information on Common App</li>
            <li>Work with your child to finish brag sheets so they are ready to give to teachers at the beginning of the school year</li>
            <li>Your child should be done taking the ACT or SAT</li>
            <li>Look up application ED/EA/ERA/RD deadlines and create a plan to tackle supplemental essays with your child</li>
          </ul>
          """,
          colorClass: "background-primary-50"
        },
        %{
          monthName: "August",
          content: ~S"""
          <ul>
            <li><b>Common App/UCs/Coalition opens</b></li>
            <li>Remind your child to ask their teachers for letters of recommendation within the first 2-3 weeks of school starting</li>
            <li>
              Check in with your child about their grades a month or two after school begins for the semester
              <ul>
                <li>Consider whether your child should drop classes, as appropriate</li>
              </ul>
            </li>
            <li>Ensure your child continues to work on their supplemental applications.</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "September",
          content: ~S"""
          <ul>
            <li>Help your child fill out personal details for all their applications; be sure they add recommenders to apps so they can upload letters of recommendation</li>
            <li>Examine the FAFSA and CSS profile with your child and decide whether you will fill it out, keeping in mind that it is required for many scholarships</li>
            <li>Encourage your child to visit their school's guidance counselor and get all necessary college application forms, such as Naviance instructions</li>
            <li>Research which colleges want interviews or auditions and work with your child to schedule them as needed</li>
            <li>If your child has a good start on their supplemental essays and has extra bandwidth, encourage them to ask their mentor about a scholarship audit.</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "October",
          content: ~S"""
          <ul>
            <li>If your child is nervous about upcoming interviews, encourage them to ask their mentor for practice questions and a mock interview session.</li>
            <li>Fill out FAFSA/CSS as early as possible to maximize potential financial aid</li>
            <li>Remind your child to sent their official SAT or ACT scores to the schools on their list</li>
            <li>Work with your child to decide if creating a ZeeMee profile is a good choice for them</li>
            <li>Ensure that your student has all their letters of recommendation and has thanked their recommenders. Deadlines are next month!</li>
            <li>Ensure your child has submitted all of their early applications by the end of October</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "November",
          content: ~S"""
          <ul>
            <li>If your child has a good start on their supplemental essays and has extra bandwidth, encourage them to ask their mentor about a scholarship audit.</li>
            <li>Encourage your child to take advantage of the Thanksgiving break to catch up on school and supplemental essays</li>
            <li><b>UC deadline</b></li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "December",
          content: ~S"""
          <ul>
            <li><b>Apply Texas regular deadline</b></li>
            <li>
              As early decisions arrive, think about next steps for all possible scenarios.
              <ul>
                <li>If your child gets into their ED school, congratulations! Do you want them to start working on scholarships?</li>
                <li>If your child gets deferred or rejected, do you want them to continue applying to reach schools or should they focus more on soft target and safety schools?</li>
              </ul>
            </li>
            <li>Do not let your child wait to work on their final supplemental essays until the last week of December. Mentors will do their best, but they also have family obligations during this period.</li>
            <li>Ensure your child has submitted their regularly applications by the end of December</li>
          </ul>
          """,
          colorClass: "background-warning-50"
        },
        %{
          monthName: "January",
          content: ~S"""
          <ul>
            <li>If your child was accepted to their early decision school, remember to send in the necessary deposit</li>
            <li>If your child has a good start on their supplemental essays and has extra bandwidth, encourage them to ask their mentor about a scholarship audit.</li>
            <li>Help your child write and submit letters of continued interest to schools where they were deferred or waitlisted</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
        %{
          monthName: "Early Spring",
          content: ~S"""
          <ul>
          <li>
          As acceptances continue to arrive, work with your child to decide which school they will attend.
          <ul>
          <li>If you have questions about financial aid packets or schools, your child's mentor would be happy to answer your questions</li>
          </ul>
          </li>
          <li>Once you've decided on a school, be sure to send in the necessary deposit to hold your child's spot.</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
        %{
          monthName: "Late Spring",
          content: ~S"""
          <ul>
            <li>Talk to your child about what college life is like. Topics to consider include how to do laundry, dealing with roommates, and how to arrange their study schedule for classes.</li>
            <li>Discuss summer plans with your child, including revising their school of choice and other summer opportunities</li>
          </ul>
          """,
          colorClass: "background-success-50"
        },
      ]
    }
  end
end
