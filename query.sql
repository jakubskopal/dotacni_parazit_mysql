SET GLOBAL sql_mode = '';

SELECT * FROM viewCombined ORDER BY idPrijemce, idDotace, idRozhodnuti, idObdobi;

# SELECT * FROM viewCombined WHERE rozhodnutiRefundaceIndikator = 0 ORDER BY prijemceIco, dotacePodpisDatum, dotaceProjektIdentifikator, rozhodnutiRokRozhodnuti, obdobiRozpoctoveObdobi;

# Poznamky:
#   refundaceIndikator vypada ze znamena, ze bylo pozdeji refundovano z EU fondu

# SELECT
#     prijemceIco                                AS 'Prijemce_ICO',
#     prijemceJmenoPrijemce                      AS 'Prijemce_Jmeno',
#     dotaceProjektNazev                         AS 'Dotace_NazevProjektu',
#     # Ucel projektu nedokazeme najit
#     dotaceProjektKod                           AS 'Dotace_KodProjektu',
#     dotaceProjektIdentifikator                 AS 'Dotace_IdentifikatorProjektu',
#     # Dotacni titul nebo ucelovy znak
#     COALESCE(
#             dotaceTitulKod,
#             ucelZnakKod)                       AS 'Dotace_KodTituluNeboUcelu',
#     COALESCE(
#             dotaceTitulNazev,
#             ucelZnakNazev)                     AS 'Dotace_NazevTituluNeboUcelu',
#     # Operacni program nebo grantove schema
#     COALESCE(
#             operacniProgramKod,
#             grantoveSchemaKod)                 AS 'Obdobi_KodProgramuNeboSchematu',
#     COALESCE(
#             operacniProgramNazev,
#             grantoveSchemaNazev)               AS 'Obdobi_NazevProgramuNeboSchematu',
#     rozhodnutiDotacePoskytovatelKod            AS 'Rozhodnuti_KodPoskytovatele',
#     rozhodnutiDotacePoskytovatelNazev          AS 'Rozhodnuti_NazevPoskytovatele',
#     rozhodnutiTuzemskyZdroj                    AS 'Rozhodnuti_ZdrojJeVCR',
#     rozhodnutiRokRozhodnuti                    AS 'Rozhodnuti_Rok',
#     prijemceOkresNutsKod                       AS 'Prijemce_NUTSOkresu',
#     prijemceOkresNazev                         AS 'Prijemce_NazevOkresu',
#     prijemceObecNutsKod                        AS 'Prijemce_NUTSObce',
#     prijemceObecNazev                          AS 'Prijemce_NazevObce',
#     rozhodnutiCastkaPozadovana                 AS 'Rozhodnuti_PozadovanaCastka',
#     obdobiCastkaCerpana                        AS 'Obdobi_CerpanaCastka',
#     obdobiCastkaUvolnena                       AS 'Obdobi_UvonenaCastka',
#     obdobiCastkaVracena                        AS 'Obdobi_UvonenaCastka',
#     obdobiCastkaSpotrebovana                   AS 'Obdobi_SpotrebovanaCastka',
#     idPrijemce                                 AS 'ID Prijemce',
#     idDotace                                   AS 'ID Dotace',
#     idRozhodnuti                               AS 'ID Rozhodnuti'
# FROM viewCombined
# WHERE
#       rozhodnutiRefundaceIndikator = 0
# #       AND idDotace = '0077B1C5C1023C43FA7B4017F98DC2455A92FE03'
# GROUP BY
#     idDotace,
#     idPrijemce,
#     idRozhodnuti,
#     prijemceIco,
#     prijemceJmenoPrijemce,
#     dotaceTitulKod,
#     ucelZnakKod,
#     dotaceTitulNazev,
#     ucelZnakNazev,
#     dotaceProjektKod,
#     dotaceProjektIdentifikator,
#     dotaceProjektNazev,
#     operacniProgramKod,
#     grantoveSchemaKod,
#     operacniProgramNazev,
#     grantoveSchemaNazev,
#     rozhodnutiDotacePoskytovatelKod,
#     rozhodnutiDotacePoskytovatelNazev,
#     rozhodnutiTuzemskyZdroj,
#     rozhodnutiRokRozhodnuti,
#     prijemceOkresNutsKod,
#     prijemceOkresNazev,
#     prijemceObecNutsKod,
#     prijemceObecNazev,
#     rozhodnutiCastkaPozadovana
