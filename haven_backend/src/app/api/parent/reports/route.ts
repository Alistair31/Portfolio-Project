import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'
import { applyAnonymity } from '@/lib/anonymize'

export async function GET(request: Request) {
  const user = extractUser(request)
  if (!user || user.role !== 'PARENT') {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const links = await db.parentStudentLink.findMany({
    where: { parentId: user.id },
    select: { studentId: true },
  })

  const studentIds = links.map((l) => l.studentId)
  if (studentIds.length === 0) {
    return new Response(JSON.stringify([]), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const reports = await db.report.findMany({
    where:   { authorId: { in: studentIds } },
    select:  {
      id:           true,
      trackingCode: true,
      type:         true,
      gravity:      true,
      status:       true,
      anonymityLevel: true,
      createdAt:    true,
      author: { select: { name: true, className: true } },
      _count: { select: { followUps: true } },
    },
    orderBy: { createdAt: 'desc' },
  })

  const safe = reports.map((r) => ({
    ...r,
    author: applyAnonymity(r.author, r.anonymityLevel),
  }))

  return new Response(JSON.stringify(safe), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
}
