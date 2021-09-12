defmodule TznWeb.Parent.CollegeListAnswerView do
  use TznWeb, :view

  def render("create_or_update.json",  %{college_list: college_list, answer: answer}) do
    %{
      test_response: "hi"
    }
  end

end
