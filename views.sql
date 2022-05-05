reate or replace view mentor_hour_counts as
with mentor_monthly_hours as 
	(select 
		mentor_id,
		(extract(epoch from ended_at) - extract(epoch from started_at))/3600 as hours,
		date_part('year', started_at)::integer as year,
		date_part('month', started_at)::integer as month,
		to_char(started_at, 'month') as month_name
	from timesheet_entries)

select mentor_id, year, month, month_name, sum(hours) as hours from mentor_monthly_hours group by mentor_id, year, month, month_name order by mentor_id, year, month