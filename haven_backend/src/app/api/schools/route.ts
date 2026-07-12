import { db } from '@/lib/db'

export async function GET() {
  try {
    const schools = await db.school.findMany({
      select: { code: true, name: true, type: true },
      orderBy: { name: 'asc' },
    })

    return new Response(JSON.stringify(schools), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('[GET /api/schools]', error)
    return new Response(JSON.stringify({ error: 'Database error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
}
