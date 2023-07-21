# Intro
This is the Elixir/Phoenix monolith for Transizion's CollegeRize.com platform. CollegeRize is the platform that helps
Transizion scale mentorship. In this application you'll find tailored UIs for each of our primary users: admins, mentors, 
parents, school admins

# Getting started
* Get gigalixir access and follow their docs to set up git with their remote so you can deploy
* You can develop in a docker container or natively. The docker setup is just convenient for isolation and upgrades.
```docker-compose up```
* Recommended VS code extensions: dev containers, docker, phoenix framework, ElixirLS, Prettier, Tailwind CSS Intellisense
* Load a DB Snapshot. For simplicity, we just use a full copy of the prod DB
```
pg_dump [url] > dump.sql
dropdb  -h localhost -U postgres tzn_dev
createdb -h localhost -U postgres tzn_dev
psql -h localhost -U postgres -d tzn_dev -f ./dump.sql
```
* `./run.sh` (in your web container if you're using docker)


# Deployment
The app is hosted via gigalixir. They handle scaling & db, it's very simple and easy. To deploy, just run:
```
git push gigalixir master
```

# Development Notes
### UI/UX:
* As of Sep 2022, large number of our users are on 1366x769, 1400x900 for desktop.
For mobile, 390x884.  So design with those sizes in mind. Desktop is 2/3 traffic,
mobile is 1/3. Tablets are < 1 %

### Code:
* When using many_to_many, specify the join keys. We know they're inflected
but we prefer it to be explicit
* Join tables take the name table1_to_table2. **TODO: Consider prefixing join tables with an `_`**

### Testing:
There aren't any code tests because we're tiny and prioritized product iteration. Obviously you must test your work locally
before any deployment. The app and complexity is pretty easy to manage once you know your way around the code base. 
Some e2e tests around the key workflows might be helpful.

We do have DB tests though via metabase infrastructure. See the DB State checks folder in metabase. We can get some e2e/smokey tests
by checking the database state on a regular basis. IE check if parent emails are being sent out regularly

### PRs/Reviews
I'm the only engineer so not necessary. But there should be code reviews before merging/deploying anything

### Idea for automated mentor QA with pod_flags:
* Run job on schedule that looks for something like mentor did not meet with mentee for > 2 weeks
* Create a pod_flag if that's detected with a new `type` field
* Search for mentors with multiple pod_flags of the same type. To track mentor quality/consistency over time

## Running the common app deadlines updater
* Update `ca_scraper/index.js` with a user + pass for common app's website
* Run `./run.sh` in `ca_scraper`. It should spit out some screenshots as well as a `common_app_colleges.json` result
* Copy & Paste the content of `common_app_colleges.json` into `lib/tzn/scripts/import_ca_deadlines.ex`
* Uncommon the lines in `local_log` if desired
* Run the server & call `Tzn.Scripts.ImportCaDeadlines.run` from the console
