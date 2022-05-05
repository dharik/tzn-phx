defmodule Tzn.Repo.Migrations.CreatePodViews do
  use Ecto.Migration

  def up do
    execute """
     CREATE VIEW pod_hour_counts AS  WITH a AS (
          SELECT pods.id AS pod_id,
             ( SELECT COALESCE(sum((date_part('epoch'::text, timesheet_entries.ended_at) - date_part('epoch'::text, timesheet_entries.started_at)) / 3600::double precision), 0::numeric::double precision) AS "coalesce"
                    FROM timesheet_entries
                   WHERE timesheet_entries.pod_id = pods.id) AS hours_used,
             ( SELECT COALESCE(sum(contract_purchases.hours)::double precision, 0::numeric::double precision) AS "coalesce"
                    FROM contract_purchases
                   WHERE contract_purchases.pod_id = pods.id) AS hours_purchased
            FROM pods
         )
    SELECT a.pod_id,
     a.hours_used,
     a.hours_purchased,
     a.hours_purchased - a.hours_used AS hours_remaining
    FROM a;

    """

    execute """
    DROP VIEW mentee_hour_counts
    """
  end

  def down do
    execute """
    CREATE VIEW mentee_hour_counts AS  SELECT mentees.id AS mentee_id,
        ( SELECT COALESCE(sum((date_part('epoch'::text, timesheet_entries.ended_at) - date_part('epoch'::text, timesheet_entries.started_at)) / 3600::double precision), 0::numeric::double precision) AS "coalesce"
               FROM timesheet_entries
              WHERE timesheet_entries.mentee_id = mentees.id) AS hours_used,
        ( SELECT COALESCE(sum(contract_purchases.hours)::double precision, 0::numeric::double precision) AS "coalesce"
               FROM contract_purchases
              WHERE contract_purchases.mentee_id = mentees.id) AS hours_purchased
       FROM mentees;


    """

    execute """
    DROP VIEW pod_hour_counts
    """
  end
end
