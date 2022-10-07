defmodule TznWeb.Schema do
  use Absinthe.Schema
  import Absinthe.Resolution.Helpers
  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  @desc "A calendar deadline"
  object :deadline do
    field :year, :integer
    field :month, :integer
    field :month_name, :string
    field :month_shortname, :string
    field :day, :integer
    field :title, :string
    field :description, :string

    field :completed, :boolean
    field :hidden, :boolean
  end

  object :timeline do
    field :name, :string
    field :deadlines, list_of(:deadline)
  end

  # PodGroup
  object :cohort do
    field :id, :string
    field :name, :string

    field :students, list_of(:cohort_student) do
      resolve(dataloader(:db, :pods))
    end

    field :student_count, :integer do
      resolve(
        dataloader(:db, :pods,
          callback: fn pods, _parent, _args ->
            {:ok, Enum.count(pods)}
          end
        )
      )
    end

    field :school_admins, list_of(:school_admin) do
      resolve(dataloader(:db, :school_admins))
    end

    field :stats, :cohort_stat do
      resolve(fn _, _, _ ->
        {:ok, 5} # TODO
      end)
    end
  end

  object :cohort_stat do
    field :active_students, :integer
    field :expected_students, :integer
    field :hours_mentored, :integer
    field :hours_per_student, :float
    field :parent_updates_sent, :integer
    field :missed_sessions, :integer
  end

  object :student_highlight do
    field :student, :cohort_student
    field :description, :string
    field :highlight_type, :string # Warning, celebration, etc
  end



  # Pod, sort of
  object :cohort_student do
    field :id, :integer

    field :name, :string do
      resolve(
        dataloader(:db, :mentee, callback: fn mentee, _parent, _args -> {:ok, mentee.name} end)
      )
    end

    field :mentor_name, :string do
      resolve(
        dataloader(:db, :mentor, callback: fn mentor, _parent, _args -> {:ok, mentor.name} end)
      )
    end

    field :first_meeting_with_mentor, :string do
      resolve(
        dataloader(:db, :timesheet_entries,
          callback: fn timesheet_entries, _parent, _args ->
            {:ok,
             timesheet_entries |> Enum.sort_by(& &1.id) |> List.first(%{}) |> Map.get(:started_at)}
          end
        )
      )
    end

    field :most_recent_meeting_with_mentor, :string do
      resolve(
        dataloader(:db, :timesheet_entries,
          callback: fn timesheet_entries, _parent, _args ->
            {:ok,
             timesheet_entries |> Enum.sort_by(& &1.id) |> List.last(%{}) |> Map.get(:started_at)}
          end
        )
      )
    end

    field :hours_mentored, :float do
      resolve(
        dataloader(:db, :hour_counts,
          callback: fn hour_counts, _parent, _args ->
            {:ok, hour_counts.hours_used |> Number.Conversion.to_float() |> Float.round(2)}
          end
        )
      )
    end
  end

  object :school_admin do
    field :name, :string
  end

  object :school_admin_highlight do
    field :description, :string
  end


  query do
    field :student_timeline, list_of(:deadline) do
      arg(:id, non_null(:integer)) # pod id
      arg :include_past, :boolean, default_value: false
      arg :sort, :string, default_value: "asc"
      arg :limit, :integer, default_value: 0

      resolve(fn _, %{id: id, include_past: include_past, sort: sort, limit: limit}, _ ->
        # TODO: Permission check
        pod = Tzn.Pods.get_pod!(id)
        pod_timeline = Tzn.Timelines.get_or_create_timeline(pod)
        events = Tzn.Timelines.aggregate_calendar_events(pod_timeline)

        events = if include_past do
          events
        else
          Enum.reject(events, fn e ->
            Timex.before?(e.date, Timex.now())
          end)
        end

        events = if sort == "asc" do
          Enum.sort_by(events, fn e -> e.date end, {:asc, Date})
        else
          Enum.sort_by(events, fn e -> e.date end, {:desc, Date})
        end

        events = if limit && limit > 0 do
          Enum.take(events, limit)
        else
          events
        end

        {:ok, Enum.map(events, fn event ->
          case event do
            %{calendar: calendar, calendar_event: calendar_event} ->
              %{
                year: event.date.year,
                month: event.date.month,
                month_name: Timex.month_name(event.date.month),
                month_shortname: Timex.month_shortname(event.date.month),
                day: event.date.day,
                title: calendar_event.name,
                description: calendar_event.description,
                completed: event.completed,
                hidden: event.hidden
              }
            %{todo: todo} ->
              %{
                year: event.date.year,
                month: event.date.month,
                month_name: Timex.month_name(event.date.month),
                month_shortname: Timex.month_shortname(event.date.month),
                day: event.date.day,
                title: "TODO",
                description: todo.todo_text,
                completed: event.completed,
                hidden: event.hidden
              }
            %{mentor_timeline_event: mte} ->
              %{
                year: event.date.year,
                month: event.date.month,
                month_name: Timex.month_name(event.date.month),
                month_shortname: Timex.month_shortname(event.date.month),
                day: event.date.day,
                title: nil,
                description: mte.notes,
                completed: event.completed,
                hidden: event.hidden
              }
          end
        end)}
      end)
    end

    field :general_timeline, list_of(:deadline) do
      arg :include_past, :boolean, default_value: false
      arg :sort, :string, default_value: "asc"
      arg :limit, :integer, default_value: 0

      resolve(fn _, %{include_past: include_past, sort: sort, limit: limit}, _ ->
        events =  Tzn.Timelines.general_calendar_events()
        events = if include_past do
           events
         else
           Enum.reject(events, fn e ->
             Timex.before?(e.date, Timex.now())
           end)
         end

         events = if sort == "asc" do
           Enum.sort_by(events, fn e -> e.date end, {:asc, Date})
         else
           Enum.sort_by(events, fn e -> e.date end, {:desc, Date})
         end

         events = if limit && limit > 0 do
           Enum.take(events, limit)
         else
           events
         end

         {:ok, Enum.map(events, fn event ->
             %{
               year: event.date.year,
               month: event.date.month,
               month_name: Timex.month_name(event.date.month),
               month_shortname: Timex.month_shortname(event.date.month),
               day: event.date.day,
               title: event.calendar_event.name,
               description: event.calendar_event.description,
               completed: event.completed,
               hidden: event.hidden
             }
           end)}

      end)


    end

    field :cohorts, list_of(:cohort) do
      resolve(fn
        _, _, %{context: %{current_user: %{school_admin_profile: nil}}} ->
          {:error, "No school profile"}

        _, _, %{context: %{current_user: %{school_admin_profile: current_school_admin}}} ->
          {:ok, Tzn.PodGroups.list_groups(current_school_admin)}
      end)
    end

    field :my_name, :string do
      resolve(fn _, _, %{context: %{current_user: cu}} ->
        name =
          cond do
            !is_nil(cu.school_admin_profile) -> cu.school_admin_profile.name
            !is_nil(cu.mentor_profile) -> cu.mentor_profile.name
            !is_nil(cu.parent_profile) -> cu.parent_profile.name
            !is_nil(cu.mentee_profile) -> cu.mentee_profile.name
            !is_nil(cu.admin_profile) -> "CZ Admin"
            true -> ""
          end

        {:ok, name}
      end)
    end

  end
end
