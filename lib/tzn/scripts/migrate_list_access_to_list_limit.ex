defmodule Tzn.Scripts.MigrateListAccessToListLimit do
  import Ecto.Query
  alias Tzn.Repo
  alias Tzn.DB.Pod

  def run do
    from(p in Pod, where: p.college_list_access == true)
    |> Repo.update_all(set: [college_list_limit: 1])

    from(p in Pod, where: p.college_list_access == false)
    |> Repo.update_all(set: [college_list_limit: 0])

    from(p in Pod, where: p.ecvo_list_access == true)
    |> Repo.update_all(set: [ecvo_list_limit: 1])

    from(p in Pod, where: p.ecvo_list_access == false)
    |> Repo.update_all(set: [ecvo_list_limit: 0])

    from(p in Pod, where: p.scholarship_list_access == true)
    |> Repo.update_all(set: [scholarship_list_limit: 1])

    from(p in Pod, where: p.scholarship_list_access == false)
    |> Repo.update_all(set: [scholarship_list_limit: 0])
  end
end
