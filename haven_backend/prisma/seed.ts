import 'dotenv/config'
import { PrismaClient } from '../src/generated/prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'
import bcrypt from 'bcryptjs'

// Même driver que l'app : connexion via l'adaptateur PrismaPg (obligatoire avec Neon/Supabase)
const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })
const db = new PrismaClient({ adapter })

// ---------------------------------------------------------------------------
// Établissements
// ---------------------------------------------------------------------------

const schools = [
  { code: 'LYC-SJL-31', name: 'Lycée Saint Joseph La Salle — Toulouse',       type: 'LYCEE'    as const },
  { code: 'CLG-SJL-31', name: 'Collège Saint Joseph La Salle — Toulouse',      type: 'COLLEGE'  as const },
  { code: 'CLG-ROC-31', name: 'Lycée (étude supérieur) Saint Joseph La Salle', type: 'BTS_CPGE' as const },
  { code: 'TEST-001',   name: 'Établissement de test',                          type: 'MIXED'    as const },
]

// ---------------------------------------------------------------------------
// Comptes staff — mot de passe lu depuis .env pour ne jamais hardcoder
// SEED_STAFF_PASSWORD doit être défini dans haven_backend/.env
// ---------------------------------------------------------------------------

// Les comptes staff sont définis ici et synchronisés à chaque seed.
// className est vide pour le staff (champ obligatoire en base mais sans sens pour eux).
const staffAccounts = [
  // Lycée
  { email: 'prof.lyc@placeholder.fr',  name: 'M. Dupont (Lycée)',  role: 'TEACHER'      as const, schoolCode: 'LYC-SJL-31' },
  { email: 'cpe.lyc@placeholder.fr',   name: 'Mme Martin (Lycée)', role: 'DIRECTOR_CPE' as const, schoolCode: 'LYC-SJL-31' },
  // Collège
  { email: 'prof.clg@placeholder.fr',  name: 'M. Bernard (CLG)',   role: 'TEACHER'      as const, schoolCode: 'CLG-SJL-31' },
  { email: 'cpe.clg@placeholder.fr',   name: 'Mme Petit (CLG)',    role: 'DIRECTOR_CPE' as const, schoolCode: 'CLG-SJL-31' },
  // BTS / CPGE
  { email: 'prof.bts@placeholder.fr',  name: 'M. Moreau (BTS)',    role: 'TEACHER'      as const, schoolCode: 'CLG-ROC-31' },
  // Rectorat — rattaché à un établissement arbitraire (schoolCode peu pertinent pour ce rôle)
  { email: 'rectorat@placeholder.fr',  name: 'Rectorat Toulouse',  role: 'RECTORAT'     as const, schoolCode: 'LYC-SJL-31' },
  // Compte de test multi-rôle
  { email: 'test.staff@placeholder.fr', name: 'Staff Test',        role: 'TEACHER'      as const, schoolCode: 'TEST-001'   },
]

// ---------------------------------------------------------------------------

async function main() {
  // --- Établissements ---
  // Supprime les écoles absentes de la liste (garde la cohérence si on retire un établissement)
  const codes = schools.map(s => s.code)
  await db.school.deleteMany({ where: { code: { notIn: codes } } })

  for (const school of schools) {
    await db.school.upsert({
      where:  { code: school.code },
      update: { name: school.name, type: school.type },
      create: school,
    })
  }
  console.log(`✓ ${schools.length} établissements synchronisés.`)

  // --- Comptes staff ---
  // Le mot de passe par défaut est lu depuis .env pour éviter tout hardcoding.
  // Si la variable est absente, le seed échoue explicitement plutôt que silencieusement.
  const rawPassword = process.env.SEED_STAFF_PASSWORD
  if (!rawPassword) {
    throw new Error('SEED_STAFF_PASSWORD est absent du fichier .env')
  }

  // bcrypt.hash(password, saltRounds) : saltRounds = 10 est le standard recommandé
  // (compromis entre sécurité et temps de calcul)
  const passwordHash = await bcrypt.hash(rawPassword, 10)

  for (const staff of staffAccounts) {
    await db.user.upsert({
      where:  { email: staff.email },
      // Ne met à jour que le nom et le rôle, pas le mot de passe
      // (permet de changer le mdp manuellement sans qu'un seed l'écrase)
      update: { name: staff.name, role: staff.role, schoolCode: staff.schoolCode },
      create: {
        email:        staff.email,
        name:         staff.name,
        role:         staff.role,
        schoolCode:   staff.schoolCode,
        className:    '', // non applicable pour le staff
        passwordHash,
      },
    })
  }
  console.log(`✓ ${staffAccounts.length} comptes staff synchronisés.`)
}

main()
  .catch(console.error)
  .finally(() => db.$disconnect())
