defmodule TznWeb.TypeformWebhookController do
  use TznWeb, :controller
  require Logger

  def handle(conn, %{"form_response" => %{"answers" => answers}}) do
    mentee_name = get_answer_by_field_id(answers, "e1be2b5d042d25ef")
    mentee_phone = get_answer_by_field_id(answers, "16e1f32b51b6ab87")
    mentee_email = get_answer_by_field_id(answers, "bb066f78-e17e-4ed3-bc01-e2e08db4fad5")

    school_goals = get_answer_by_field_id(answers, "6cae8e678b4c92da")

    parent1_first_name = get_answer_by_field_id(answers, "c778a0f5-a789-401b-b7b8-5962ca076ab2")
    parent1_last_name = get_answer_by_field_id(answers, "18c6ceae-1881-43fc-b5f1-9d85d3f63cb5")
    parent1_phone = get_answer_by_field_id(answers, "d905a713-ce18-4ba9-8542-74b33320589d")
    parent1_email = get_answer_by_field_id(answers, "38f065e6-6f63-47c1-aa24-462176de4862")

    parent2_first_name = get_answer_by_field_id(answers, "e1c9b155-b25b-484b-b41e-53c55a1da318")
    parent2_last_name = get_answer_by_field_id(answers, "a89f0596-73b9-4613-a38d-c22cc2a3f3c8")
    parent2_phone = get_answer_by_field_id(answers, "151597ee-b00d-4634-b0c4-287ba49d06cd")
    parent2_email = get_answer_by_field_id(answers, "ce462e37-19ec-45a9-ab18-55f47c365a9d")

    formatted_data = %{
      mentee: %{
        name: mentee_name,
        internal_notes:
          "Phone: #{mentee_phone}\nParent1 Phone: #{parent1_phone}\nParent2 Phone: #{parent2_phone}\nGoals: #{school_goals}",
        email: mentee_email
      },
      parent1: %{
        name: "#{parent1_first_name} #{parent1_last_name}",
        email: parent1_email
      },
      parent2: %{
        name: "#{parent2_first_name} #{parent2_last_name}",
        email: parent2_email
      }
    }

    Tzn.SlackNotifier.send_to_coding(
      "Got typeoform submission, ```#{Jason.encode!(formatted_data, pretty: true)}```"
    )

    conn |> text("ok")
  end

  def get_answer_by_field_id(answers, field_id) when is_list(answers) and is_binary(field_id) do
    Enum.find(answers, %{}, fn a -> a["field"]["ref"] == field_id end) |> Map.get("text", "")
  end
end
