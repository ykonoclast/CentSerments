BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "dependance" (
    "lieu_dependant"    INTEGER UNIQUE,
    "lieu_superieur"    INTEGER,
    "relation_dependance"    INTEGER,
    PRIMARY KEY("lieu_dependant","lieu_superieur"),
    FOREIGN KEY("lieu_dependant") REFERENCES "lieu"("id_lieu"),
    FOREIGN KEY("lieu_superieur") REFERENCES "lieu"("id_lieu"),
    FOREIGN KEY("relation_dependance") REFERENCES "type_relation"("id_type_relation"),
    CONSTRAINT "chk_pas_autovassal" CHECK("lieu_dependant" <> "lieu_superieur")
);
CREATE TABLE IF NOT EXISTS "fief" (
    "titulaire_fief"    INTEGER,
    "lieu_fief"    INTEGER,
    PRIMARY KEY("titulaire_fief","lieu_fief"),
    FOREIGN KEY("lieu_fief") REFERENCES "lieu"("id_lieu"),
    FOREIGN KEY("titulaire_fief") REFERENCES "personne"("id_personne")
);
CREATE TABLE IF NOT EXISTS "lieu" (
	"id_lieu"	INTEGER,
	"nom_lieu_pendra"	TEXT NOT NULL COLLATE NOCASE,
	"nom_lieu_hp"	TEXT DEFAULT '' COLLATE NOCASE,
	"type_lieu"	INTEGER,
	"commentaire_lieu"	TEXT COLLATE NOCASE,
	PRIMARY KEY("id_lieu" AUTOINCREMENT),
	CONSTRAINT "unique_nom_type_hp" UNIQUE("nom_lieu_hp","type_lieu"),
	CONSTRAINT "unique_nom_type_pendra" UNIQUE("nom_lieu_pendra","type_lieu"),
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
	"prenom_pendra"	TEXT COLLATE NOCASE,
	"nom_pendra"	TEXT COLLATE NOCASE,
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
	"niveau_type_lieu"	INTEGER NOT NULL,
	PRIMARY KEY("id_type_lieu" AUTOINCREMENT),
	FOREIGN KEY("niveau_type_lieu") REFERENCES "niveau_lieu"("id_niveau")
);
CREATE TABLE IF NOT EXISTS "type_relation" (
	"id_type_relation"	INTEGER,
	"lbl_type_relation"	TEXT NOT NULL UNIQUE COLLATE NOCASE,
	PRIMARY KEY("id_type_relation" AUTOINCREMENT)
);
INSERT INTO "dependance" ("lieu_dependant","lieu_superieur","relation_dependance") VALUES (1,2,3),
 (2,6,3),
 (3,7,3),
 (4,7,3),
 (5,6,4);
INSERT INTO "fief" ("titulaire_fief","lieu_fief") VALUES (1,3),
 (2,1),
 (2,2),
 (3,4),
 (4,7);
INSERT INTO "lieu" ("id_lieu","nom_lieu_pendra","nom_lieu_hp","type_lieu","commentaire_lieu") VALUES (1,'Silchester','Silarasque',4,'Le comté, pas le duché'),
 (2,'Silchester','Silarasque',5,'Le duché, pas le comté, aussi connu sous le nom de "Duché de la Thoren" car court le long du fleuve'),
 (3,'Dirleton','Diralès',2,NULL),
 (4,'Stirling','Drol Ange',2,NULL),
 (5,'Sussex','Sunesque',7,NULL),
 (6,'Logres','Shandovra',6,NULL),
 (7,'Lothian','Sharoc',6,NULL);
INSERT INTO "niveau_lieu" ("id_niveau","lbl_niveau","val_niveau") VALUES (1,'Seigneurie',10),
 (2,'Baronnie',20),
 (3,'Vicomté',30),
 (4,'Comté',40),
 (5,'Duché',50),
 (6,'Royaume',60);
INSERT INTO "personne" ("id_personne","prenom_pendra","nom_pendra","prenom_hp","nom_hp","annee_majorite_max","majorite_certaine","annee_mort_max","mort_certaine","commentaire_personne") VALUES (1,'Lot',NULL,'Lothar','',470,1,513,1,'Plus âgé que dans Pendragon (naissance en 449 au lieu de 467)'),
 (2,'Ulfius',NULL,'Ulfius','',460,1,NULL,0,'insulte la reine en 512, donc encore en vie à ce moment-là'),
 (3,NULL,NULL,'Adelin','',470,1,479,1,'Exécuté par Rayya sur intrigue de Lothar'),
 (4,NULL,NULL,'Rayya','',465,1,NULL,0,NULL);
INSERT INTO "type_lieu" ("id_type_lieu","lbl_type_lieu","niveau_type_lieu") VALUES (1,'Seigneurie',1),
 (2,'Baronnie',2),
 (3,'Vicomté',3),
 (4,'Comté',4),
 (5,'Duché',5),
 (6,'Royaume',6),
 (7,'Thanat',5),
 (8,'Tuath (grand)',5),
 (9,'Tuath (petit)',4);
INSERT INTO "type_relation" ("id_type_relation","lbl_type_relation") VALUES (1,'vassal'),
 (2,'tributaire'),
 (3,'région ou subdivision'),
 (4,'de jure mais autonome');
CREATE VIEW v_lieux_orphelins AS
SELECT 
    l.nom_lieu_pendra,
    l.nom_lieu_hp,
    tl.lbl_type_lieu,
    CASE 
        WHEN f.lieu_fief IS NULL THEN 'SANS TITULAIRE'
        ELSE 'OK'
    END AS etat_titulaire,
    CASE 
        WHEN d.lieu_dependant IS NULL AND nl.val_niveau >= 60 THEN 'SOMMET (Royaume)'
        WHEN d.lieu_dependant IS NULL THEN 'SANS SUZERAIN'
        ELSE 'OK'
    END AS etat_hierarchie
FROM lieu l
JOIN type_lieu tl ON l.type_lieu = tl.id_type_lieu
JOIN niveau_lieu nl ON tl.niveau_type_lieu = nl.id_niveau
LEFT JOIN fief f ON l.id_lieu = f.lieu_fief
LEFT JOIN dependance d ON l.id_lieu = d.lieu_dependant
WHERE f.lieu_fief IS NULL 
   OR (d.lieu_dependant IS NULL AND nl.val_niveau < 60);
CREATE VIEW v_personnages AS
SELECT 
    p.prenom_hp,
    p.nom_hp,
    -- On regroupe les types et noms de fiefs pour éviter les doublons de lignes
    GROUP_CONCAT(tl.lbl_type_lieu || ' de ' || l.nom_lieu_hp, ', ') AS fiefs,
    (p.annee_majorite_max - 21) AS annee_naissance_calc,
    p.annee_majorite_max AS annee_majorite,
    p.majorite_certaine,
    p.annee_mort_max AS annee_mort,
    p.mort_certaine,
    p.commentaire_personne AS commentaire
FROM personne p
LEFT JOIN fief f ON p.id_personne = f.titulaire_fief
LEFT JOIN lieu l ON f.lieu_fief = l.id_lieu
LEFT JOIN type_lieu tl ON l.type_lieu = tl.id_type_lieu
GROUP BY p.id_personne;
CREATE VIEW v_politique AS
WITH FiefsComplets AS (
    SELECT 
        p.id_personne,
        -- Utilise le nom HP par défaut si le nom Pendragon est NULL
        COALESCE(p.prenom_hp, '') || ' ' || COALESCE(p.nom_hp, '') AS seigneur,
        tl.lbl_type_lieu AS type_fief,
        l.nom_lieu_hp AS fief,
        nl.lbl_niveau AS niveau_fief,
        nl.val_niveau,
        l_sup.nom_lieu_hp AS lieu_suzerain,
        tr.lbl_type_relation AS relation,
        (SELECT p_sup.prenom_hp || ' ' || p_sup.nom_hp 
         FROM fief f_sup
         JOIN personne p_sup ON f_sup.titulaire_fief = p_sup.id_personne
         WHERE f_sup.lieu_fief = d.lieu_superieur
         LIMIT 1) AS seigneur_suzerain
    FROM personne p
    JOIN fief f ON p.id_personne = f.titulaire_fief
    JOIN lieu l ON f.lieu_fief = l.id_lieu
    JOIN type_lieu tl ON l.type_lieu = tl.id_type_lieu
    JOIN niveau_lieu nl ON tl.niveau_type_lieu = nl.id_niveau
    LEFT JOIN dependance d ON l.id_lieu = d.lieu_dependant
    LEFT JOIN lieu l_sup ON d.lieu_superieur = l_sup.id_lieu
    LEFT JOIN type_relation tr ON d.relation_dependance = tr.id_type_relation
)
SELECT seigneur, type_fief, fief, niveau_fief, lieu_suzerain, relation, seigneur_suzerain
FROM FiefsComplets fc
WHERE fc.val_niveau = (
    SELECT MAX(val_niveau) 
    FROM FiefsComplets fc2 
    WHERE fc2.id_personne = fc.id_personne
);
CREATE VIEW v_stats_feodales AS
SELECT 
    nl.lbl_niveau AS Rang,
    COUNT(l.id_lieu) AS total_lieux,
    COUNT(f.lieu_fief) AS occupes,
    COUNT(l.id_lieu) - COUNT(f.lieu_fief) AS vacants,
    -- Calcul du pourcentage avec une sécurité pour éviter la division par zéro
    CASE 
        WHEN COUNT(l.id_lieu) = 0 THEN '0%'
        ELSE ROUND(CAST(COUNT(f.lieu_fief) AS FLOAT) / COUNT(l.id_lieu) * 100, 1) || '%' 
    END AS taux_occupation
FROM niveau_lieu nl
LEFT JOIN type_lieu tl ON nl.id_niveau = tl.niveau_type_lieu
LEFT JOIN lieu l ON tl.id_type_lieu = l.type_lieu
LEFT JOIN fief f ON l.id_lieu = f.lieu_fief
GROUP BY nl.id_niveau, nl.lbl_niveau, nl.val_niveau
ORDER BY nl.val_niveau DESC;
COMMIT;
