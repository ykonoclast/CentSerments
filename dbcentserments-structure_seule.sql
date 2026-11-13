BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "dependance" (
	"lieu_dependant"	INTEGER UNIQUE,
	"lieu_superieur"	INTEGER,
	"relation_dependance"	INTEGER,
	PRIMARY KEY("lieu_dependant","lieu_superieur"),
	FOREIGN KEY("lieu_dependant") REFERENCES "lieu"("id_lieu"),
	FOREIGN KEY("lieu_superieur") REFERENCES "lieu"("id_lieu"),
	FOREIGN KEY("relation_dependance") REFERENCES "type_relation"("id_type_relation"),
	CONSTRAINT "chk_pas_autovassal" CHECK("lieu_dependant" <> "lieu_superieur")
);
CREATE TABLE IF NOT EXISTS "fief" (
	"titulaire_fief"	INTEGER,
	"lieu_fief"	INTEGER,
	PRIMARY KEY("titulaire_fief","lieu_fief"),
	FOREIGN KEY("lieu_fief") REFERENCES "lieu"("id_lieu"),
	FOREIGN KEY("titulaire_fief") REFERENCES "personne"("id_personne")
);
CREATE TABLE IF NOT EXISTS "lieu" (
	"id_lieu"	INTEGER,
	"nom_lieu_pendra"	TEXT NOT NULL UNIQUE COLLATE NOCASE,
	"nom_lieu_hp"	TEXT UNIQUE COLLATE NOCASE,
	"type_lieu"	INTEGER,
	"commentaire_lieu"	TEXT COLLATE NOCASE,
	PRIMARY KEY("id_lieu" AUTOINCREMENT),
	FOREIGN KEY("type_lieu") REFERENCES "type_lieu"("id_type_lieu")
);
CREATE TABLE IF NOT EXISTS "niveau_lieu" (
	"id_niveau"	INTEGER,
	"lbl_niveau"	TEXT NOT NULL UNIQUE COLLATE NOCASE,
	"val_niveau"	INTEGER NOT NULL UNIQUE,
	PRIMARY KEY("id_niveau" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "personne" (
	"id_personne"	INTEGER,
	"prenom_pendra"	TEXT NOT NULL COLLATE NOCASE,
	"nom_pendra"	TEXT NOT NULL DEFAULT '' COLLATE NOCASE,
	"prenom_hp"	TEXT NOT NULL COLLATE NOCASE,
	"nom_hp"	TEXT NOT NULL DEFAULT '' COLLATE NOCASE,
	"annee_majorite_max"	INTEGER,
	"majorite_certaine"	INTEGER NOT NULL DEFAULT 0 CHECK("majorite_certaine" IN (0, 1)),
	"annee_mort_max"	INTEGER,
	"mort_certaine"	INTEGER NOT NULL DEFAULT 0 CHECK("mort_certaine" IN (0, 1)),
	"commentaire_personne"	TEXT COLLATE NOCASE,
	PRIMARY KEY("id_personne" AUTOINCREMENT),
	CONSTRAINT "unique_hp" UNIQUE("prenom_hp","nom_hp"),
	CONSTRAINT "unique_pendra" UNIQUE("prenom_pendra","nom_pendra")
);
CREATE TABLE IF NOT EXISTS "type_lieu" (
	"id_type_lieu"	INTEGER,
	"lbl_type_lieu"	TEXT NOT NULL UNIQUE COLLATE NOCASE,
	"niveau_type_lieu"	INTEGER,
	PRIMARY KEY("id_type_lieu" AUTOINCREMENT),
	FOREIGN KEY("niveau_type_lieu") REFERENCES "niveau_lieu"("id_niveau")
);
CREATE TABLE IF NOT EXISTS "type_relation" (
	"id_type_relation"	INTEGER,
	"lbl_type_relation"	TEXT NOT NULL UNIQUE COLLATE NOCASE,
	PRIMARY KEY("id_type_relation" AUTOINCREMENT)
);
CREATE VIEW v_test AS SELECT 1;
COMMIT;
