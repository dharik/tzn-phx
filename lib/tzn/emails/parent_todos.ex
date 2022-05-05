defmodule Tzn.Emails.ParentTodos do
  @moduledoc """
  I've appended pod_id to the email key for when a parent has multiple children.
  Without it, we'd only send a parent one email with notes about only one of their
  children. Eventually this should be a single email with contents of multiple
  mentees but that's a nice-to-have right now.

  Eventually it might make sense to use a json field on email_history that tells us what
  inputs went into the email. The string key seems simple enough.


  """

  import Swoosh.Email
  use Phoenix.Swoosh, view: TznWeb.EmailView, layout: {TznWeb.LayoutView, :email}
  alias Tzn.DB.Pod
  require Logger

  def maybe_send_for_pod(%Pod{} = pod) do
    pod = Tzn.Pods.get_pod!(pod.id) # Reload with many of the associations
    if has_notes(pod) do
      if should_send_to_parent(pod.mentee.parent1_email, pod.id) do
        Logger.info(
          "Sending parent(1) update to #{pod.mentee.parent1_email} for pod id:#{pod.mentee.id}"
        )

        generate(
          pod.mentee.parent1_email,
          Tzn.Util.informal_name(pod.mentee),
          Tzn.Util.informal_name(pod.mentor),
          pod.mentor.email,
          pod.mentee.parent1_name,
          pod.mentee_todo_notes,
          pod.parent_todo_notes,
          pod.mentor_todo_notes
        )
        |> Tzn.Mailer.deliver!()

        Tzn.Emails.append_email_history(pod.mentee.parent1_email, email_key(pod.id))
      end

      if should_send_to_parent(pod.mentee.parent2_email, pod.id) do
        Logger.info(
          "Sending parent(2) update to #{pod.mentee.parent2_email} for pod id:#{pod.id}"
        )

        generate(
          pod.mentee.parent2_email,
          Tzn.Util.informal_name(pod.mentee),
          Tzn.Util.informal_name(pod.mentor),
          pod.mentor.email,
          pod.mentee.parent2_name,
          pod.mentee_todo_notes,
          pod.parent_todo_notes,
          pod.mentor_todo_notes
        )
        |> Tzn.Mailer.deliver!()

        Tzn.Emails.append_email_history(pod.mentee.parent2_email, email_key(pod.id))
      end
    end
  end

  def generate(
        to,
        mentee_name,
        mentor_name,
        mentor_email,
        parent_name,
        mentee_todos,
        parent_todos,
        mentor_todos
      ) do
    new()
    |> from({"Transizion", "mentors@transizion.com"})
    |> to(to)
    |> reply_to(mentor_email)
    |> bcc(mentor_email)
    |> bcc("mentors@transizion.com")
    |> subject("Transizion Update: #{mentee_name}")
    |> render_body("parent_todos.html", %{
      mentee_todos: mentee_todos,
      parent_todos: parent_todos,
      mentor_todos: mentor_todos,
      mentee_name: mentee_name,
      mentor_name: mentor_name,
      mentor_email: mentor_email,
      parent_name:
        if is_binary(parent_name) && String.length(parent_name) > 2 do
          parent_name
        else
          nil
        end
    })
  end

  def email_key(pod_id) when is_integer(pod_id) do
    email_key(Integer.to_string(pod_id))
  end

  def email_key(pod_id) when is_binary(pod_id) do
    "parent_biweekly_update_with_todos/pod:" <> pod_id
  end

  def should_send_to_parent(nil, _) do
    false
  end

  def should_send_to_parent("", _) do
    false
  end

  @doc """
  Never send the same type of email more than once per 3 days
  """
  def should_send_to_parent(parent_email, pod_id) when is_binary(parent_email) do
    last_email_at = Tzn.Emails.last_email_sent_at(parent_email, email_key(pod_id))

    String.length(parent_email) > 3 &&
      (!last_email_at || !Tzn.Util.within_n_days_ago(last_email_at, 3))
  end

  def has_notes(pod = %Pod{}) do
    is_binary(pod.mentor_todo_notes) || is_binary(pod.mentee_todo_notes) ||
      is_binary(pod.parent_todo_notes)
  end
end
