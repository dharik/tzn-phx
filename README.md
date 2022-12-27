UI/UX:
* As of Sep 2022, large number of our users are on 1366x769, 1400x900 for desktop.
For mobile, 390x884.  So design with those sizes in mind. Desktop is 2/3 traffic,
mobile is 1/3. Tablets are < 1 %

Code:
* When using many_to_many, specify the join keys. We know they're inflected
but we prefer it to be explicit
* Join tables take the name table1_to_table2. **TODO: Consider prefixing join tables with an `_`**
* We don't strictly follow REST


Idea for automated mentor QA with pod_flags:
* Run job on schedule that looks for something like mentor did not meet with mentee for > 2 weeks
* Create a pod_flag if that's detected with a new `type` field
* Search for mentors with multiple pod_flags of the same type. To track mentor quality/consistency over time