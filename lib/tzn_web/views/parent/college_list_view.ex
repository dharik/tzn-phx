defmodule TznWeb.Parent.CollegeListView do
  use TznWeb, :view

  def answer_for_question(question, answers) do
    Enum.find(answers, fn a -> a.college_list_question_id == question.id end)
  end
end
