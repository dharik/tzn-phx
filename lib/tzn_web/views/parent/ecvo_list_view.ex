defmodule TznWeb.Parent.ECVOListView do
  use TznWeb, :view

  def answer_for_question(question, answers) do
    Enum.find(answers, %{from_pod: "", from_parent: ""}, fn a -> a.question_id == question.id end)
  end
end
