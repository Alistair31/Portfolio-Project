import { createHmac } from 'crypto'

interface ReportFields {
  id:            string
  type:          string
  gravity:       number
  mode:          string
  anonymityLevel: string
  description:   string
  createdAt:     Date
}

export function computeIntegrityHash(report: ReportFields): string {
  const secret = process.env.REPORT_INTEGRITY_SECRET
  if (!secret) throw new Error('REPORT_INTEGRITY_SECRET manquant dans .env')

  const payload = [
    report.id,
    report.type,
    String(report.gravity),
    report.mode,
    report.anonymityLevel,
    report.description,
    report.createdAt.toISOString(),
  ].join('|')

  return createHmac('sha256', secret).update(payload).digest('hex')
}
