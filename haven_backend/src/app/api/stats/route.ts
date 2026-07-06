import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'

const STAFF_ROLES = ['TEACHER', 'DIRECTOR_CPE', 'RECTORAT'] as const

export async function GET(request: Request) {
  const user = extractUser(request)
  if (!user) {
    return new Response(JSON.stringify({ error: 'Non autorisé' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  if (!STAFF_ROLES.includes(user.role as (typeof STAFF_ROLES)[number])) {
    return new Response(JSON.stringify({ error: 'Accès refusé' }), {
      status: 403,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const isRectorat = user.role === 'RECTORAT'

    let schoolCode: string | undefined
    if (!isRectorat) {
      const staffUser = await db.user.findUnique({
        where: { id: user.id },
        select: { schoolCode: true },
      })
      schoolCode = staffUser?.schoolCode
    }

    const reports = await db.report.findMany({
      where: isRectorat
        ? {}
        : {
            author: { schoolCode },
            // Le niveau (prof / direction) voit ses signalements + ceux qu'il a
            // transférés au Rectorat (qui restent dans SES stats malgré l'escalade).
            OR: [
              { targetLevel: user.role as 'TEACHER' | 'DIRECTOR_CPE' },
              { escalatedFromLevel: user.role as 'TEACHER' | 'DIRECTOR_CPE' },
            ],
          },
      select: {
        status:  true,
        type:    true,
        gravity: true,
        author:  { select: { schoolCode: true } },
      },
    })

    const total = reports.length
    const byStatus:  Record<string, number> = { PENDING: 0, IN_PROGRESS: 0, CLOSED: 0 }
    const byType:    Record<string, number> = { PHYSICAL: 0, VERBAL: 0, SEXUAL: 0, CYBER: 0, OTHER: 0 }
    const byGravity: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
    const schoolMap: Record<string, { total: number; pending: number; inProgress: number; closed: number }> = {}

    for (const r of reports) {
      byStatus[r.status]   = (byStatus[r.status]   ?? 0) + 1
      byType[r.type]       = (byType[r.type]       ?? 0) + 1
      byGravity[r.gravity] = (byGravity[r.gravity] ?? 0) + 1

      if (isRectorat) {
        const sc = r.author.schoolCode
        if (!schoolMap[sc]) schoolMap[sc] = { total: 0, pending: 0, inProgress: 0, closed: 0 }
        schoolMap[sc].total++
        if (r.status === 'PENDING')     schoolMap[sc].pending++
        else if (r.status === 'IN_PROGRESS') schoolMap[sc].inProgress++
        else                            schoolMap[sc].closed++
      }
    }

    const resolutionRate = total > 0 ? Math.round((byStatus['CLOSED'] / total) * 100) / 100 : 0

    const bySchool = isRectorat
      ? Object.entries(schoolMap).map(([sc, counts]) => ({ schoolCode: sc, ...counts }))
      : undefined

    return new Response(
      JSON.stringify({
        total,
        resolutionRate,
        byStatus,
        byType,
        byGravity,
        ...(bySchool !== undefined && { bySchool }),
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    console.error('[GET /api/stats]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
