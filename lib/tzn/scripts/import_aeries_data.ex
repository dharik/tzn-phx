defmodule Tzn.Scripts.ImportAeriesData do
  @moduledoc """
  This is not used, just for reference
  """
  def run(url, cert, pod_group_id) do
    pod_group = Tzn.PodGroups.get_group(pod_group_id)

    {:ok, response} = HTTPoison.get(
      url,
      ["Accept": "application/json",
      "AERIES-CERT": cert],
      [timeout: 100_000, recv_timeout: 100_000]
    )

    students =
      Jason.decode!(response.body)
      |> Enum.map(fn s ->
          s
          |> Map.take( ["FirstName", "LastName", "Grade", "ParentGuardianName", "ResidenceAddressState", "ParentEmailAddress", "StudentEmailAddress", "FirstNameAlias", "LastNameAlias", "Gender"])
          |> Map.update!("StudentEmailAddress", fn e ->
            if is_binary(e) do
              String.downcase(e)
            else
              nil
            end
          end)
          |> Map.update!("ParentEmailAddress", fn e ->
            if is_binary(e) do
              String.downcase(e)
            else
              nil
            end
          end)
          |> Map.update!("Grade", fn g ->
            case g do
              9 -> "freshman"
              10 -> "sophomore"
              11 -> "junior"
              12 -> "senior"
              _ ->
                if g < 9 do
                  "middle_school"
                else
                  "college"
                end
            end

          end)
      end)

      IO.inspect(students)

    Enum.each(students, fn s ->
      # Look up mentee by email
      mentee = Tzn.Mentee.get_mentee_by_email(s["StudentEmailAddress"])
      if mentee do
        IO.puts("got mentee")
        IO.inspect(mentee)
      else
        m = Tzn.Mentee.admin_create_mentee(%{
          name: s["FirstName"] <> " " <> s["LastName"],
          nick_name: s["FirstNameAlias"],
          email: s["StudentEmailAddress"],
          grade: s["Grade"],
          internal_note: "<p>Import for cohort: " <> pod_group.name <> " on " <> to_string(Timex.today()) <> "</p><br />Parent name: " <> s["ParentGuardianName"] <> "<br />Parent email: " <> s["ParentEmailAddress"] <> "<br />Gender: " <> s["Gender"] <> "<br />State: " <> s["ResidenceAddressState"] <> "<br />------"
        })
      end
    end)


  end
end
