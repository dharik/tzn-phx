defmodule TznWeb.MentorTimesheetEntry do
  use Phoenix.LiveView
  use Phoenix.HTML
  import TznWeb.ErrorHelpers
  alias TznWeb.Router.Helpers, as: Routes

  def mount(
        _params,
        %{
          "timesheet_entry_id" => timesheet_entry_id,
          "pod_id" => pod_id,
          "mentor_id" => mentor_id
        },
        socket
      ) do
    default_started_at = Timex.now() |> Timex.shift(hours: -6) |> Timex.to_naive_datetime()

    pod = Tzn.Pods.get_pod(pod_id)
    timesheet_entry =
      if timesheet_entry_id do
        Tzn.Timesheets.get_timesheet_entry!(timesheet_entry_id)
      else
        %Tzn.Transizion.TimesheetEntry{
          started_at: default_started_at,
          ended_at: default_started_at |> Timex.shift(minutes: 60),
          pod_id: pod_id,
          mentor_id: mentor_id,
          mentee_grade: if pod do
            pod.mentee.grade
          else
            nil
          end
        }
      end


    mentor = Tzn.Transizion.get_mentor(mentor_id)

    pods =
      if mentor do
        Tzn.Pods.list_pods(mentor)
        |> Enum.filter(&(&1.active || timesheet_entry.id == &1.id))
      else
        []
      end

    categories = Tzn.Timesheets.categories(mentor, pod)

    {:ok,
     socket
     |> assign(:mentor, mentor)
     |> assign(:timesheet_entry, timesheet_entry)
     |> assign(:pod, pod)
     |> assign_todo_error()
     |> assign(:pods, pods)
     |> assign(:grade_options, Tzn.Util.grade_options())
     |> assign(:categories, categories)
     |> assign_new(:action, fn ->
       if timesheet_entry.id do
         Routes.mentor_timesheet_entry_path(socket, :update, timesheet_entry)
       else
         Routes.mentor_timesheet_entry_path(socket, :create)
       end
     end)
     |> assign(
       :changeset,
       Tzn.Timesheets.change_timesheet_entry(timesheet_entry) |> Map.put(:action, :update)
     )}
  end

  def handle_event("validate", %{"timesheet_entry" => attrs}, socket) do
    pod = Tzn.Pods.get_pod(attrs["pod_id"])

    pod_changed =
      cond do
        !socket.assigns.pod && pod -> true
        socket.assigns.pod && !pod -> true
        pod && socket.assigns.pod && socket.assigns.pod.id !== pod.id -> true
        true -> false
      end

    attrs =
      if pod_changed do
        attrs |> Map.put("category", "")
      else
        attrs
      end

    attrs =
      if pod_changed && pod do
        attrs
        |> Map.put("mentee_grade", pod.mentee.grade)
      else
        attrs
      end

    updated_changeset =
      Tzn.Timesheets.change_timesheet_entry(
        socket.assigns.timesheet_entry,
        attrs
      )
      |> Map.put(:action, :update)

    categories = Tzn.Timesheets.categories(socket.assigns.mentor, pod)

    {:noreply,
     socket
     |> assign(:changeset, updated_changeset)
     |> assign(:pod, pod)
     |> assign_todo_error()
     |> assign(:categories, categories)}
  end

  def handle_event("add_todo_mentor", _params, socket) do
    Tzn.Pods.create_todo(%{
      todo_text: "Change me",
      pod_id: socket.assigns.pod.id,
      due_date: Timex.today() |> Timex.shift(days: 1),
      assignee_type: "mentor"
    })

    {:noreply,
     socket |> assign(:pod, Tzn.Pods.get_pod(socket.assigns.pod.id)) |> assign_todo_error()}
  end

  def handle_event("add_todo_parent", _params, socket) do
    Tzn.Pods.create_todo(%{
      todo_text: "Change me",
      pod_id: socket.assigns.pod.id,
      due_date: Timex.today() |> Timex.shift(days: 1),
      assignee_type: "parent"
    })

    {:noreply,
     socket |> assign(:pod, Tzn.Pods.get_pod(socket.assigns.pod.id)) |> assign_todo_error()}
  end

  def handle_event("add_todo_mentee", _params, socket) do
    Tzn.Pods.create_todo(%{
      todo_text: "Change me",
      pod_id: socket.assigns.pod.id,
      due_date: Timex.today() |> Timex.shift(days: 1),
      assignee_type: "mentee"
    })

    {:noreply,
     socket |> assign(:pod, Tzn.Pods.get_pod(socket.assigns.pod.id)) |> assign_todo_error()}
  end

  def assign_todo_error(socket = %{assigns: %{pod: nil}}) do
    assign(socket, :todo_error, nil)
  end

  def assign_todo_error(socket = %{assigns: %{pod: pod}}) do
    case Tzn.Pods.todos_state(pod) do
      {:ok, _} -> assign(socket, :todo_error, nil)
      {:error, message} -> assign(socket, :todo_error, message)
    end
  end

  def handle_info(:todo_updated, socket) do
    # Side-load the pod again so we don't move around all of the todos
    pod = Tzn.Pods.get_pod(socket.assigns.pod.id)

    {:noreply,
     case Tzn.Pods.todos_state(pod) do
       {:ok, _} -> assign(socket, :todo_error, nil)
       {:error, message} -> assign(socket, :todo_error, message)
     end}
  end
end
