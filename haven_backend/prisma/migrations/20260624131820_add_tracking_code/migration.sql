/*
  Warnings:

  - A unique constraint covering the columns `[trackingCode]` on the table `Report` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `trackingCode` to the `Report` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Report" ADD COLUMN     "trackingCode" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Report_trackingCode_key" ON "Report"("trackingCode");
