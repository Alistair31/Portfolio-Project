import { db } from '@/lib/db'
import jwt from 'jsonwebtoken'

export async function DELETE(request: Request) {
  const authHeader = request.headers.get('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
	return new Response(JSON.stringify({ error: 'Unauthorized' }), {
	  status: 401,
	  headers: { 'Content-Type': 'application/json' },
	})
  }
  const token = authHeader.split(' ')[1]
	try {
		// Verify token
		const payload = jwt.verify(token,
			process.env.JWT_SECRET!) as {
				id?: string;
				sub?: string;
				role?: string
			}
		const userId = payload?.id ?? payload?.sub
		if (!userId) {
			return new Response(JSON.stringify({ error: 'Invalid token payload' }), {
				status: 401,
				headers: { 'Content-Type': 'application/json' },
			})
		}

		// Delete user account
		await db.user.delete({ where: { id: userId } })

		return new Response(JSON.stringify({ success: true }), {
			status: 200,
			headers: { 'Content-Type': 'application/json' },
		})
  } catch (error) {
	return new Response(JSON.stringify({ error: 'Invalid token' }), {
	  status: 401,
	  headers: { 'Content-Type': 'application/json' },
	})
  }
}
