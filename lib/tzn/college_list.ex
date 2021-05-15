defmodule Tzn.CollegeList do
  @moduledoc """
  The Transizion context.
  """

  import Ecto.Query, warn: false

  alias Tzn.Repo
  alias Tzn.Transizion.MentorHourCounts
  alias Tzn.Transizion.Mentee
  alias Tzn.Transizion.CollegeList
  alias Tzn.Transizion.CollegeListAnswer
  alias Tzn.Transizion.CollegeListQuestion

  def list_college_list_questions do
    CollegeListQuestion |> Repo.all
  end

  def get_college_list!(%{access_key: access_key}), do: Repo.get_by!(CollegeList, access_key: access_key)
  def get_college_list!(id), do: Repo.get!(CollegeList, id)


end
