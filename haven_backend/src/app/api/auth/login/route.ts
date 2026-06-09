import { z } from "zod"
import { db } from "@/lib/db"
import bcrypt from "bcryptjs"
import jwt from "jsonwebtoken"

export async function POST(request: Request) {
  const body = await request.json()
  const schema = z.object({
	email: z.string().email().max(100),
	password: z.string().min(6).max(100),
  })

  if (!process.env.JWT_SECRET) throw new Error("JWT_SECRET is not defined")

  const result = schema.safeParse(body)
  if (!result.success) {
	return new Response(JSON.stringify({ error: result.error.issues }), {
	  status: 400,
	  headers: { "Content-Type": "application/json" },
	})
  }
  const { email, password } = result.data

  try {
	const user = await db.user.findUnique({ where: { email } })
	if (!user) {
	  return new Response(JSON.stringify({ error: "Invalid email or password" }), {
		status: 401,
		headers: { "Content-Type": "application/json" },
	  })
	}
	const isPasswordValid = await bcrypt.compare(password, user.passwordHash)
	if (!isPasswordValid) {
	  return new Response(JSON.stringify({ error: "Invalid email or password" }), {
		status: 401,
		headers: { "Content-Type": "application/json" },
	  })
	}
	const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET!,
      { expiresIn: "7d" }
    )

	return new Response(JSON.stringify({ token, user: { id: user.id, email: user.email, name: user.name } }), {
	  status: 200,
	  headers: { "Content-Type": "application/json" },
	})
  } catch (error) {
	return new Response(JSON.stringify({ error: "Database error" }), {
	  status: 500,
	  headers: { "Content-Type": "application/json" },
	})
  }
}
