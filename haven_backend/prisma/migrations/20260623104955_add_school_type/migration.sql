-- CreateEnum
CREATE TYPE "SchoolType" AS ENUM ('COLLEGE', 'LYCEE', 'BTS_CPGE', 'MIXED');

-- AlterTable
ALTER TABLE "School" ADD COLUMN     "type" "SchoolType" NOT NULL DEFAULT 'MIXED';
