defmodule Tzn.PodGroups do
  alias Tzn.DB.Pod
  alias Tzn.DB.PodGroup
  alias Tzn.DB.SchoolAdmin
  alias Tzn.DB.PodGroupToProfile
  alias Tzn.DB.PodToPodGroup
  alias Tzn.Users.Admin
  alias Tzn.Repo

  import Ecto.Query

  def add_to_group(%PodGroup{id: group_id}, %SchoolAdmin{id: school_admin_id}) do
    unless Repo.get_by(PodGroupToProfile, pod_group_id: group_id, school_admin_id: school_admin_id) do
      PodGroupToProfile.changeset(%PodGroupToProfile{}, %{
        school_admin_id: school_admin_id,
        pod_group_id: group_id
      })
      |> Repo.insert()
    end
  end

  def add_to_group(%PodGroup{id: group_id}, %Pod{id: pod_id}) do
    unless Repo.get_by(PodToPodGroup, pod_group_id: group_id, pod_id: pod_id) do
      PodToPodGroup.changeset(%PodToPodGroup{}, %{pod_id: pod_id, pod_group_id: group_id})
      |> Repo.insert()
    end
  end

  def remove_from_group(%PodGroup{id: group_id}, %SchoolAdmin{id: admin_id}) do
    Repo.get_by(PodGroupToProfile, pod_group_id: group_id, school_admin_id: admin_id)
    |> Repo.delete()
  end

  def remove_from_group(%PodGroup{id: group_id}, %Pod{id: pod_id}) do
    Repo.get_by(PodToPodGroup, pod_group_id: group_id, pod_id: pod_id)
    |> Repo.delete()
  end

  def create_group(params) do
    change_group(%PodGroup{}, params) |> Repo.insert()
  end

  def update_group(%PodGroup{} = group, changes) do
    PodGroup.changeset(group, changes) |> Repo.update()
  end

  def change_group(%PodGroup{} = group, changes \\ %{}) do
    PodGroup.changeset(group, changes)
  end

  def get_group(id) do
    Repo.get(PodGroup, id)
    |> Repo.preload(pods: [:mentee, :mentor, :hour_counts])
    |> Repo.preload(:school_admins)
  end

  def list_groups(%SchoolAdmin{} = a) do
    a |> Ecto.assoc(:pod_groups) |> Repo.all()
  end

  def list_groups(%Admin{}) do
    list_all_groups()
    |> Repo.preload(pods: [:mentee, :mentor, :hour_counts])
    |> Repo.preload(:school_admins)
  end

  def list_all_groups() do
    from(g in PodGroup, order_by: [desc: g.id]) |> Repo.all()
  end
end
