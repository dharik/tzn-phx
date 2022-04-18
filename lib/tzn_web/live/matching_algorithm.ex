defmodule TznWeb.MatchingAlgorithm do
  use Phoenix.LiveView
  use Phoenix.HTML

  def mount(_params, _session, socket) do
    # todo: add timezone, capacity
    {:ok,
     socket
     |> assign(:careers, MapSet.new())
     |> assign(:school_tiers, MapSet.new())
     |> assign(:hobbies, MapSet.new())
     |> assign(:gender, "no_preference")
     |> assign(:social_factor, nil)
     |> assign(:learning_disability, false)
     |> assign(:timezone_offset, nil)
     |> assign(:show_scoring, false)
     |> assign_new(
       :mentors,
       fn ->
         Tzn.Transizion.list_mentors()
         |> Enum.reject(fn m -> m.archived end)
          |> Enum.sort_by(&(&1.photo_url), :desc) # Little hack to prioritize mentors w/ photos on initial load
       end
     )
     |> assign(:scored_mentors, [])
     |> calculate_scores()}
  end

  def handle_event("set_career", %{"career" => career}, socket) do
    {:noreply,
     socket
     |> toggle_value(:careers, career)
     |> calculate_scores()}
  end

  def handle_event("set_hobby", %{"hobby" => hobby}, socket) do
    {:noreply, socket |> toggle_value(:hobbies, hobby) |> calculate_scores()}
  end

  def handle_event("set_school_tier", %{"school_tier" => school_tier}, socket) do
    {:noreply, socket |> toggle_value(:school_tiers, school_tier) |> calculate_scores()}
  end

  def handle_event("set_gender_male", _params, socket) do
    {:noreply, socket |> assign(:gender, "male") |> calculate_scores()}
  end

  def handle_event("set_gender_female", _params, socket) do
    {:noreply, socket |> assign(:gender, "female") |> calculate_scores()}
  end

  def handle_event("set_gender_non_binary", _params, socket) do
    {:noreply, socket |> assign(:gender, "non_binary") |> calculate_scores()}
  end

  def handle_event("set_gender_no_preference", _params, socket) do
    {:noreply, socket |> assign(:gender, "no_preference") |> calculate_scores()}
  end

  def handle_event("toggle_learning_disability", _params, socket) do
    {:noreply, socket |> update(:learning_disability, &(!&1)) |> calculate_scores()}
  end

  def handle_event("set_social_factor", %{"social_factor" => social_factor}, socket) do
    {:noreply, socket |> assign(:social_factor, social_factor) |> calculate_scores()}
  end

  def handle_event("toggle_scoring", _, socket) do
    {:noreply, socket |> update(:show_scoring, &(!&1))}
  end

  def toggle_value(socket, mapset_name, value) do
    socket
    |> update(mapset_name, fn mapset ->
      if MapSet.member?(mapset, value) do
        MapSet.delete(mapset, value)
      else
        MapSet.put(mapset, value)
      end
    end)
  end

  def calculate_scores(
        %{
          assigns: %{
            mentors: mentors,
            careers: selected_careers,
            school_tiers: selected_school_tiers,
            hobbies: selected_hobbies,
            gender: selected_gender,
            social_factor: selected_social_factor,
            learning_disability: selected_learning_disability,
            timezone_offset: selected_timezone_offset
          }
        } = socket
      ) do
    scored_mentors =
      mentors
      |> Enum.map(fn m ->
        career_score =
          MapSet.new(m.career_interests || [])
          |> MapSet.intersection(selected_careers)
          |> MapSet.to_list()
          |> Enum.count()

        career_score = career_score * 40

        school_tier_score =
          MapSet.new(m.school_tiers || [])
          |> MapSet.intersection(selected_school_tiers)
          |> MapSet.to_list()
          |> Enum.count()

        school_tier_score = school_tier_score * 40

        gender_score =
          if m.gender == selected_gender do
            10
          else
            0
          end

        learning_score =
          if m.disability_experience && selected_learning_disability do
            10
          else
            0
          end

        social_factor_score =
          if m.social_factor == selected_social_factor do
            10
          else
            0
          end

        hobby_score =
          MapSet.new(m.hobbies || [])
          |> MapSet.intersection(selected_hobbies)
          |> MapSet.to_list()
          |> Enum.count()

        hobby_score = hobby_score * 10

        scores = %{
          career: career_score,
          school_tier: school_tier_score,
          gender: gender_score,
          learning_disability: learning_score,
          social_factor: social_factor_score,
          hobby: hobby_score
        }

        total = Map.values(scores) |> Enum.sum()
        Map.put(
          m,
          :score,
          total
        ) |> Map.put(:score_breakdown, scores)
      end)
      |> Enum.sort_by(& &1.score, :desc)

    assign(socket, :scored_mentors, scored_mentors)
  end
end
