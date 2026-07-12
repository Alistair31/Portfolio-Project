import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'
import { applyAnonymity } from '@/lib/anonymize'

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const user = extractUser(request)
  if (!user || user.role !== 'PARENT') {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { id } = await params

  const links = await db.parentStudentLink.findMany({
    where:  { parentId: user.id },
    select: { studentId: true },
  })
  const studentIds = links.map((l) => l.studentId)

  const report = await db.report.findUnique({
    where:  { id },
    select: {
      id:            true,
      trackingCode:  true,
      type:          true,
      gravity:       true,
      mode:          true,
      status:        true,
      description:   true,
      anonymityLevel: true,
      targetLevel:   true,
      createdAt:     true,
      authorId:      true,
      author: { select: { name: true, className: true } },
      followUps: {
        select: {
          id:        true,
          notes:     true,
          newStatus: true,
          createdAt: true,
          staff: { select: { role: true } },
        },
        orderBy: { createdAt: 'asc' },
      },
    },
  })

  if (!report || !studentIds.includes(report.authorId)) {
    return new Response(JSON.stringify({ error: 'Accès refusé' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const { authorId: _, ...safe } = report
  return new Response(JSON.stringify({
    ...safe,
    author: applyAnonymity(safe.author, safe.anonymityLevel),
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
}
