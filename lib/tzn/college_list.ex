defmodule Tzn.CollegeList do
  import Ecto.Query, warn: false

  alias Tzn.Repo
  alias Tzn.Transizion.Mentee

  alias Tzn.CollegeList.CollegeList
  alias Tzn.CollegeList.Answer
  alias Tzn.CollegeList.Question


  def get_college_list!(%{access_key: access_key}), do: Repo.get_by!(CollegeList, access_key: access_key)
  def get_college_list!(id), do: Repo.get!(CollegeList, id)

  def list_active_questions do
    Repo.all(from q in Question, where: q.active == true, order_by: q.display_order)
  end

end
