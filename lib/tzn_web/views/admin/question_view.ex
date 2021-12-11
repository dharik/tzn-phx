defmodule TznWeb.Admin.QuestionView do
  use TznWeb, :view

  def question_edit_text(q) do
    if Enum.count(q.question_sets) == 0 do
      "Edit*"
    else
      "Edit"
    end
  end
end
