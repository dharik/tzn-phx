defmodule TznWeb.Admin.MatchingAlgorithmView do
  use TznWeb, :view

  def data do
    {:ok, data} = Jason.encode(%{
      options: %{
        hobbies: Tzn.Transizion.Mentor.hobby_options |> Enum.map(&Tuple.to_list/1),
        careers: Tzn.Transizion.Mentor.career_interest_options |> Enum.map(&Tuple.to_list/1),
        school_tiers: Tzn.Transizion.Mentor.school_tier_options |> Enum.map(&Tuple.to_list/1)
      },
      mentors: Tzn.Repo.all(Tzn.Transizion.Mentor) |> Enum.reject(fn m -> m.archived end) |> Enum.map(&mentor/1) 
      })
      data
    end

  def mentor(%Tzn.Transizion.Mentor{} = mentor) do
    Map.new
    |> Map.put(:career_interests, mentor.career_interests || [])
    |> Map.put(:school_tiers, mentor.school_tiers || [])
    |> Map.put(:gender, mentor.gender)
    |> Map.put(:hobbies, mentor.hobbies || [])
    |> Map.put(:disability_experience, mentor.disability_experience)
    |> Map.put(:social_factor, mentor.social_factor)
    |> Map.put(:international_experience, mentor.international_experience)
    |> Map.put(:name, mentor.name)
    |> Map.put(:id, mentor.id)
    |> Map.put(:photo_url, mentor.photo_url)
  end
end