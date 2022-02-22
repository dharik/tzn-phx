defmodule Tzn.Emails.ParentTodos do
  @moduledoc """
  I've appended mentee_id to the email key for when a parent has multiple children.
  Without it, we'd only send a parent one email with notes about only one of their
  children. Eventually this should be a single email with contents of multiple
  mentees but that's a nice-to-have right now.

  Eventually it might make sense to use a json field on email_history that tells us what
  inputs went into the email. The string key seems simple enough.


  Tzn.Emails.ParentTodos.maybe_send_for_mentee(Tzn.Transizion.get_mentee())

  """

  import Swoosh.Email
  use Phoenix.Swoosh, view: TznWeb.EmailView, layout: {TznWeb.LayoutView, :email}

  require Logger
  alias Tzn.Transizion.Mentee

  def maybe_send_for_mentee(%Tzn.Transizion.Mentee{} = mentee) do
    with mentee <- Tzn.Repo.reload(mentee),
        mentor <- Tzn.Transizion.get_mentor(mentee),
         true <- has_notes(mentee) do
      if should_send_to_parent(mentee.parent1_email, mentee.id) do
        Logger.info(
          "Sending parent(1) update to #{mentee.parent1_email} for mentee id:#{mentee.id}"
        )

        generate(
          mentee.parent1_email,
          mentee.name,
          mentor.name,
          mentee.parent1_name,
          mentee.mentee_todo_notes,
          mentee.parent_todo_notes,
          mentee.mentor_todo_notes
        )
        |> Tzn.Mailer.deliver!()

        Tzn.Emails.append_email_history(mentee.parent1_email, email_key(mentee.id))
      end

      if should_send_to_parent(mentee.parent2_email, mentee.id) do
        Logger.info(
          "Sending parent(2) update to #{mentee.parent2_email} for mentee id:#{mentee.id}"
        )

        generate(
          mentee.parent2_email,
          mentee.name,
          mentor.name,
          mentee.parent2_name,
          mentee.mentee_todo_notes,
          mentee.parent_todo_notes,
          mentee.mentor_todo_notes
        )
        |> Tzn.Mailer.deliver!()

        Tzn.Emails.append_email_history(mentee.parent2_email, email_key(mentee.id))
      end
    end
  end

  def generate(
        to,
        mentee_name,
        mentor_name,
        parent_name,
        mentee_todos,
        parent_todos,
        mentor_todos
      ) do
    new()
    |> from({"Transizion", "support@transizion.com"})
    |> to(to)
    |> bcc("support@transizion.com")
    |> subject("Transizion Update: #{mentee_name}")
    |> render_body("parent_todos.html", %{
      mentee_todos: mentee_todos,
      parent_todos: parent_todos,
      mentor_todos: mentor_todos,
      mentee_name: mentee_name,
      mentor_name: mentor_name,
      parent_name:
        if is_binary(parent_name) && String.length(parent_name) > 2 do
          parent_name
        else
          nil
        end
    })
  end

  def email_key(mentee_id) when is_integer(mentee_id) do
    email_key(Integer.to_string(mentee_id))
  end

  def email_key(mentee_id) when is_binary(mentee_id) do
    "parent_biweekly_update_with_todos/mentee:" <> mentee_id
  end

  def should_send_to_parent(nil, _) do
    false
  end

  def should_send_to_parent("", _) do
    false
  end

  def should_send_to_parent(parent_email, mentee_id) when is_binary(parent_email) do
    last_email_at = Tzn.Emails.last_email_sent_at(parent_email, email_key(mentee_id))

    String.length(parent_email) > 3 &&
      (!last_email_at || (last_email_at && !Tzn.Util.within_n_days_ago(last_email_at, 14)))
  end

  def has_notes(mentee = %Mentee{}) do
    is_binary(mentee.mentor_todo_notes) || is_binary(mentee.mentee_todo_notes) ||
      is_binary(mentee.parent_todo_notes)
  end
end
