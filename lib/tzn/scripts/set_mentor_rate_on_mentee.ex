defmodule Tzn.Scripts.SetMentorRateOnMentee do
  # script didn't work so I ended up doing a raw query
  # update mentees set
	# mentor_rate = (SELECT hourly_rate from mentors where mentors.id = mentees.mentor_id)
  # where mentees.mentor_id is not null
  def run do
    import Ecto.Query
    alias Tzn.Transizion.Mentee
    alias Tzn.Repo

    mentees_to_update =
      from(m in Mentee, where: is_nil(m.mentor_rate) and not is_nil(m.mentor_id))
      |> Repo.all()
      |> Repo.preload(:mentor)

    Enum.each(mentees_to_update, fn mentee ->
      IO.puts("Updating mentee #{mentee.id} whose mentor is #{mentee.mentor_id}")

      Mentee.admin_changeset(mentee, %{
        mentor_rate: mentee.mentor.hourly_rate
      })
      |> Repo.update()
    end)
  end
end
