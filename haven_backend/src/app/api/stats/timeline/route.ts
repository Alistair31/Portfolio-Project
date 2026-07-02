import { db } from '@/lib/db'
import { extractUser } from '@/lib/auth'
import { Prisma } from '@/generated/prisma/client'

const STAFF_ROLES = ['TEACHER', 'DIRECTOR_CPE', 'RECTORAT'] as const
type Period = 'week' | 'month' | 'year'

const JOURS = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
const MOIS  = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc']

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
    const { searchParams } = new URL(request.url)
    const periodParam = searchParams.get('period') ?? 'week'
    const period: Period = (['week', 'month', 'year'] as const).includes(periodParam as Period)
      ? (periodParam as Period)
      : 'week'

    const isRectorat = user.role === 'RECTORAT'

    let schoolCode: string | undefined
    if (!isRectorat) {
      const staffUser = await db.user.findUnique({
        where:  { id: user.id },
        select: { schoolCode: true },
      })
      schoolCode = staffUser?.schoolCode
    }

    // Chaque période définit la granularité SQL et la fenêtre temporelle
    const config = {
      week:  { trunc: 'day',   days: 7   },
      month: { trunc: 'week',  days: 35  },
      year:  { trunc: 'month', days: 365 },
    }[period]

    // Date de début calculée en JS — évite Prisma.raw et les problèmes d'adaptateur
    const since = new Date(Date.now() - config.days * 24 * 60 * 60 * 1000)

    // Filtres conditionnels : RECTORAT voit tout, les autres voient leur école + leur targetLevel
    const roleFilter   = isRectorat ? Prisma.empty : Prisma.sql`AND r."targetLevel" = ${user.role}`
    const schoolJoin   = isRectorat ? Prisma.empty : Prisma.sql`INNER JOIN "User" u ON u.id = r."authorId"`
    const schoolFilter = isRectorat ? Prisma.empty : Prisma.sql`AND u."schoolCode" = ${schoolCode}`

    // DATE_TRUNC regroupe les signalements par jour / semaine / mois
    // COUNT(*)::int convertit le bigint PostgreSQL en int JS
    const rows = await db.$queryRaw<{ period: Date; count: number }[]>(
      Prisma.sql`
        SELECT DATE_TRUNC(${config.trunc}, r."createdAt") AS period,
               COUNT(*)::int                              AS count
        FROM   "Report" r
        ${schoolJoin}
        WHERE  r."createdAt" >= ${since}
        ${roleFilter}
        ${schoolFilter}
        GROUP  BY period
        ORDER  BY period ASC
      `
    )

    // Lookup ISO-date → count pour le gap-filling
    const lookup = new Map(
      rows.map(r => [new Date(r.period).toISOString().slice(0, 10), Number(r.count)])
    )

    const now = new Date()
    const points: { label: string; count: number }[] = []

    if (period === 'week') {
      // 7 derniers jours, un point par jour
      for (let i = 6; i >= 0; i--) {
        const d = new Date(now)
        d.setDate(d.getDate() - i)
        const key = d.toISOString().slice(0, 10)
        points.push({ label: JOURS[d.getDay()], count: lookup.get(key) ?? 0 })
      }
    } else if (period === 'month') {
      // 5 dernières semaines, un point par lundi (DATE_TRUNC('week') retourne le lundi en PG)
      for (let i = 4; i >= 0; i--) {
        const d = new Date(now)
        d.setDate(d.getDate() - i * 7)
        const day = d.getDay()
        d.setDate(d.getDate() + (day === 0 ? -6 : 1 - day))
        d.setHours(0, 0, 0, 0)
        const key = d.toISOString().slice(0, 10)
        points.push({ label: `${d.getDate()}/${d.getMonth() + 1}`, count: lookup.get(key) ?? 0 })
      }
    } else {
      // 12 derniers mois, un point par mois
      for (let i = 11; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
        const key = d.toISOString().slice(0, 10)
        points.push({ label: MOIS[d.getMonth()], count: lookup.get(key) ?? 0 })
      }
    }

    return new Response(JSON.stringify(points), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[GET /api/stats/timeline]', error)
    return new Response(JSON.stringify({ error: 'Erreur serveur' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
