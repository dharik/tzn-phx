defmodule TznWeb.Admin.MentorController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.Mentor
  alias Tzn.Repo
  alias Tzn.Users

  plug :load_users

  def load_users(conn, _params) do
    users = Users.list_users()
    conn |> assign(:users, users)
  end

  def index(conn, _params) do
    mentors = Transizion.list_mentors() |> Repo.preload([:mentees, :monthly_hour_counts])

    # Sort by hours this month
    sorted_mentors = mentors 
    |> Enum.sort_by(fn mentor ->
      most_recent_month_data = mentor.monthly_hour_counts |> List.first
      if most_recent_month_data && 
        most_recent_month_data.year == Date.utc_today.year && 
        most_recent_month_data.month == Date.utc_today.month do
        most_recent_month_data.hours |> Decimal.to_float
      else
        0.0
      end
    end, :desc)

    render(conn, "index.html", mentors: sorted_mentors)
  end

  def new(conn, _params) do
    changeset = Transizion.change_mentor(%Mentor{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mentor" => mentor_params}) do
    case Transizion.create_mentor(mentor_params) do
      {:ok, mentor} ->
        conn
        |> put_flash(:info, "Mentor created successfully.")
        |> redirect(to: Routes.admin_mentor_path(conn, :show, mentor))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mentor =
      Transizion.get_mentor!(id)
      |> Repo.preload([
        :mentees,
        :monthly_hour_counts,
        :user,
        timesheet_entries: [:mentee],
        strategy_sessions: [:mentee]
      ])

    render(conn, "show.html", mentor: mentor)
  end

  def edit(conn, %{"id" => id}) do
    mentor = Transizion.get_mentor!(id)
    changeset = Transizion.change_mentor(mentor)
    render(conn, "edit.html", mentor: mentor, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentor" => mentor_params}) do
    mentor = Transizion.get_mentor!(id)

    case Transizion.update_mentor(mentor, mentor_params) do
      {:ok, mentor} ->
        conn
        |> put_flash(:info, "Mentor updated successfully.")
        |> redirect(to: Routes.admin_mentor_path(conn, :show, mentor))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mentor: mentor, changeset: changeset)
    end
  end

  #   def delete(conn, %{"id" => id}) do
  #     mentor = Transizion.get_mentor!(id)
  #     {:ok, _mentor} = Transizion.delete_mentor(mentor)

  #     conn
  #     |> put_flash(:info, "Mentor deleted successfully.")
  #     |> redirect(to: Routes.mentor_path(conn, :index))
  #   end
end
