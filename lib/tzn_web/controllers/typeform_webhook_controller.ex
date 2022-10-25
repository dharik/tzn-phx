defmodule TznWeb.TypeformWebhookController do
  use TznWeb, :controller
  require Logger

  # Twin Palms Onboarding
  def handle(conn, %{"form_response" => %{"form_id" => "s7iPNWWk", "answers" => answers}}) do
    # Direct from form:
    mentee_name = get_answer_by_field_id(answers, "aXHeyB9M7Wiq") |> get_text()
    mentee_email = get_answer_by_field_id(answers, "ZgVeL1tBljZR") |> get_email()
    mentee_pronouns = get_answer_by_field_id(answers, "RB76hekliOmJ") |> get_choice()

    has_p1 = get_answer_by_field_id(answers, "tl1jn2ubSp9x") |> get_boolean()
    p1_fname = get_answer_by_field_id(answers, "Bjs8bWWu2TGE") |> get_text()
    p1_lname = get_answer_by_field_id(answers, "uYRHqS5l0aa8") |> get_text()
    p1_phone = get_answer_by_field_id(answers, "luMaPyIEH9fL") |> get_phone()
    p1_email = get_answer_by_field_id(answers, "PqpsSo9z1s0q") |> get_email()
    p1_relation = get_answer_by_field_id(answers, "G41gzSKavZcx") |> get_text()

    has_p2 = get_answer_by_field_id(answers, "KAi0s0SpVMJY") |> get_boolean()
    p2_fname = get_answer_by_field_id(answers, "uDQDrgPMRwIJ") |> get_text()
    p2_lname = get_answer_by_field_id(answers, "bvupEGrh3T4A") |> get_text()
    p2_phone = get_answer_by_field_id(answers, "KDcQv3hBOtIZ") |> get_phone()
    p2_email = get_answer_by_field_id(answers, "5TwhHBYpt3S3") |> get_email()
    p2_relation = get_answer_by_field_id(answers, "l9uw1CwBWpPY") |> get_text()

    time_slots = get_answer_by_field_id(answers, "jTiuO3bAijfb") |> get_choices()

    # Computed:
    p1_name = "#{p1_fname} #{p1_lname}"
    p2_name = "#{p2_fname} #{p2_lname}"

    p1_data =
      if has_p1 do
        %{
          parent1_name: p1_name,
          parent1_email: p1_email
        }
      else
        %{}
      end

    p2_data =
      if has_p2 do
        %{
          parent2_name: p2_name,
          parent2_email: p2_email
        }
      else
        %{}
      end

    mentee_data =
      %{
        name: mentee_name,
        email: mentee_email,
        grade: "senior",
        pronouns: mentee_pronouns,
        internal_notes:
          "<p>Parent 1 (#{p1_name}) relation: #{p1_relation}, phone: #{p1_phone}</p>" <>
            "<p>Parent 2 (#{p2_name}) relation: #{p2_relation}, phone: #{p2_phone}</p>" <>
            "<p>Time slots: #{time_slots}</p>"
      }
      |> Map.merge(p1_data)
      |> Map.merge(p2_data)

    if Tzn.Mentee.get_mentee_by_email(mentee_email) do
      Tzn.SlackNotifier.send_to_coding(
        "Onboarding submission for Twin Palms but the student is already in our system. Manually update where applicable ```#{Jason.encode!(mentee_data, pretty: true)}```"
      )

      raise "This mentee (#{mentee_email}) already exists and should be manually updated"
    end

    Tzn.Repo.transaction(fn ->
      {:ok, mentee} = Tzn.Mentee.admin_create_mentee(mentee_data)

      {:ok, pod} =
        Tzn.Pods.create_pod(%{
          type: "college_mentoring",
          mentee_id: mentee.id,
          college_list_access: false,
          ecvo_list_access: false,
          scholarship_list_access: false,
          internal_note: "<p>Time slots: #{time_slots}</p>"
        })

      {:ok, _contract_purchase} =
        Tzn.Transizion.create_contract_purchase(%{
          pod_id: pod.id,
          date: Timex.now() |> Timex.to_naive_datetime(),
          hours: 10.0,
          notes: "Default hours from automated Typeform onboarding",
          expected_revenue: 0.0
        })

      # Add pod to group
      # TODO: Set the right pod group id
      Tzn.PodGroups.get_group(1) |> Tzn.PodGroups.add_to_group(pod)

      {:ok, "Added"}
    end)

    Tzn.SlackNotifier.send_to_coding(
      "Onboarding submission for Twin Palms ```#{Jason.encode!(mentee_data, pretty: true)}```"
    )

    conn |> text("ok")
    # conn |> json(mentee_data)
  end

  def get_choice(answer) do
    case answer do
      %{"choice" => %{"label" => value}} -> value
      %{"choice" => %{"other" => value}} -> value
      _ -> nil
    end
  end

  def get_choices(answer) do
    case answer do
      %{"choices" => %{"labels" => values, "other" => other}} -> values ++ [other]
      %{"choices" => %{"labels" => values}} -> values
      %{"choices" => %{"other" => value}} -> [value]
      _ -> nil
    end
  end

  def get_text(answer) do
    case answer do
      %{"text" => value} -> value
      _ -> nil
    end
  end

  def get_phone(answer) do
    case answer do
      %{"phone_number" => value} -> value
      _ -> nil
    end
  end

  def get_email(answer) do
    case answer do
      %{"email" => value} -> value
      _ -> nil
    end
  end

  def get_boolean(answer) do
    case answer do
      %{"boolean" => value} -> value
      _ -> nil
    end
  end

  def get_answer_by_field_id(answers, field_id) when is_list(answers) and is_binary(field_id) do
    Enum.find(answers, nil, fn a -> a["field"]["id"] == field_id end)
  end
end
