-- ****************************************************************************************************************************
-- suppression des tables
-- ****************************************************************************************************************************
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'schema_ins_piste') LOOP
		RAISE NOTICE 'Supprime la TABLE %', quote_ident(r.tablename);
        EXECUTE 'DROP TABLE IF EXISTS schema_ins_piste.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- ****************************************************************************************************************************
-- Collection dossiers_inscription 
-- ****************************************************************************************************************************

/* *************
    apprenant
*/

-- creation de la table au préalable
create table schema_ins_piste.apprenant (
    code_apprenant varchar,
	est_primo boolean,
    nom_famille varchar,
    nom_usuel varchar,
    prenom varchar,
    prenom2 varchar,
    prenom3 varchar,
    sexe varchar,
    date_naissance date,
    code_pays_naissance varchar,
    code_commune_naissance varchar,
    libelle_commune_naissance varchar,
    libelle_commune_naissance_etranger varchar,
    code_nationalite varchar,
    code_nationalite2 varchar,
    date_obtention_nationalite2 date,
    annee_obtention_bac integer,
    code_type_ou_serie_bac varchar,
    code_mention_bac varchar,
    type_etablissement_bac varchar,
    code_pays_bac varchar,
    code_departement_bac varchar,
    code_etablissement_bac varchar,
    etablissement_libre_bac varchar,
    precisions_titre_dispense_bac varchar,
    ine varchar,
    annee_entree_enseignement_superieur integer,
    annee_entree_universite integer,
    annee_entree_etablissement integer,
    code_categorie_socioprofessionnelle varchar,
    code_quotite_travaillee varchar,
    code_categorie_socioprofessionnelle_parent1 varchar,
    code_categorie_socioprofessionnelle_parent2 varchar,
    code_situation_familiale varchar,
    nombre_enfants integer,
    code_situation_militaire varchar,
    date_creation timestamp,
    date_modification timestamp,
    code_premiere_specialite_bac varchar,
    code_deuxieme_specialite_bac varchar,
    statut_ine varchar,
    date_derniere_verification_ine timestamp,
    code_erreur_ine varchar,
    message_erreur_ine varchar,
    temoin_neo_bachelier boolean,
    
    source_json JSONB);


-- recopie du JSON
insert into schema_ins_piste.apprenant (source_json)
select source_json from mongo_piste_inscription.dossiers_inscription;

-- extraction des id
update schema_ins_piste.apprenant 
set 
    code_apprenant = source_json->'apprenant'->'codeApprenant'->>'value',
	est_primo = (source_json->>'estPrimo')::boolean,
    nom_famille = source_json->'apprenant'->'etatCivil'->'nomDeNaissance'->>'value',
    nom_usuel = source_json->'apprenant'->'etatCivil'->'nomUsuel'->>'value',
    prenom = source_json->'apprenant'->'etatCivil'->'prenom'->>'value',
    prenom2 = source_json->'apprenant'->'etatCivil'->'deuxiemePrenom'->>'value',
    prenom3 = source_json->'apprenant'->'etatCivil'->'troisiemePrenom'->>'value',
    sexe = source_json->'apprenant'->'etatCivil'->>'genre',
    date_naissance = CASE  
		WHEN (source_json->'apprenant'->'etatCivil'->'dateDeNaissance'->'value'->>'$date') LIKE '%numberLong%' THEN NULL::date
		ELSE (source_json->'apprenant'->'etatCivil'->'dateDeNaissance'->'value'->>'$date')::date
	END,
    code_pays_naissance = source_json->'apprenant'->'etatCivil'->'paysDeNaissance'->>'code',
    code_commune_naissance = source_json->'apprenant'->'etatCivil'->'communeDeNaissance'->>'code',
    libelle_commune_naissance = source_json->'apprenant'->'etatCivil'->'communeDeNaissance'->>'libelle',
    libelle_commune_naissance_etranger = source_json->'apprenant'->'etatCivil'->'communeDeNaissanceEtranger'->>'value',
    code_nationalite = source_json->'apprenant'->'etatCivil'->'nationalite'->>'code',
    --code_nationalite2 varchar,
    --date_obtention_nationalite2 date,
    annee_obtention_bac = (source_json->'apprenant'->'bac'->>'anneeObtention')::integer,
    code_type_ou_serie_bac = source_json->'apprenant'->'bac'->'serie'->>'code',
    code_mention_bac = source_json->'apprenant'->'bac'->'mention'->>'code',
    type_etablissement_bac = CASE  
		WHEN source_json->'apprenant'->'bac'->'etablissement'->>'type'='ETABLISSEMENT_FRANCAIS' THEN 'F'
		WHEN source_json->'apprenant'->'bac'->'etablissement'->>'type' IS NULL THEN NULL
		ELSE 'E'
	END,
    code_pays_bac = source_json->'apprenant'->'bac'->'etablissement'->'pays'->>'code',
    code_departement_bac = source_json->'apprenant'->'bac'->'etablissement'->'departement'->>'code',
    code_etablissement_bac = source_json->'apprenant'->'bac'->'etablissement'->>'numeroUai',
    etablissement_libre_bac = source_json->'apprenant'->'bac'->'etablissementLibre'->>'saisieLibre',
    --precisions_titre_dispense_bac varchar,
    ine = source_json->'apprenant'->'ine'->>'value',
    annee_entree_enseignement_superieur = (source_json->'apprenant'->'premieresInscriptions'->>'anneeEnseignementSuperieur')::integer,
    annee_entree_universite = (source_json->'apprenant'->'premieresInscriptions'->>'anneeUniversitaire')::integer,
    annee_entree_etablissement = (source_json->'apprenant'->'premieresInscriptions'->>'anneeEtablissement')::integer,
    code_categorie_socioprofessionnelle = source_json->'apprenant'->'profession'->>'code',
    code_quotite_travaillee = source_json->'apprenant'->'quotite'->>'code',
    code_categorie_socioprofessionnelle_parent1 = source_json->'apprenant'->'parent1'->>'code',
    code_categorie_socioprofessionnelle_parent2 = source_json->'apprenant'->'parent2'->>'code',
    code_situation_familiale = source_json->'apprenant'->'situationPersonnelle'->'situationFamiliale'->>'code',
    nombre_enfants = (source_json->'apprenant'->'situationPersonnelle'->>'nbrEnfants')::integer,
    code_situation_militaire = source_json->'apprenant'->'situationPersonnelle'->'situationMilitaire'->>'code',
    --date_creation timestamp,
    --date_modification timestamp,
    code_premiere_specialite_bac = source_json->'apprenant'->'bac'->'specialiteBac1'->>'code',
    code_deuxieme_specialite_bac = source_json->'apprenant'->'bac'->'specialiteBac2'->>'code',
    statut_ine = source_json->'apprenant'->'ine'->>'statutIne',
    --date_derniere_verification_ine timestamp,
    --code_erreur_ine varchar,
    --message_erreur_ine varchar, 
    temoin_neo_bachelier = (source_json->>'temoinNeoBachelier')::boolean
    ;
--select * from schema_ins_piste.apprenant;






/* *************
    contacts
*/

-- creation de la table au préalable
CREATE TABLE schema_ins_piste.contact_courriel AS
    SELECT
        code_apprenant,
        NULL::varchar AS "code_type_contact",
        NULL::varchar AS "courriel",

        source_json_contacts
    FROM schema_ins_piste.apprenant,        
        jsonb_array_elements(source_json->'apprenant'->'contacts'->'courriels') AS source_json_contacts;

-- extraction des valeurs
update schema_ins_piste.contact_courriel 
set 
    code_type_contact = source_json_contacts->'demandeContact'->>'code',
	courriel = source_json_contacts->>'courriel'
    
    ;
--select * from schema_ins_piste.contact_courriel;





-- creation de la table au préalable
CREATE TABLE schema_ins_piste.contact_adresse_postale AS
    SELECT
        code_apprenant,
        NULL::varchar AS "code_type_contact",
        NULL::varchar AS "code_postal",
        --NULL::varchar AS "code_commune",
        NULL::varchar AS "code_pegase_commune",
        NULL::varchar AS "libelle_commune",
        NULL::varchar AS "ligne1_ou_etage",
        NULL::varchar AS "ligne2_ou_batiment",
        NULL::varchar AS "ligne3_ou_voie",
        NULL::varchar AS "ligne4_ou_complement",
        NULL::varchar AS "ligne5_etranger",
        NULL::varchar AS "code_pays",
        NULL::varchar AS "libelle_pays",

        source_json_contacts
    FROM schema_ins_piste.apprenant,        
        jsonb_array_elements(source_json->'apprenant'->'contacts'->'adressesPostales') AS source_json_contacts;

-- extraction des valeurs
update schema_ins_piste.contact_adresse_postale 
set 
    code_type_contact = source_json_contacts->'demandeContact'->>'code',
	code_postal = source_json_contacts->>'codePostal',
	--code_commune = source_json_contacts->>'commune',
	code_pegase_commune = source_json_contacts->>'codePegaseCommune',
	libelle_commune = source_json_contacts->>'commune',
	ligne1_ou_etage = source_json_contacts->>'ligne1OuEtage',
	ligne2_ou_batiment = source_json_contacts->>'ligne2OuBatiment',
	ligne3_ou_voie = source_json_contacts->>'ligne3OuVoie',
	ligne4_ou_complement = source_json_contacts->>'ligne4OuComplement',
	ligne5_etranger = source_json_contacts->>'ligne5OuEtranger',
	code_pays = source_json_contacts->>'pays'
	--libelle_pays = source_json_contacts->'demandeContact'->>'code'	
    ;
--select * from schema_ins_piste.contact_adresse_postale;






-- creation de la table au préalable
CREATE TABLE schema_ins_piste.contact_numero_telephone AS
    SELECT
        code_apprenant,
        NULL::varchar AS "code_type_contact",
        NULL::varchar AS "telephone",

        source_json_contacts
    FROM schema_ins_piste.apprenant,        
        jsonb_array_elements(source_json->'apprenant'->'contacts'->'numerosDeTelephone') AS source_json_contacts;

-- extraction des valeurs
update schema_ins_piste.contact_numero_telephone 
set 
    code_type_contact = source_json_contacts->'demandeContact'->>'code',
	telephone = source_json_contacts->>'telephone'
    
    ;
--select * from schema_ins_piste.contact_numero_telephone;










-- creation de la table au préalable
CREATE TABLE schema_ins_piste.contact AS
(SELECT code_apprenant,
	code_type_contact AS "type",
    'ADRESSE ELECTRONIQUE' AS "libelle_type",
	courriel AS "mail",
	NULL AS "telephone",
	NULL AS "code_postal",
	NULL AS "code_commune",
	NULL AS "libelle_commune",
	NULL AS "ligne1_ou_etage",
	NULL AS "ligne2_ou_batiment",
	NULL AS "ligne3_ou_voie",
	NULL AS "ligne4_ou_complement",
	NULL AS "ligne5_etranger",
	NULL AS "code_pays",
	NULL AS "libelle_pays"
	
	FROM schema_ins_piste.contact_courriel
	
	WHERE courriel IS NOT NULL)
	
UNION

(SELECT code_apprenant,
	code_type_contact AS "type",
    'N° DE TELEPHONE' AS "libelle_type",
	NULL AS "mail",
	telephone AS "telephone",
	NULL AS "code_postal",
	NULL AS "code_commune",
	NULL AS "libelle_commune",
	NULL AS "ligne1_ou_etage",
	NULL AS "ligne2_ou_batiment",
	NULL AS "ligne3_ou_voie",
	NULL AS "ligne4_ou_complement",
	NULL AS "ligne5_etranger",
	NULL AS "code_pays",
	NULL AS "libelle_pays"
	
	FROM schema_ins_piste.contact_numero_telephone
	
	WHERE telephone IS NOT NULL)
	
UNION


(SELECT code_apprenant,
	code_type_contact AS "type",
    'ADRESSE POSTALE' AS "libelle_type",
	NULL AS "mail",
	NULL AS "telephone",
	schema_ref.commune.code_postal AS "code_postal",
	schema_ref.commune.code_insee AS "code_commune",
	schema_ref.commune.libelle_long AS "libelle_commune",
	ligne1_ou_etage AS "ligne1_ou_etage",
	ligne2_ou_batiment AS "ligne2_ou_batiment",
	ligne3_ou_voie AS "ligne3_ou_voie",
	ligne4_ou_complement AS "ligne4_ou_complement",
	ligne5_etranger AS "ligne5_etranger",
	code_pays AS "code_pays",
	P1.libelle_long AS "libelle_pays"
	
	FROM schema_ins_piste.contact_adresse_postale
	
	LEFT JOIN schema_ref.pays_nationalite P1 ON P1.code = contact_adresse_postale.code_pays
	LEFT JOIN schema_ref.commune ON schema_ref.commune.code = contact_adresse_postale.code_pegase_commune
	
	WHERE contact_adresse_postale.code_postal IS NOT NULL OR code_pegase_commune IS NOT NULL OR ligne1_ou_etage IS NOT NULL OR ligne2_ou_batiment IS NOT NULL OR ligne3_ou_voie IS NOT NULL OR ligne4_ou_complement IS NOT NULL OR ligne5_etranger IS NOT NULL OR code_pays IS NOT NULL);

--select * from schema_ins_piste.contact;
   
   
   






-- creation de la table
CREATE TABLE schema_ins_piste.contacts AS
 SELECT contact.code_apprenant,
    max(contact.mail) filter (where type = 'MEL-001') as "mail_perso",
    max(contact.mail) filter (where type = 'MEL-002') as "mail_secours",
    
    max(telephone) filter (where type = 'TEL-002') as "telephone_perso",
    max(telephone) filter (where type = 'TEL-001') as "telephone_urgence",
    
    max(code_postal) filter (where type = 'ADR-001') as "adresse_fixe_code_postal",
    max(code_commune) filter (where type = 'ADR-001') as "adresse_fixe_code_commune",
    max(libelle_commune) filter (where type = 'ADR-001') as "adresse_fixe_libelle_commune",
    max(ligne1_ou_etage) filter (where type = 'ADR-001') as "adresse_fixe_ligne1_ou_etage",
    max(ligne2_ou_batiment) filter (where type = 'ADR-001') as "adresse_fixe_ligne2_ou_batiment",
    max(ligne3_ou_voie) filter (where type = 'ADR-001') as "adresse_fixe_ligne3_ou_voie",
    max(ligne4_ou_complement) filter (where type = 'ADR-001') as "adresse_fixe_ligne4_ou_complement",
    max(ligne5_etranger) filter (where type = 'ADR-001') as "adresse_fixe_ligne5_etranger",
    max(code_pays) filter (where type = 'ADR-001') as "adresse_fixe_code_pays",
    max(libelle_pays) filter (where type = 'ADR-001') as "adresse_fixe_libelle_pays",
    
    
    max(code_postal) filter (where type = 'ADR-002') as "adresse_annuelle_code_postal",
    max(code_commune) filter (where type = 'ADR-002') as "adresse_annuelle_code_commune",
    max(libelle_commune) filter (where type = 'ADR-002') as "adresse_annuelle_libelle_commune",
    max(ligne1_ou_etage) filter (where type = 'ADR-002') as "adresse_annuelle_ligne1_ou_etage",
    max(ligne2_ou_batiment) filter (where type = 'ADR-002') as "adresse_annuelle_ligne2_ou_batiment",
    max(ligne3_ou_voie) filter (where type = 'ADR-002') as "adresse_annuelle_ligne3_ou_voie",
    max(ligne4_ou_complement) filter (where type = 'ADR-002') as "adresse_annuelle_ligne4_ou_complement",
    max(ligne5_etranger) filter (where type = 'ADR-002') as "adresse_annuelle_ligne5_etranger",
    max(code_pays) filter (where type = 'ADR-002') as "adresse_annuelle_code_pays",
    max(libelle_pays) filter (where type = 'ADR-002') as "adresse_annuelle_libelle_pays"

   FROM schema_ins_piste.contact

   GROUP BY contact.code_apprenant;
--SELECT * FROM schema_ins_piste.contacts;






/* *************
    inscription
*/

-- creation de la table
CREATE TABLE schema_ins_piste.inscription AS
    SELECT
        code_apprenant,
        NULL::varchar AS "id",
        NULL::varchar AS "statut_inscription",
        NULL::varchar AS "statut_paiement",
        NULL::varchar AS "statut_pieces",
        NULL::varchar AS "code_structure",
        NULL::varchar AS "code_periode",
        NULL::varchar AS "code_objet_formation",
        NULL::varchar AS "origine",
        NULL::varchar AS "numero_cvec",
        NULL::varchar AS "admission_voie",
        NULL::varchar AS "admission_annee_concours",
        NULL::varchar AS "admission_concours",
        NULL::varchar AS "admission_rang_concours",
        NULL::varchar AS "admission_annee_precedente",
        NULL::varchar AS "admission_type_classe_preparatoire",
        NULL::varchar AS "admission_puissance_classe_preparatoire",
        NULL::varchar AS "admission_code_pays",
        NULL::varchar AS "admission_code_etablissement",
        NULL::varchar AS "cesure",
        NULL::varchar AS "mobilite",
        NULL::boolean AS "temoin_souhait_amenagement",
        NULL::varchar AS "admission_temoin_classe_prepa",
        NULL::varchar AS "admission_type_etablissement_precedent",
        NULL::varchar AS "admission_departement_etablissement_precedent",
        NULL::varchar AS "admission_code_etablissement_etranger",
        NULL::varchar AS "annee_precedente",
        NULL::varchar AS "situation_annee_precedente_code",
        NULL::varchar AS "code_regime_inscription",
        NULL::varchar AS "date_creation",
        NULL::varchar AS "date_modification",
        NULL::varchar AS "annee_obtention_dernier_diplome",
        NULL::varchar AS "code_type_dernier_diplome_obtenu",
        NULL::varchar AS "situation_annee_precedente_code_bcn",
        NULL::varchar AS "date_contexte_situation_annee_precedente",
        NULL::varchar AS "situation_annee_precedente_libelle_affichage",
        NULL::varchar AS "numero_candidat",
        NULL::boolean AS "temoin_principale",
        NULL::varchar AS "date_contexte_admission_concours",
        NULL::varchar AS "date_contexte_admission_type_classe_preparatoire",
        NULL::varchar AS "date_contexte_etablissement_precedent",
        NULL::varchar AS "date_contexte_code_regime_inscription",
        NULL::varchar AS "date_contexte_type_dernier_diplome_obtenu",
        NULL::varchar AS "date_inscription",
        NULL::varchar AS "ecole_doctorale_code",
        NULL::varchar AS "date_contexte_ecole_doctorale",
        NULL::varchar AS "filiere_code",
        NULL::varchar AS "date_contexte_filiere",
        NULL::boolean AS "temoin_convention_etablissement",
        NULL::varchar AS "programme_echange_code",
        NULL::varchar AS "date_contexte_programme_echange",
        NULL::varchar AS "programme_echange_pays_code",
        NULL::boolean AS "temoin_enseignement_distance_depuis_france",
        NULL::varchar AS "contexte_inscription",
        temoin_neo_bachelier,
        source_json->'paiementReference'->'value'->'$binary'->>'base64' AS "paiement_reference",

        source_json_inscription
    FROM schema_ins_piste.apprenant,        
        jsonb_array_elements(source_json->'choixInscription') AS source_json_inscription;


-- extraction des valeurs
update schema_ins_piste.inscription 
set 
	id = source_json_inscription->'_id'->'value'->'$binary'->>'base64',
    statut_inscription = 'EN_COURS',
    --statut_paiement = source_json_inscription->'periode'->>'code',
    --statut_pieces = source_json_inscription->'periode'->>'code',
    code_structure = source_json_inscription->'cheminInscription'->'cibleInscriptionRef'->>'codeStructure',
    code_periode = source_json_inscription->'periode'->>'code',
    code_objet_formation = source_json_inscription->'cheminInscription'->'cibleInscriptionRef'->'chemin'->>-1,
    origine = source_json_inscription->'admission'->'identifiantAdmis'->>'origine',
    numero_cvec = source_json_inscription->'cvec'->>'value',
    --admission_voie = source_json_inscription->'periode'->>'code',
    --admission_annee_concours = source_json_inscription->'periode'->>'code',
    --admission_concours = source_json_inscription->'periode'->>'code',
    --admission_rang_concours = source_json_inscription->'periode'->>'code',
    --admission_annee_precedente = source_json_inscription->'periode'->>'code',
    --admission_type_classe_preparatoire = source_json_inscription->'periode'->>'code',
    --admission_puissance_classe_preparatoire = source_json_inscription->'periode'->>'code',
    --admission_code_pays = source_json_inscription->'periode'->>'code',
    --admission_code_etablissement = source_json_inscription->'periode'->>'code',
    cesure = source_json_inscription->>'cesure',
    mobilite = source_json_inscription->>'mobilite',
    temoin_souhait_amenagement = (source_json_inscription->>'souhaitAmenagementSpecifique')::boolean,
    --admission_temoin_classe_prepa = source_json_inscription->'periode'->>'code',
    --admission_type_etablissement_precedent = source_json_inscription->'periode'->>'code',
    --admission_departement_etablissement_precedent = source_json_inscription->'periode'->>'code',
    --admission_code_etablissement_etranger = source_json_inscription->'periode'->>'code',
    annee_precedente = source_json_inscription->'situationPrecedente'->>'anneePrecedente',
    situation_annee_precedente_code = source_json_inscription->'situationPrecedente'->'situationAnneePrecedente'->>'code',
    code_regime_inscription = source_json_inscription->'regimeInscription'->>'code',
    annee_obtention_dernier_diplome = source_json_inscription->'situationPrecedente'->>'anneeObtentionDernierDiplome',
    code_type_dernier_diplome_obtenu = source_json_inscription->'situationPrecedente'->'dernierDiplome'->>'code',
    situation_annee_precedente_code_bcn = source_json_inscription->'situationPrecedente'->'situationAnneePrecedente'->>'codeBcn',
    situation_annee_precedente_libelle_affichage = source_json_inscription->'situationPrecedente'->'situationAnneePrecedente'->>'libelle',
    numero_candidat = source_json_inscription->'admission'->'identifiantAdmis'->'numeroCandidat'->>'value',
    temoin_principale = (source_json_inscription->>'principal')::boolean,
	--ecole_doctorale_code = source_json_inscription->'periode'->>'code',
    --filiere_code = source_json_inscription->'periode'->>'code',
    --temoin_convention_etablissement = source_json_inscription->'periode'->>'code',
    --programme_echange_code = source_json_inscription->'periode'->>'code',
    --programme_echange_pays_code = source_json_inscription->'periode'->>'code',
    temoin_enseignement_distance_depuis_france = (source_json_inscription->'cheminInscription'->>'teleEnseignement')::boolean,
    contexte_inscription = CASE  
		WHEN temoin_neo_bachelier=true THEN 'PRIMO'
		ELSE 'REINS'
	END
	
    --date_creation = source_json_inscription->'periode'->>'code',
    --date_modification = source_json_inscription->'periode'->>'code',
    --date_contexte_situation_annee_precedente = source_json_inscription->'periode'->>'code',
    --date_contexte_admission_concours = source_json_inscription->'periode'->>'code',
    --date_contexte_admission_type_classe_preparatoire = source_json_inscription->'periode'->>'code',
    --date_contexte_etablissement_precedent = source_json_inscription->'periode'->>'code',
    --date_contexte_code_regime_inscription = source_json_inscription->'periode'->>'code',
    --date_contexte_type_dernier_diplome_obtenu = source_json_inscription->'periode'->>'code',
    --date_inscription = source_json_inscription->'periode'->>'code',
    --date_contexte_ecole_doctorale = source_json_inscription->'periode'->>'code',
    --date_contexte_filiere = source_json_inscription->'periode'->>'code',
    --date_contexte_programme_echange = source_json_inscription->'periode'->>'code',
    ;
--select * from schema_ins_piste.inscription;





/* *************
    bourse_ou_aide_financiere
*/

-- creation de la table
CREATE TABLE schema_ins_piste.bourse_ou_aide_financiere AS
    SELECT
        id AS "id_inscription",
        NULL::varchar AS "code",
        NULL::varchar AS "code_bcn",

        source_json_bourse
    FROM schema_ins_piste.inscription,        
        jsonb_array_elements(source_json_inscription->'boursesOuAidesFinancieres') AS source_json_bourse;


-- extraction des valeurs
update schema_ins_piste.bourse_ou_aide_financiere 
set 
	code = source_json_bourse->>'code',
    code_bcn = source_json_bourse->>'codeBcn'
    ;
--select * from schema_ins_piste.bourse_ou_aide_financiere;






/* *************
    amenagement_specifique
*/

-- creation de la table
CREATE TABLE schema_ins_piste.amenagement_specifique AS
    SELECT
        id AS "id_inscription",
        NULL::varchar AS "code",

        source_json_amenagement_specifique
    FROM schema_ins_piste.inscription,        
        jsonb_array_elements(source_json_inscription->'amenagementsSpecifiques') AS source_json_amenagement_specifique;


-- extraction des valeurs
update schema_ins_piste.amenagement_specifique 
set 
	code = source_json_amenagement_specifique->>'code'
    ;
--select * from schema_ins_piste.amenagement_specifique;




/* *************
    profil_specifique
*/

-- creation de la table
CREATE TABLE schema_ins_piste.profil_specifique AS
    SELECT
        id AS "id_inscription",
        NULL::varchar AS "code",

        source_json_profil_specifique
    FROM schema_ins_piste.inscription,        
        jsonb_array_elements(source_json_inscription->'profilsSpecifiques') AS source_json_profil_specifique;

-- extraction des valeurs
update schema_ins_piste.profil_specifique 
set 
	code = source_json_profil_specifique->>'code'
    ;
--select * from schema_ins_piste.profil_specifique;





/* *************
    demande_piece
*/

-- creation de la table
CREATE TABLE schema_ins_piste.demande_piece AS
    SELECT
        id AS "id_inscription",
        NULL::varchar AS "code",
        NULL::boolean AS "obligatoire",
        NULL::boolean AS "temoin_photo",
        NULL::boolean AS "temoin_primo",
        NULL::boolean AS "temoin_reins",
        NULL::varchar AS "statut_piece",

        source_json_demande_piece
    FROM schema_ins_piste.inscription,        
        jsonb_array_elements(source_json_inscription->'demandesPiece') AS source_json_demande_piece;

-- extraction des valeurs
update schema_ins_piste.demande_piece 
set 
	code = source_json_demande_piece->>'code',
    obligatoire = (source_json_demande_piece->>'obligatoire')::boolean,
    temoin_photo = (source_json_demande_piece->>'temoinPhoto')::boolean,
    temoin_primo = (source_json_demande_piece->>'temoinPrimo')::boolean,
    temoin_reins = (source_json_demande_piece->>'temoinReins')::boolean
    ;
--select * from schema_ins_piste.demande_piece;






/* *************
    inscription_pieces
*/

-- creation de la table
CREATE TABLE schema_ins_piste.inscription_pieces AS
    SELECT
        id AS "id_inscription",
        NULL::varchar AS "code_demande_piece",
        NULL::varchar AS "statut_piece",

        source_json_inscription_pieces
    FROM schema_ins_piste.inscription,        
        jsonb_array_elements(source_json_inscription->'pieces') AS source_json_inscription_pieces;

-- extraction des valeurs
update schema_ins_piste.inscription_pieces 
set 
	code_demande_piece = source_json_inscription_pieces->>'codeDemandePiece',
    statut_piece = source_json_inscription_pieces->>'statutPiece'
    ;

-- mise à jour statut des pièces
UPDATE schema_ins_piste.demande_piece 
SET statut_piece = inscription_pieces.statut_piece
FROM schema_ins_piste.inscription_pieces
WHERE demande_piece.id_inscription = inscription_pieces.id_inscription AND demande_piece.code = inscription_pieces.code_demande_piece;

--select * from schema_ins_piste.demande_piece;

--SELECT * FROM schema_ins_piste.demande_piece ORDER BY id_inscription;









-- ****************************************************************************************************************************
-- Collection calendrier : TODO
-- ****************************************************************************************************************************

/*
insert into schema_ins_piste.calendrier (source_json)
select source_json from mongo_piste_inscription.calendrier;

-- extraction des id
update schema_ins_piste.calendrier set code_calendrier = source_json->'code';
*/



-- ****************************************************************************************************************************
-- Collection chemins : TODO
-- ****************************************************************************************************************************

/*
insert into schema_ins_piste.chemins (source_json)
select source_json from mongo_piste_inscription.chemins;

-- extraction des id
-- update schema_ins_piste.chemins set code_calendrier = source_json->'code';
*/




-- ****************************************************************************************************************************
-- Collection paiements
-- ****************************************************************************************************************************

/* *************
    paiements
*/

-- creation de la table au préalable
create table schema_ins_piste.paiements (
    id varchar,
    montant numeric,
    date_heure timestamp,
    
    paiement_confirme boolean,
    paiement_manuel_valide boolean,
    
    source_json_paiements JSONB
);
-- recopie du JSON
insert into schema_ins_piste.paiements (source_json_paiements)
select source_json from mongo_piste_inscription.paiements;

-- extraction des données
update schema_ins_piste.paiements 
set 
	id = source_json_paiements->'_id'->'value'->'$binary'->>'base64',
    montant = (source_json_paiements->'montant'->>'valeur')::numeric,
    date_heure = (source_json_paiements->'dateHeure'->>'$date')::timestamp,
    
    paiement_confirme = (source_json_paiements->>'paiementConfirme')::boolean,
    paiement_manuel_valide = (source_json_paiements->>'paiementManuelValide')::boolean
    ;

--select * from schema_ins_piste.paiements;
--select * from schema_ins_piste.paiements WHERE id IN (SELECT paiement_reference FROM schema_ins_piste.inscription);



/* *************
    paiements_paybox
*/

-- creation de la table au préalable
CREATE TABLE schema_ins_piste.paiements_paybox AS
    SELECT
        source_json_paiements->'_id'->'value'->'$binary'->>'base64' AS "id_paiement",
        NULL::numeric AS "montant",
        NULL::timestamp AS "date_heure",
        NULL::numeric AS "echeance1_montant" ,
        NULL::timestamp AS "echeance1_date_recouvrement",
        NULL::numeric AS "echeance2_montant" ,
        NULL::timestamp AS "echeance2_date_recouvrement",
        NULL::numeric AS "echeance3_montant" ,
        NULL::timestamp AS "echeance3_date_recouvrement",
        NULL::numeric AS "echeance4_montant" ,
        NULL::timestamp AS "echeance4_date_recouvrement",
        NULL::numeric AS "echeance5_montant" ,
        NULL::timestamp AS "echeance5_date_recouvrement",
        
		NULL::varchar AS "reponse_paybox_code",
		NULL::varchar AS "reponse_paybox_transaction",
		NULL::varchar AS "reponse_paybox_autorisation",
		NULL::varchar AS "reference_paybox",
		NULL::varchar AS "identifiant_compte",

        source_json_paiements_paybox
    FROM schema_ins_piste.paiements,        
        jsonb_array_elements(source_json_paiements->'paiementsPaybox') AS source_json_paiements_paybox;
        
-- extraction des données
update schema_ins_piste.paiements_paybox 
set 
	montant = (source_json_paiements_paybox->'montant'->>'valeur')::numeric,
    date_heure = (source_json_paiements_paybox->'dateHeure'->>'$date')::timestamp,
    
    echeance1_montant = (source_json_paiements_paybox->'echeances'->0->'montant'->>'valeur')::numeric,
	echeance1_date_recouvrement = (source_json_paiements_paybox->'echeances'->0->'dateRecouvrement'->>'$date')::timestamp,
    
    echeance2_montant = (source_json_paiements_paybox->'echeances'->1->'montant'->>'valeur')::numeric,
	echeance2_date_recouvrement = (source_json_paiements_paybox->'echeances'->1->'dateRecouvrement'->>'$date')::timestamp,
    
    echeance3_montant = (source_json_paiements_paybox->'echeances'->2->'montant'->>'valeur')::numeric,
	echeance3_date_recouvrement = (source_json_paiements_paybox->'echeances'->2->'dateRecouvrement'->>'$date')::timestamp,
    
    echeance4_montant = (source_json_paiements_paybox->'echeances'->3->'montant'->>'valeur')::numeric,
	echeance4_date_recouvrement = (source_json_paiements_paybox->'echeances'->3->'dateRecouvrement'->>'$date')::timestamp,
    
    echeance5_montant = (source_json_paiements_paybox->'echeances'->4->'montant'->>'valeur')::numeric,
	echeance5_date_recouvrement = (source_json_paiements_paybox->'echeances'->4->'dateRecouvrement'->>'$date')::timestamp,
    
    reponse_paybox_code = source_json_paiements_paybox->'reponsePaybox'->>'reponseCode',
	reponse_paybox_transaction = source_json_paiements_paybox->'reponsePaybox'->>'reponseTransaction',
	reponse_paybox_autorisation = source_json_paiements_paybox->'reponsePaybox'->>'reponseAutorisation',
	reference_paybox = source_json_paiements_paybox->>'referencePaybox',
	identifiant_compte = source_json_paiements_paybox->>'identifiantCompte'
    ;

--select * from schema_ins_piste.paiements_paybox;



/* ************************************************************************** */
/* Besoins de tests */
/*

- admis qui n'a rien lancé et n'est pas allé sur Pégase
- admis qui s'est connecté 1 fois à Pégase sans aller plus loin
- admis qui s'est connecté a poursuivi son inscription et a déposé 1 pièce obligatoire
- admis qui s'est connecté a poursuivi son inscription et a déposé toutes les pièces obligatoires
- admis qui s'est connecté a poursuivi son inscription et a déposé toutes les pièces obligatoires et a payé
- admis qui s'est inscrit en tant que boursier et est allé jusqu'au bout
- admis sur 2 formations et s'inscrit sur les 2 en même temps en allant jusqu'à la saisie d'une seule poièce jointe
- inscription jusqu'au bout avec validation d'une inscription en IT2S

*/


/* ************************************************************************** */
/* Tests de requêtes */

/*
SELECT 
	apprenant.code_apprenant,
	ine,
	nom_famille,
	nom_usuel,
	prenom,
	prenom2,
	prenom3,
	sexe,
	date_naissance,
	code_pays_naissance,
	libelle_commune_naissance,
	libelle_commune_naissance_etranger,
	code_nationalite,
	telephone_perso,
	telephone_urgence,
	mail_perso,
	code_periode,
	
	string_agg(bourse_ou_aide_financiere.code, ',') AS "bourse_ou_aide_financiere",
	
	COUNT(*) FILTER(WHERE demande_piece.obligatoire = TRUE) AS "nbr_pieces_obligatoires",
	COUNT(*) FILTER(WHERE demande_piece.statut_piece IS NOT NULL) AS "nbr_pieces_deposees"
	
FROM schema_ins_piste.apprenant

LEFT JOIN schema_ins_piste.inscription ON inscription.code_apprenant = apprenant.code_apprenant
LEFT JOIN schema_ins_piste.bourse_ou_aide_financiere ON bourse_ou_aide_financiere.id_inscription = inscription.id
LEFT JOIN schema_ins_piste.contacts ON contacts.code_apprenant = apprenant.code_apprenant
LEFT JOIN schema_ins_piste.demande_piece ON demande_piece.id_inscription = inscription.id

WHERE code_periode IS NOT NULL
--AND code_periode IN ('PER-2024', 'PER-2024-S1', 'PER-2024-S2')

GROUP BY
	apprenant.code_apprenant,
	ine,
	nom_famille,
	nom_usuel,
	prenom,
	prenom2,
	prenom3,
	sexe,
	date_naissance,
	code_pays_naissance,
	libelle_commune_naissance,
	libelle_commune_naissance_etranger,
	code_nationalite,
	telephone_perso,
	telephone_urgence,
	mail_perso,
	code_periode,
	bourse_ou_aide_financiere.code;
*/



/*
SELECT 
	apprenant.code_apprenant,
	ine,
	nom_famille,
	nom_usuel,
	prenom,
	prenom2,
	prenom3,
	sexe,
	date_naissance,
	code_pays_naissance,
	libelle_commune_naissance,
	libelle_commune_naissance_etranger,
	code_nationalite,
	telephone_perso,
	telephone_urgence,
	mail_perso,
	code_periode,
	
	string_agg(bourse_ou_aide_financiere.code, ',') AS "bourse_ou_aide_financiere",
	
	COUNT(*) FILTER(WHERE demande_piece.obligatoire = TRUE) AS "nbr_pieces_obligatoires",
	COUNT(*) FILTER(WHERE demande_piece.statut_piece IS NOT NULL) AS "nbr_pieces_deposees",
    
    paiements.montant AS "paiement_montant",
    paiements.date_heure AS "paiement_date_heure",
    paiements.paiement_confirme AS "paiement_confirme"
	
FROM schema_ins_piste.apprenant

LEFT JOIN schema_ins_piste.inscription ON inscription.code_apprenant = apprenant.code_apprenant
LEFT JOIN schema_ins_piste.bourse_ou_aide_financiere ON bourse_ou_aide_financiere.id_inscription = inscription.id
LEFT JOIN schema_ins_piste.contacts ON contacts.code_apprenant = apprenant.code_apprenant
LEFT JOIN schema_ins_piste.demande_piece ON demande_piece.id_inscription = inscription.id
LEFT JOIN schema_ins_piste.paiements ON paiements.id = inscription.paiement_reference

WHERE code_periode IS NOT NULL
--AND code_periode IN ('PER-2024', 'PER-2024-S1', 'PER-2024-S2')

GROUP BY
	apprenant.code_apprenant,
	ine,
	nom_famille,
	nom_usuel,
	prenom,
	prenom2,
	prenom3,
	sexe,
	date_naissance,
	code_pays_naissance,
	libelle_commune_naissance,
	libelle_commune_naissance_etranger,
	code_nationalite,
	telephone_perso,
	telephone_urgence,
	mail_perso,
	code_periode,
	bourse_ou_aide_financiere.code,
	paiements.montant,
    paiements.date_heure,
    paiements.paiement_confirme
    ;
*/
