
/*
# Copyright 2012, 2013 Jason R. Dobson <peakstogenes@gmail.com>
#
# This file is part of peaksToGenes.
#
# peaksToGenes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# peaksToGenes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>.
*/

DROP TABLE IF EXISTS upstream_number_of_peaks;
DROP TABLE IF EXISTS downstream_number_of_peaks;
DROP TABLE IF EXISTS transcript_number_of_peaks;
DROP TABLE IF EXISTS gene_body_number_of_peaks;
DROP TABLE IF EXISTS available_genomes;
DROP TABLE IF EXISTS transcripts;
DROP TABLE IF EXISTS experiments;
DROP TABLE IF EXISTS chromosome_sizes;
CREATE TABLE chromosome_sizes (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome_id INTEGER NOT NULL REFERENCES available_genomes(id) ON UPDATE CASCADE,
	chromosome_sizes_file TEXT NOT NULL UNIQUE
);
CREATE TABLE transcripts (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome_id INTEGER NOT NULL REFERENCES available_genomes(id) ON UPDATE CASCADE,
	transcript TEXT NOT NULL,
	UNIQUE (genome_id, transcript) ON CONFLICT REPLACE
);
CREATE TABLE experiments (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome_id INTEGER NOT NULL REFERENCES available_genomes(id) ON UPDATE CASCADE,
	experiment TEXT NOT NULL UNIQUE
);
CREATE TABLE upstream_number_of_peaks (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome_id INTEGER NOT NULL REFERENCES available_genomes(id) ON UPDATE CASCADE,
	name INTEGER NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
	gene INTEGER NOT NULL REFERENCES transcript(id) ON DELETE CASCADE,
	_10_Steps_Upstream_Number_of_Peaks REAL,
	_9_Steps_Upstream_Number_of_Peaks REAL,
	_8_Steps_Upstream_Number_of_Peaks REAL,
	_7_Steps_Upstream_Number_of_Peaks REAL,
	_6_Steps_Upstream_Number_of_Peaks REAL,
	_5_Steps_Upstream_Number_of_Peaks REAL,
	_4_Steps_Upstream_Number_of_Peaks REAL,
	_3_Steps_Upstream_Number_of_Peaks REAL,
	_2_Steps_Upstream_Number_of_Peaks REAL,
	_1_Steps_Upstream_Number_of_Peaks REAL
);
CREATE TABLE transcript_number_of_peaks (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome_id INTEGER NOT NULL REFERENCES available_genomes(id) ON UPDATE CASCADE,
	name INTEGER NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
	gene INTEGER NOT NULL REFERENCES transcript(id) ON DELETE CASCADE,
	_5Prime_UTR_Number_of_Peaks REAL,
	_Exons_Number_of_Peaks REAL,
	_Introns_Number_of_Peaks REAL,
	_3Prime_UTR_Number_of_Peaks REAL
);
CREATE TABLE gene_body_number_of_peaks (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome_id INTEGER NOT NULL REFERENCES available_genomes(id) ON UPDATE CASCADE,
	name INTEGER NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
	gene INTEGER NOT NULL REFERENCES transcript(id) ON DELETE CASCADE,
	_Gene_Body_0_to_10_Number_of_Peaks REAL,
	_Gene_Body_10_to_20_Number_of_Peaks REAL,
	_Gene_Body_20_to_30_Number_of_Peaks REAL,
	_Gene_Body_30_to_40_Number_of_Peaks REAL,
	_Gene_Body_40_to_50_Number_of_Peaks REAL,
	_Gene_Body_50_to_60_Number_of_Peaks REAL,
	_Gene_Body_60_to_70_Number_of_Peaks REAL,
	_Gene_Body_70_to_80_Number_of_Peaks REAL,
	_Gene_Body_80_to_90_Number_of_Peaks REAL,
	_Gene_Body_90_to_100_Number_of_Peaks REAL
);
CREATE TABLE downstream_number_of_peaks (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome_id INTEGER NOT NULL REFERENCES available_genomes(id) ON UPDATE CASCADE,
	name INTEGER NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
	gene INTEGER NOT NULL REFERENCES transcript(id) ON DELETE CASCADE,
	_1_Steps_Downstream_Number_of_Peaks REAL,
	_2_Steps_Downstream_Number_of_Peaks REAL,
	_3_Steps_Downstream_Number_of_Peaks REAL,
	_4_Steps_Downstream_Number_of_Peaks REAL,
	_5_Steps_Downstream_Number_of_Peaks REAL,
	_6_Steps_Downstream_Number_of_Peaks REAL,
	_7_Steps_Downstream_Number_of_Peaks REAL,
	_8_Steps_Downstream_Number_of_Peaks REAL,
	_9_Steps_Downstream_Number_of_Peaks REAL,
	_10_Steps_Downstream_Number_of_Peaks REAL
);
CREATE TABLE available_genomes (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome TEXT NOT NULL,
	_10_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_9_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_8_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_7_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_6_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_5_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_4_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_3_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_2_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_1_Steps_Upstream_Peaks_File TEXT NOT NULL,
	_5Prime_UTR_Peaks_File TEXT NOT NULL,
	_Exons_Peaks_File TEXT NOT NULL,
	_Introns_Peaks_File TEXT NOT NULL,
	_3Prime_UTR_Peaks_File TEXT NOT NULL,
	_Gene_Body_0_to_10_Peaks_File TEXT NOT NULL,
	_Gene_Body_10_to_20_Peaks_File TEXT NOT NULL,
	_Gene_Body_20_to_30_Peaks_File TEXT NOT NULL,
	_Gene_Body_30_to_40_Peaks_File TEXT NOT NULL,
	_Gene_Body_40_to_50_Peaks_File TEXT NOT NULL,
	_Gene_Body_50_to_60_Peaks_File TEXT NOT NULL,
	_Gene_Body_60_to_70_Peaks_File TEXT NOT NULL,
	_Gene_Body_70_to_80_Peaks_File TEXT NOT NULL,
	_Gene_Body_80_to_90_Peaks_File TEXT NOT NULL,
	_Gene_Body_90_to_100_Peaks_File TEXT NOT NULL,
	_1_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_2_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_3_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_4_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_5_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_6_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_7_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_8_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_9_Steps_Downstream_Peaks_File TEXT NOT NULL,
	_10_Steps_Downstream_Peaks_File TEXT NOT NULL,
    step_size INTEGER NOT NULL,
	UNIQUE (genome, step_size, _10_Steps_Upstream_Peaks_File, _9_Steps_Upstream_Peaks_File, _8_Steps_Upstream_Peaks_File, _7_Steps_Upstream_Peaks_File, _6_Steps_Upstream_Peaks_File, _5_Steps_Upstream_Peaks_File, _4_Steps_Upstream_Peaks_File, _3_Steps_Upstream_Peaks_File, _2_Steps_Upstream_Peaks_File, _1_Steps_Upstream_Peaks_File, _5Prime_UTR_Peaks_File, _Exons_Peaks_File, _Introns_Peaks_File, _3Prime_UTR_Peaks_File, _1_Steps_Downstream_Peaks_File, _2_Steps_Downstream_Peaks_File, _3_Steps_Downstream_Peaks_File, _4_Steps_Downstream_Peaks_File, _5_Steps_Downstream_Peaks_File, _6_Steps_Downstream_Peaks_File, _7_Steps_Downstream_Peaks_File, _8_Steps_Downstream_Peaks_File, _9_Steps_Downstream_Peaks_File, _10_Steps_Downstream_Peaks_File, _Gene_Body_0_to_10_Peaks_File, _Gene_Body_10_to_20_Peaks_File, _Gene_Body_20_to_30_Peaks_File, _Gene_Body_30_to_40_Peaks_File, _Gene_Body_40_to_50_Peaks_File, _Gene_Body_50_to_60_Peaks_File, _Gene_Body_60_to_70_Peaks_File, _Gene_Body_70_to_80_Peaks_File, _Gene_Body_80_to_90_Peaks_File, _Gene_Body_90_to_100_Peaks_File) ON CONFLICT REPLACE);
