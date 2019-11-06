SET sql_mode = '';

DROP TABLE IF EXISTS viewCiselnikOperacniProgram;

# NOTE: View spojujici ciselniky operacnik programu
CREATE TABLE viewCiselnikOperacniProgram AS
SELECT
       opp.idOperacniProgram, operacaniProgramKod, operacaniProgramNazev, operacaniProgramCislo, zaznamPlatnostOdDatum, zaznamPlatnostDoDatum
FROM ciselnikCedrOperacniProgramv01 opp
UNION ALL
SELECT
       opp.idOperacniProgram, operacaniProgramKod, operacaniProgramNazev, operacaniProgramCislo, zaznamPlatnostOdDatum, zaznamPlatnostDoDatum
FROM ciselnikMmrOperacniProgramv01 opp;

ALTER TABLE viewCiselnikOperacniProgram ADD PRIMARY KEY (idOperacniProgram);

DROP TABLE IF EXISTS viewCiselnikGrantoveSchema;

# NOTE: View spojujici ciselniky grantovych schemat
CREATE TABLE viewCiselnikGrantoveSchema AS
SELECT
       grs.idGrantoveSchema, grantoveSchemaKod, grantoveSchemaNazev, grantoveSchemaCislo, zaznamPlatnostOdDatum, zaznamPlatnostDoDatum
FROM ciselnikCedrGrantoveSchemav01 grs
UNION ALL
SELECT
       grs.idGrantoveSchema, grantoveSchemaKod, grantoveSchemaNazev, grantoveSchemaCislo, zaznamPlatnostOdDatum, zaznamPlatnostDoDatum
FROM ciselnikMmrGrantoveSchemav01 grs;

ALTER TABLE viewCiselnikGrantoveSchema ADD PRIMARY KEY (idGrantoveSchema);

DROP TABLE IF EXISTS viewDotace;

CREATE TABLE viewDotace AS
SELECT
       idDotace,
       idPrijemce,
       NULLIF(TRIM(projektKod), '')                                            AS projektKod,
       podpisDatum,
       subjektRozliseniKod,
       NULLIF(ukonceniPlanovaneDatum, TIMESTAMP '0000-00-00 00:00:00')         AS ukonceniPlanovaneDatum,
       NULLIF(ukonceniSkutecneDatum, TIMESTAMP '0000-00-00 00:00:00')          AS ukonceniSkutecneDatum,
       NULLIF(zahajeniPlanovaneDatum, TIMESTAMP '0000-00-00 00:00:00')         AS zahajeniPlanovaneDatum,
       NULLIF(zahajeniSkutecneDatum, TIMESTAMP '0000-00-00 00:00:00')          AS zahajeniSkutecneDatum,
       zmenaSmlouvyIndikator,
       projektIdnetifikator,
       COALESCE(
           NULLIF(TRIM(projektNazev), ''),
           (SELECT GROUP_CONCAT(e.etapaNazev ORDER BY e.etapaCislo SEPARATOR ', ') FROM Etapa e WHERE e.idDotace = Dotace.idDotace))
                                                                               AS projektNazev,
       NULLIF(TRIM(iriOperacniProgram), '')                                    AS iriOperacniProgram,
       NULLIF(TRIM(iriPodprogram), '')                                         AS iriPodprogram,
       NULLIF(TRIM(iriPriorita), '')                                           AS iriPriorita,
       NULLIF(TRIM(iriOpatreni), '')                                           AS iriOpatreni,
       NULLIF(TRIM(iriPodopatreni), '')                                        AS iriPodopatreni,
       NULLIF(TRIM(iriGrantoveSchema), '')                                     AS iriGrantoveSchema,
       NULLIF(TRIM(iriProgramPodpora), '')                                     AS iriProgramPodpora,
       NULLIF(TRIM(iriTypCinnosti), '')                                        AS iriTypCinnosti,
       NULLIF(TRIM(iriProgram), '')                                            AS iriProgram,
       dPlatnost,
       dtAktualizace
FROM Dotace;

ALTER TABLE viewDotace ADD PRIMARY KEY (idDotace);

DROP TABLE IF EXISTS viewRozpoctoveObdobi;

CREATE TABLE viewRozpoctoveObdobi AS
SELECT
       idObdobi,
       idRozhodnuti,
       castkaCerpana,
       castkaUvolnena,
       castkaVracena,
       castkaSpotrebovana,
       rozpoctoveObdobi,
       vyporadaniKod,
       NULLIF(TRIM(iriDotacniTitul), '')                                       AS iriDotacniTitul,
       NULLIF(TRIM(iriUcelovyZnak), '')                                        AS iriUcelovyZnak,
       dPlatnost,
       dtAktualizace
FROM RozpoctoveObdobi;

ALTER TABLE viewRozpoctoveObdobi ADD PRIMARY KEY (idObdobi);
ALTER TABLE viewRozpoctoveObdobi ADD FOREIGN KEY (iriDotacniTitul) REFERENCES ciselnikDotaceTitulv01(idDotaceTitul);
ALTER TABLE viewRozpoctoveObdobi ADD FOREIGN KEY (iriUcelovyZnak) REFERENCES ciselnikUcelZnakv01(idUcelZnak);

DROP TABLE IF EXISTS viewPrijemcePomoci;

# NOTE: View normalizujici prijemce, jeho jmeno, obec a okres
CREATE TABLE viewPrijemcePomoci AS
SELECT
       pri.idPrijemce,
       NULLIF(pri.ico, '0') ico,
       CASE
           WHEN NULLIF(pri.ico, '0') IS NULL THEN CONCAT(pri.prijmeni, ' ', pri.jmeno, ' (', pri.rokNarozeni, ')')
           ELSE NULLIF(pri.obchodniJmeno, '')
           END jmenoPrijemce,
       NULLIF(TRIM(pri.obchodniJmeno), '')                                        AS obchodniJmeno,
       NULLIF(TRIM(pri.prijmeni), '')                                             AS prijmeni,
       NULLIF(TRIM(pri.jmeno), '')                                                AS jmeno,
       NULLIF(pri.rokNarozeni, 0)                                                 AS rokNarozeni,
       obec.obecKod,
       obec.id                                                                    AS iriObec,
       obec.obecNazev,
       obec.obecNutsKod,
       okres.id                                                                   AS iriOkres,
       okres.okresNazev,
       okres.okresNutsKod
    FROM PrijemcePomoci pri
        LEFT JOIN AdresaBydliste byd on byd.idPrijemce = pri.idPrijemce
        LEFT JOIN AdresaSidlo sid on sid.idPrijemce = pri.idPrijemce
        LEFT JOIN Osoba oso on oso.id = pri.iriOsoba
        LEFT JOIN ciselnikObecv01 obec on obec.obecKod = COALESCE(sid.obecKod, byd.obecKod, oso.bydlisteObecKod) AND obec.zaznamPlatnostDoDatum > NOW()
        LEFT JOIN ciselnikOkresv01 okres on okres.okresKod = obec.okresNadKod AND okres.zaznamPlatnostDoDatum > NOW();

ALTER TABLE viewPrijemcePomoci ADD PRIMARY KEY (idPrijemce);

DROP TABLE IF EXISTS viewRozhodnuti;

# NOTE: View normalizujici rozhodnuti, financni zdroj (EU/CZ) a poskytovatele
CREATE TABLE viewRozhodnuti AS
SELECT
       roz.idRozhodnuti,
       roz.idDotace,
       roz.castkaPozadovana,
       roz.castkaRozhodnuta,
       roz.rokRozhodnuti,
       roz.investiceIndikator,
       roz.navratnostIndikator,
       roz.refundaceIndikator,
       CASE WHEN LEFT(zdroj.financniZdrojKod, 1) = 't' THEN 1 ELSE 0 END tuzemskyZdroj,
       zdroj.financniZdrojKod,
       zdroj.financniZdrojNazev,
       poskytovatel.dotacePoskytovatelKod,
       poskytovatel.dotacePoskytovatelNazev
FROM Rozhodnuti roz
     LEFT JOIN ciselnikFinancniZdrojv01 zdroj ON zdroj.id = roz.iriFinancniZdroj
     LEFT JOIN ciselnikDotacePoskytovatelv01 poskytovatel ON poskytovatel.id = roz.iriPoskytovatelDotace;

ALTER TABLE viewRozhodnuti ADD PRIMARY KEY (idRozhodnuti);

ALTER TABLE viewDotace ADD FOREIGN KEY (idPrijemce) REFERENCES viewPrijemcePomoci(idPrijemce);
ALTER TABLE viewRozpoctoveObdobi ADD FOREIGN KEY (idRozhodnuti) REFERENCES viewRozhodnuti(idRozhodnuti);
ALTER TABLE viewRozhodnuti ADD FOREIGN KEY (idDotace) REFERENCES viewDotace(idDotace);

DROP TABLE IF EXISTS viewCombined;

CREATE TABLE viewCombined AS
SELECT
       prijemce.idPrijemce                                                        AS idPrijemce,
       prijemce.ico                                                               AS prijemceIco,
       prijemce.jmenoPrijemce                                                     AS prijemceJmenoPrijemce,
       prijemce.obchodniJmeno                                                     AS prijemceObchodniJmeno,
       prijemce.prijmeni                                                          AS prijemcePrijmeni,
       prijemce.jmeno                                                             AS prijemceJmeno,
       prijemce.rokNarozeni                                                       AS prijemceRokNarozeni,
       prijemce.obecKod                                                           AS prijemceObecKod,
       prijemce.iriObec                                                           AS prijemceIriObec,
       prijemce.obecNazev                                                         AS prijemceObecNazev,
       prijemce.obecNutsKod                                                       AS prijemceObecNutsKod,
       prijemce.iriOkres                                                          AS prijemceIriOkres,
       prijemce.okresNazev                                                        AS prijemceOkresNazev,
       prijemce.okresNutsKod                                                      AS prijemceOkresNutsKod,

       dotace.idDotace                                                            AS idDotace,
       dotace.projektKod                                                          AS dotaceProjektKod,
       dotace.podpisDatum                                                         AS dotacePodpisDatum,
       dotace.subjektRozliseniKod                                                 AS dotaceSubjektRozliseniKod,
       dotace.ukonceniPlanovaneDatum                                              AS dotaceUkonceniPlanovaneDatum,
       dotace.ukonceniSkutecneDatum                                               AS dotaceUkonceniSkutecneDatum,
       dotace.zahajeniPlanovaneDatum                                              AS dotaceZahajeniPlanovaneDatum,
       dotace.zahajeniSkutecneDatum                                               AS dotaceZahajeniSkutecneDatum,
       dotace.zmenaSmlouvyIndikator                                               AS dotaceZmenaSmlouvyIndikator,
       dotace.projektIdnetifikator                                                AS dotaceProjektIdentifikator,
       dotace.projektNazev                                                        AS dotaceProjektNazev,
       dotace.iriOperacniProgram                                                  AS dotaceIriOperacniProgram,
       dotace.iriPodprogram                                                       AS dotaceIriPodprogram,
       dotace.iriPriorita                                                         AS dotaceIriPriorita,
       dotace.iriOpatreni                                                         AS dotaceIriOpatreni,
       dotace.iriPodopatreni                                                      AS dotaceIriPodopatreni,
       dotace.iriGrantoveSchema                                                   AS dotaceIriGrantoveSchema,
       dotace.iriProgramPodpora                                                   AS dotaceIriProgramPodpora,
       dotace.iriTypCinnosti                                                      AS dotaceIriTypCinnosti,
       dotace.iriProgram                                                          AS dotaceIriProgram,
       dotace.dPlatnost                                                           AS dotaceDPlatnost,
       dotace.dtAktualizace                                                       AS dotaceDTAktualizace,

       operacniProgram.idOperacniProgram                                          AS idOperacniProgram,
       operacniProgram.operacaniProgramKod                                        AS dotaceOperacniProgramKod,
       operacniProgram.operacaniProgramNazev                                      AS dotaceOperacniProgramNazev,
       operacniProgram.operacaniProgramCislo                                      AS dotaceOperacniProgramCislo,
       operacniProgram.zaznamPlatnostOdDatum                                      AS dotaceOperacniProgramZaznamPlatnostOdDatum,
       operacniProgram.zaznamPlatnostDoDatum                                      AS dotaceOperacniProgramZaznamPlatnostDoDatum,

       grantoveSchema.idGrantoveSchema                                            AS idGrantoveSchema,
       grantoveSchema.grantoveSchemaKod                                           AS dotaceGrantoveSchemaKod,
       grantoveSchema.grantoveSchemaNazev                                         AS dotaceGrantoveSchemaNazev,
       grantoveSchema.grantoveSchemaCislo                                         AS dotaceGrantoveSchemaCislo,
       grantoveSchema.zaznamPlatnostOdDatum                                       AS dotaceGrantoveSchemaZaznamPlatnostOdDatum,
       grantoveSchema.zaznamPlatnostDoDatum                                       AS dotaceGrantoveSchemaZaznamPlatnostDoDatum,

       rozhodnuti.idRozhodnuti                                                    AS idRozhodnuti,
       rozhodnuti.castkaPozadovana                                                AS rozhodnutiCastkaPozadovana,
       rozhodnuti.castkaRozhodnuta                                                AS rozhodnutiCastkaRozhodnuta,
       rozhodnuti.rokRozhodnuti                                                   AS rozhodnutiRokRozhodnuti,
       rozhodnuti.investiceIndikator                                              AS rozhodnutiInvesticeIndikator,
       rozhodnuti.navratnostIndikator                                             AS rozhodnutiNavratnostIndikator,
       rozhodnuti.refundaceIndikator                                              AS rozhodnutiRefundaceIndikator,
       rozhodnuti.tuzemskyZdroj                                                   AS rozhodnutiTuzemskyZdroj,
       rozhodnuti.financniZdrojKod                                                AS rozhodnutiFinancniZdrojKod,
       rozhodnuti.financniZdrojNazev                                              AS rozhodnutiFinancniZdrojNazev,
       rozhodnuti.dotacePoskytovatelKod                                           AS rozhodnutiDotacePoskytovatelKod,
       rozhodnuti.dotacePoskytovatelNazev                                         AS rozhodnutiDotacePoskytovatelNazev,

       obdobi.idObdobi                                                            AS idObdobi,
       obdobi.castkaCerpana                                                       AS obdobiCastkaCerpana,
       obdobi.castkaUvolnena                                                      AS obdobiCastkaUvolnena,
       obdobi.castkaVracena                                                       AS obdobiCastkaVracena,
       obdobi.castkaSpotrebovana                                                  AS obdobiCastkaSpotrebovana,
       obdobi.rozpoctoveObdobi                                                    AS obdobiRozpoctoveObdobi,
       obdobi.iriDotacniTitul                                                     AS obdobiIriDotacniTitul,
       obdobi.iriUcelovyZnak                                                      AS obdobiIriUcelovyZnak,
       obdobi.dPlatnost                                                           AS obdobiDPlatnost,
       obdobi.dtAktualizace                                                       AS obdobiDTAktualizace,

       titul.dotaceTitulKod                                                       AS obdobiDotaceTitulKod,
       titul.dotaceTitulNazev                                                     AS obdobiDotaceTitulNazev,

       ucelZnak.ucelZnakKod                                                       AS obdobiUcelZnakKod,
       ucelZnak.ucelZnakNazev                                                     AS obdobiUcelZnakNazev
FROM
    viewDotace dotace
    INNER JOIN viewRozhodnuti rozhodnuti on dotace.idDotace = rozhodnuti.idDotace
    INNER JOIN viewPrijemcePomoci prijemce on prijemce.idPrijemce = dotace.idPrijemce
    LEFT JOIN viewRozpoctoveObdobi obdobi on rozhodnuti.idRozhodnuti = obdobi.idRozhodnuti
    LEFT JOIN viewCiselnikOperacniProgram operacniProgram ON operacniProgram.idOperacniProgram = dotace.iriOperacniProgram
    LEFT JOIN viewCiselnikGrantoveSchema grantoveSchema ON grantoveSchema.idGrantoveSchema = dotace.iriGrantoveSchema
    LEFT JOIN ciselnikDotaceTitulv01 titul ON titul.idDotaceTitul = obdobi.iriDotacniTitul
    LEFT JOIN ciselnikUcelZnakv01 ucelZnak ON ucelZnak.idUcelZnak = obdobi.iriUcelovyZnak;

ALTER TABLE viewCombined ADD PRIMARY KEY (idPrijemce, idDotace, idRozhodnuti, idObdobi);
ALTER TABLE viewCombined ADD INDEX idx_viewCombined_logical (prijemceIco, dotacePodpisDatum, dotaceProjektIdentifikator, rozhodnutiRokRozhodnuti, obdobiRozpoctoveObdobi)

