export async function getDashboard() {
  const r = await fetch('/api/school_admin?query=dashboard', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  const json = await r.json();
  return json;
}

export async function getStudentTimelineList() {
  const r = await fetch('/api/school_admin?query=student_timeline_list', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  const json = await r.json();
  return json;
}
export async function getStudentHighlights() {
  const r = await fetch('/api/school_admin?query=student_highlights', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  const json = await r.json();
  return json;
}

export async function getStudentTimeline(
  id: number | string,
  limit: number,
  sort: 'asc' | 'desc',
  includePast: 'y' | 'n'
) {
  const r = await fetch('/api/school_admin?query=student_timeline&student_id=' + id, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  const json = await r.json();
  return json;
}

export async function getGeneralTimeline(limit: number, sort: 'asc' | 'desc', includePast: 'y' | 'n') {
  const r = await fetch('/api/school_admin', {
    method: 'POST',
    body: JSON.stringify({
      query: 'general_timeline',
      limit: limit,
      includePast: includePast,
      sort: sort,
    }),
    headers: {
      'Content-Type': 'application/json',
    },
  });
  const json = await r.json();
  return json;
}

export async function getStudent(id: number | string) {
  const r = await fetch('/api/school_admin?query=student&student_id=' + id, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  const json = await r.json();
  return json;
}
