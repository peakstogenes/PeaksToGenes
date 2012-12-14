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
	transcript TEXT NOT NULL
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
	_10Kb_Upstream_Number_of_Peaks REAL,
	_9Kb_Upstream_Number_of_Peaks REAL,
	_8Kb_Upstream_Number_of_Peaks REAL,
	_7Kb_Upstream_Number_of_Peaks REAL,
	_6Kb_Upstream_Number_of_Peaks REAL,
	_5Kb_Upstream_Number_of_Peaks REAL,
	_4Kb_Upstream_Number_of_Peaks REAL,
	_3Kb_Upstream_Number_of_Peaks REAL,
	_2Kb_Upstream_Number_of_Peaks REAL,
	_1Kb_Upstream_Number_of_Peaks REAL
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
	_1Kb_Downstream_Number_of_Peaks REAL,
	_2Kb_Downstream_Number_of_Peaks REAL,
	_3Kb_Downstream_Number_of_Peaks REAL,
	_4Kb_Downstream_Number_of_Peaks REAL,
	_5Kb_Downstream_Number_of_Peaks REAL,
	_6Kb_Downstream_Number_of_Peaks REAL,
	_7Kb_Downstream_Number_of_Peaks REAL,
	_8Kb_Downstream_Number_of_Peaks REAL,
	_9Kb_Downstream_Number_of_Peaks REAL,
	_10Kb_Downstream_Number_of_Peaks REAL
);
CREATE TABLE available_genomes (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	genome TEXT NOT NULL,
	_10Kb_Upstream_Peaks_File TEXT NOT NULL,
	_9Kb_Upstream_Peaks_File TEXT NOT NULL,
	_8Kb_Upstream_Peaks_File TEXT NOT NULL,
	_7Kb_Upstream_Peaks_File TEXT NOT NULL,
	_6Kb_Upstream_Peaks_File TEXT NOT NULL,
	_5Kb_Upstream_Peaks_File TEXT NOT NULL,
	_4Kb_Upstream_Peaks_File TEXT NOT NULL,
	_3Kb_Upstream_Peaks_File TEXT NOT NULL,
	_2Kb_Upstream_Peaks_File TEXT NOT NULL,
	_1Kb_Upstream_Peaks_File TEXT NOT NULL,
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
	_1Kb_Downstream_Peaks_File TEXT NOT NULL,
	_2Kb_Downstream_Peaks_File TEXT NOT NULL,
	_3Kb_Downstream_Peaks_File TEXT NOT NULL,
	_4Kb_Downstream_Peaks_File TEXT NOT NULL,
	_5Kb_Downstream_Peaks_File TEXT NOT NULL,
	_6Kb_Downstream_Peaks_File TEXT NOT NULL,
	_7Kb_Downstream_Peaks_File TEXT NOT NULL,
	_8Kb_Downstream_Peaks_File TEXT NOT NULL,
	_9Kb_Downstream_Peaks_File TEXT NOT NULL,
	_10Kb_Downstream_Peaks_File TEXT NOT NULL,
	UNIQUE (genome, _10Kb_Upstream_Peaks_File, _9Kb_Upstream_Peaks_File, _8Kb_Upstream_Peaks_File, _7Kb_Upstream_Peaks_File, _6Kb_Upstream_Peaks_File, _5Kb_Upstream_Peaks_File, _4Kb_Upstream_Peaks_File, _3Kb_Upstream_Peaks_File, _2Kb_Upstream_Peaks_File, _1Kb_Upstream_Peaks_File, _5Prime_UTR_Peaks_File, _Exons_Peaks_File, _Introns_Peaks_File, _3Prime_UTR_Peaks_File, _1Kb_Downstream_Peaks_File, _2Kb_Downstream_Peaks_File, _3Kb_Downstream_Peaks_File, _4Kb_Downstream_Peaks_File, _5Kb_Downstream_Peaks_File, _6Kb_Downstream_Peaks_File, _7Kb_Downstream_Peaks_File, _8Kb_Downstream_Peaks_File, _9Kb_Downstream_Peaks_File, _10Kb_Downstream_Peaks_File, _Gene_Body_0_to_10_Peaks_File, _Gene_Body_10_to_20_Peaks_File, _Gene_Body_20_to_30_Peaks_File, _Gene_Body_30_to_40_Peaks_File, _Gene_Body_40_to_50_Peaks_File, _Gene_Body_50_to_60_Peaks_File, _Gene_Body_60_to_70_Peaks_File, _Gene_Body_70_to_80_Peaks_File, _Gene_Body_80_to_90_Peaks_File, _Gene_Body_90_to_100_Peaks_File) ON CONFLICT REPLACE
);
