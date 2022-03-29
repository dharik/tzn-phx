defmodule Tzn.Transizion do
  @moduledoc """
  The Transizion context.
  """

  import Ecto.Query, warn: false

  alias Tzn.Repo
  alias Tzn.Transizion.Mentor
  alias Tzn.Transizion.MentorHourCounts
  alias Tzn.Transizion.Mentee
  alias Tzn.Transizion.StrategySession
  alias Tzn.Transizion.MentorTimelineEvent
  alias Tzn.Transizion.MentorTimelineEventMarking
  alias Tzn.Transizion.ContractPurchase
  alias Tzn.Users.User
  alias Tzn.Transizion.MenteeChanges

  require IEx

  def list_mentors do
    Mentor |> order_by(asc: :archived, asc: :name) |> Repo.all()
  end

  def get_mentor(%User{mentor_profile: nil}), do: false
  def get_mentor(%User{mentor_profile: %Mentor{} = m}), do: m

  def get_mentor(%User{mentor_profile: %Ecto.Association.NotLoaded{}} = u) do
    u |> Ecto.assoc(:mentor_profile) |> Repo.one()
  end

  # TODO: Handle already loaded association
  def get_mentor(%Mentee{} = mentee) do
    Ecto.assoc(mentee, :mentor) |> Repo.one()
  end

  def get_mentor!(id), do: Repo.get!(Mentor, id)

  def mentor?(%User{mentor_profile: nil}), do: false
  def mentor?(%User{mentor_profile: %Mentor{}}), do: true

  def mentor?(%User{mentor_profile: %Ecto.Association.NotLoaded{}} = u) do
    !is_nil(get_mentor(u))
  end

  def get_hour_counts(%Mentee{} = m) do
    Ecto.assoc(m, :hour_counts) |> Repo.one()
  end

  def college_list_speciality?(%User{mentor_profile: nil}), do: false
  def college_list_speciality?(%User{mentor_profile: %Mentor{} = m}), do: m.college_list_specialty

  def college_list_speciality?(%User{mentor_profile: %Ecto.Association.NotLoaded{}} = u) do
    m = get_mentor(u)
    m && m.college_list_specialty
  end

  @doc """
  Creates a mentor.

  ## Examples

      iex> create_mentor(%{field: value})
      {:ok, %Mentor{}}

      iex> create_mentor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mentor(attrs \\ %{}) do
    %Mentor{}
    |> Mentor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mentor.

  ## Examples

      iex> update_mentor(mentor, %{field: new_value})
      {:ok, %Mentor{}}

      iex> update_mentor(mentor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mentor(%Mentor{} = mentor, attrs) do
    mentor
    |> Mentor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mentor.

  ## Examples

      iex> delete_mentor(mentor)
      {:ok, %Mentor{}}

      iex> delete_mentor(mentor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mentor(%Mentor{} = mentor) do
    Repo.delete(mentor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mentor changes.

  ## Examples

      iex> change_mentor(mentor)
      %Ecto.Changeset{data: %Mentor{}}

  """
  def change_mentor(%Mentor{} = mentor, attrs \\ %{}) do
    Mentor.changeset(mentor, attrs)
  end

  # Mentee stuff

  def list_mentees do
    Mentee |> order_by(asc: :archived, asc: :name) |> Repo.all()
  end

  def list_mentees(%{mentor: mentor}) do
    Repo.all(
      from(m in Mentee, where: m.mentor_id == ^mentor.id, order_by: [asc: m.archived, desc: m.id])
    )
  end

  def get_mentee!(id), do: Repo.get!(Mentee, id)
  def get_mentee(id), do: Repo.get(Mentee, id)
  def get_mentee_by_email(email), do: Repo.get_by(Mentee, email: email)

  def delete_mentee(%Mentee{} = mentee) do
    Repo.delete(mentee)
  end

  def change_mentee(%Mentee{} = mentee, attrs \\ %{}) do
    Mentee.changeset(mentee, attrs)
  end

  def create_mentee(attrs \\ %{}) do
    %Mentee{}
    |> Mentee.changeset(attrs)
    |> Repo.insert()
  end

  def admin_change_mentee(%Mentee{} = mentee, attrs \\ %{}) do
    Mentee.admin_changeset(mentee, attrs)
  end

  def admin_create_mentee(attrs \\ %{}) do
    %Mentee{}
    |> Mentee.admin_changeset(attrs)
    |> Repo.insert()
  end

  def update_mentee(%Mentee{} = mentee, attrs, %User{} = user) do
    mentee_changeset = Mentee.changeset(mentee, attrs)

    if mentee_changeset.valid? do
      update_and_track_mentee_changes(mentee, mentee_changeset, user)
    else
      Ecto.Changeset.apply_action(mentee_changeset, :update)
    end
  end

  def admin_update_mentee(%Mentee{} = mentee, attrs, %User{} = user) do
    mentee_changeset = Mentee.admin_changeset(mentee, attrs)

    if mentee_changeset.valid? do
      update_and_track_mentee_changes(mentee, mentee_changeset, user)
    else
      Ecto.Changeset.apply_action(mentee_changeset, :update)
    end
  end

  def update_and_track_mentee_changes(%Mentee{} = mentee, changeset, %User{} = user) do
    Repo.transaction(fn ->
      mentee_result = changeset |> Repo.update!()

      Map.to_list(changeset.changes)
      |> Enum.filter(fn {field, _} ->
        field in [:parent_todo_notes, :mentor_todo_notes, :mentee_todo_notes, :grade, :mentor_rate]
      end)
      |> Enum.each(fn {field, value} ->
        Repo.insert!(
          MenteeChanges.changeset(%MenteeChanges{}, %{
            mentee_id: mentee.id,
            changed_by: user.id,
            field: Atom.to_string(field),
            new_value: String.Chars.to_string(value)
          })
        )
      end)

      mentee_result
    end)
  end


  @doc """
  Returns the list of strategy_sessions.

  ## Examples

      iex> list_strategy_sessions()
      [%StrategySession{}, ...]

  """
  def list_strategy_sessions do
    Repo.all(StrategySession)
  end

  @doc """
  Gets a single strategy_session.

  Raises `Ecto.NoResultsError` if the Strategy session does not exist.

  ## Examples

      iex> get_strategy_session!(123)
      %StrategySession{}

      iex> get_strategy_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_strategy_session!(id), do: Repo.get!(StrategySession, id)

  @doc """
  Creates a strategy_session.

  ## Examples

      iex> create_strategy_session(%{field: value})
      {:ok, %StrategySession{}}

      iex> create_strategy_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_strategy_session(attrs \\ %{}) do
    %StrategySession{}
    |> StrategySession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a strategy_session.

  ## Examples

      iex> update_strategy_session(strategy_session, %{field: new_value})
      {:ok, %StrategySession{}}

      iex> update_strategy_session(strategy_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_strategy_session(%StrategySession{} = strategy_session, attrs) do
    strategy_session
    |> StrategySession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a strategy_session.

  ## Examples

      iex> delete_strategy_session(strategy_session)
      {:ok, %StrategySession{}}

      iex> delete_strategy_session(strategy_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_strategy_session(%StrategySession{} = strategy_session) do
    Repo.delete(strategy_session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking strategy_session changes.

  ## Examples

      iex> change_strategy_session(strategy_session)
      %Ecto.Changeset{data: %StrategySession{}}

  """
  def change_strategy_session(%StrategySession{} = strategy_session, attrs \\ %{}) do
    StrategySession.changeset(strategy_session, attrs)
  end

  def list_mentor_timeline_events do
    MentorTimelineEvent |> order_by(asc: :date, desc: :is_hard_deadline) |> Repo.all()
  end

  def change_mentor_timeline_event(%MentorTimelineEvent{} = event, attrs \\ %{}) do
    MentorTimelineEvent.changeset(event, attrs)
  end

  def update_mentor_timeline_event(%MentorTimelineEvent{} = event, attrs) do
    event
    |> MentorTimelineEvent.changeset(attrs)
    |> Repo.update()
  end

  def create_mentor_timeline_event(attrs \\ %{}) do
    %MentorTimelineEvent{}
    |> MentorTimelineEvent.changeset(attrs)
    |> Repo.insert()
  end

  def get_mentor_timeline_event!(id), do: Repo.get!(MentorTimelineEvent, id)

  def delete_mentor_timeline_event(%MentorTimelineEvent{} = event) do
    Repo.delete(event)
  end

  def mentor_timeline_event_markings(mentee) do
    markings =
      Repo.all(
        from(m in MentorTimelineEventMarking,
          where: m.mentee_id == ^mentee.id
        )
      )

    # Returns a map of event id: marking for easy lookups later.
    # assumes only one marking per event
    Map.new(markings, fn marking -> {marking.mentor_timeline_event_id, marking} end)
  end

  def change_mentor_timeline_event_marking(%MentorTimelineEventMarking{} = marking, attrs \\ %{}) do
    MentorTimelineEventMarking.changeset(marking, attrs)
  end

  def create_mentor_timeline_event_marking(attrs \\ %{}) do
    %MentorTimelineEventMarking{}
    |> MentorTimelineEventMarking.changeset(attrs)
    |> Repo.insert()
  end

  def update_mentor_timeline_event_marking(%MentorTimelineEventMarking{} = marking, attrs) do
    marking
    |> MentorTimelineEventMarking.changeset(attrs)
    |> Repo.update()
  end

  def get_mentor_timeline_event_marking!(id) do
    Repo.get!(MentorTimelineEventMarking, id)
  end

  def get_mentor_profile(user_id) do
    Repo.one(from(m in Mentor, where: m.user_id == ^user_id))
  end

  def change_contract_purchase(%ContractPurchase{} = contract_purchase, attrs \\ %{}) do
    ContractPurchase.changeset(contract_purchase, attrs)
  end

  def create_contract_purchase(attrs \\ %{}) do
    %ContractPurchase{}
    |> ContractPurchase.changeset(attrs)
    |> Repo.insert()
  end

  def get_contract_purchase!(id), do: Repo.get!(ContractPurchase, id)

  def update_contract_purchase(%ContractPurchase{} = contract_purchase, attrs) do
    contract_purchase
    |> ContractPurchase.changeset(attrs)
    |> Repo.update()
  end

  def delete_contract_purchase(%ContractPurchase{} = contract_purchase) do
    Repo.delete(contract_purchase)
  end

  def most_recent_todo_list_updated_at(nil) do
    nil
  end

  def most_recent_todo_list_updated_at(%Mentee{} = mentee) do
    Repo.one(
      from(mc in MenteeChanges,
          where: mc.field in ["parent_todo_notes", "mentee_todo_notes", "mentor_todo_notes"],
          where: mc.mentee_id == ^mentee.id,
          select: max(mc.updated_at)
        )
    )
  end
end
