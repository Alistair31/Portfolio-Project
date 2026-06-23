import 'dotenv/config'
import { PrismaClient } from '../src/generated/prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })
const db = new PrismaClient({ adapter })

async function main() {
  const schools = [
    { code: 'LYC-SJL-31', name: 'Lycée Saint Joseph La Salle — Toulouse',        type: 'LYCEE'    as const },
    { code: 'CLG-SJL-31', name: 'Collège Saint Joseph La Salle — Toulouse',       type: 'COLLEGE'  as const },
    { code: 'CLG-ROC-31', name: 'Lycée (étude supérieur) Saint Joseph La Salle',  type: 'BTS_CPGE' as const },
    { code: 'TEST-001',   name: 'Établissement de test',                           type: 'MIXED'    as const },
  ]

  const codes = schools.map(s => s.code)
  await db.school.deleteMany({ where: { code: { notIn: codes } } })

  for (const school of schools) {
    await db.school.upsert({
      where: { code: school.code },
      update: { name: school.name, type: school.type },
      create: school,
    })
  }

  console.log(`Seed terminé : ${schools.length} établissements.`)
}

main()
  .catch(console.error)
  .finally(() => db.$disconnect())
