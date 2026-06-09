import { z } from "zod"
import { db } from "@/lib/db"
import bcrypt from "bcryptjs"

export async function POST(request: Request) {
  const body = await request.json()

  const schema = z.object({
    email: z.string().email().max(100),
    password: z.string().min(6).max(100),
    name: z.string().min(2).max(50),
    className: z.string().min(1).max(50),
  })

  const result = schema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({ error: result.error.issues }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }

  const { email, password, name, className } = result.data

  try {
    const existingUser = await db.user.findUnique({ where: { email } })
    if (!existingUser) {
      const hashedPassword = await bcrypt.hash(password, 10)
      await db.user.create({
        data: { email, passwordHash: hashedPassword, name, className, role: "STUDENT" },
      })
    }
    return new Response(
      JSON.stringify({ message: "Si cet email n'est pas enregistré, un compte a été créé." }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: "Database error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
}