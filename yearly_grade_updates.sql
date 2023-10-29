-- Run this yearly around August
-- Saves admins time from manually updating each mentee's grade 'freshman' -> 'sophomore' etc
-- Run all and make sure it runs in order. Easiest way is copy/paste this whole script in postico and then
-- highlight everything and click "execute selection". Not just "execute statement"

-- Successful output should  have 4 "UPDATE ###" lines, like this:
-- UPDATE 3
-- UPDATE 21
-- UPDATE 7
-- UPDATE 1


-- We do senior -> college by hand

-- junior -> senior
with to_update as (select id from mentees 
	where 
		archived != true 
		and
		name not ilike '%test%'
		and 
		(select count(*) from pods where pods.mentee_id = mentees.id and archived = true) = 0
	)
update mentees set grade ='senior', updated_at = now() where grade = 'junior' and id in (select * from to_update);

-- sophomore -> junior
with to_update as (select id from mentees 
	where 
		archived != true 
		and
		name not ilike '%test%'
		and 
		(select count(*) from pods where pods.mentee_id = mentees.id and archived = true) = 0
	)
update mentees set grade ='junior', updated_at = now() where grade = 'sophomore' and id in (select * from to_update);


-- freshman -> sophomore
with to_update as (select id from mentees 
	where 
		archived != true 
		and
		name not ilike '%test%'
		and 
		(select count(*) from pods where pods.mentee_id = mentees.id and archived = true) = 0
	)
update mentees set grade ='sophomore', updated_at = now() where grade = 'freshman' and id in (select * from to_update);
