async function genericRequest(queryKey: string, params?: object) {
  const r = await fetch('/api/school_admin', {
    method: 'POST',
    body: JSON.stringify({ query: queryKey, ...params }),
    headers: {
      'Content-Type': 'application/json',
    },
  });
  const json = await r.json();
  return json;
}

export async function getCohorts() {
  return genericRequest('cohorts');
}

export async function getCohort(id: number | string) {
  return genericRequest('cohort', {
    id,
  });
}

export async function getCohortHighlights(id: number | string) {
  return genericRequest('cohort_highlights', {
    id,
  });
}

export async function myName() {
  return genericRequest('my_name');
}

export async function getStudent(id: number | string) {
  return genericRequest('student', {
    id,
  });
}

export async function getStudentTimeline(id: number | string, sort: 'asc' | 'desc', includePast: 'y' | 'n') {
  return genericRequest('timeline', {
    student_id: id,
    sort: sort || 'asc',
    includePast: includePast || 'n',
  });
}
export async function getStudentMilestones(id: string | number) {
  return genericRequest('milestones', {
    student_id: id,
  });
}

export async function getGeneralTimeline(
  cohortId: number | string,
  limit: number,
  sort: 'asc' | 'desc',
  includePast: 'y' | 'n'
) {
  return genericRequest('timeline', {
    cohort_id: cohortId,
    limit: limit || 0,
    sort: sort || 'asc',
    includePast: includePast || 'n',
  });
}
