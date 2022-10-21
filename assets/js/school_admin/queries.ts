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

export async function cohortsAndStudents() {
  return genericRequest('cohorts_and_students');
}

export async function getDashboard() {
  return genericRequest('dashboard');
}

export async function myName() {
  return genericRequest('my_name');
}

export async function numStudents() {
  return genericRequest('num_students');
}

export async function hoursMentored() {
  return genericRequest('hours_mentored');
}

export async function getStudentTimelineList() {
  return genericRequest('student_timeline_list');
}

export async function getStudentHighlights() {
  return genericRequest('student_highlights');
}

export async function getStudentHighlight(id?: number) {
  return genericRequest('student_highlights', { student_id: id });
}

export async function getStudent(id: number | string) {
  return genericRequest('student', {
    student_id: id,
  });
}

export async function getStudentTimeline(
  id: number | string,
  limit: number,
  sort: 'asc' | 'desc',
  includePast: 'y' | 'n'
) {
  return genericRequest('student_timeline', {
    student_id: id,
    limit: limit || 0,
    sort: sort || 'asc',
    includePast: includePast || 'n',
  });
}

export async function getGeneralTimeline(limit: number, sort: 'asc' | 'desc', includePast: 'y' | 'n') {
  return genericRequest('general_timeline', {
    limit: limit || 0,
    sort: sort || 'asc',
    includePast: includePast || 'n',
  });
}
