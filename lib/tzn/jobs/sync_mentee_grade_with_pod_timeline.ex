defmodule Tzn.Jobs.SyncMenteeGradeWithPodTimelines do
  alias Tzn.Repo
  import Ecto.Query

  def run do
    from(p in Tzn.DB.Pod, where: not is_nil(p.timeline_id))
    |> Repo.all()
    |> Repo.preload([:timeline, :mentee])
    |> Enum.reject(fn p ->
      p.mentee.grade == "college" || p.mentee.grade == "middle_school"
    end)
    |> Enum.filter(fn p ->
      p.timeline.graduation_year != Tzn.GradeYearConversions.graduation_year(p.mentee.grade)
    end)
    |> Enum.each(fn p ->
      # For now just report so we can verify this detection works
      Bugsnag.report("#{p.mentee.name}'s grade doesn't match graduation year for timeline: #{p.timeline.graduation_year}")
    end)
  end
end
