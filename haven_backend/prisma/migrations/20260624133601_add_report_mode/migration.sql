-- CreateEnum
CREATE TYPE "ReportMode" AS ENUM ('VICTIM', 'WITNESS');

-- AlterTable
ALTER TABLE "Report" ADD COLUMN     "mode" "ReportMode" NOT NULL DEFAULT 'VICTIM';
