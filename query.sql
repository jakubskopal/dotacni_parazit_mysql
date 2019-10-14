SET GLOBAL sql_mode = '';

# Poznamky:
#   refundaceIndikator vypada ze znamena, ze bylo pozdeji refundovano z EU fondu

SELECT
    prijemceIco                                AS 'ICO',
    prijemceJmenoPrijemce                      AS 'Prijemce',
    dotaceProjektNazev                         AS 'Projekt - Nazev',
    # Ucel projektu nedokazeme najit
    dotaceProjektKod                           AS 'Projekt - Kod',
    dotaceProjektIdentifikator                 AS 'Projekt - Identifikator',
    # Dotacni titul nebo ucelovy znak
    COALESCE(
            dotaceTitulKod,
            ucelZnakKod)                       AS 'Dot. Titul/Ucel Znak - Kod',
    COALESCE(
            dotaceTitulNazev,
            ucelZnakNazev)                     AS 'Dot. Titul/Ucel Znak - Nazev',
    # Operacni program nebo grantove schema
    COALESCE(
            operacniProgramKod,
            grantoveSchemaKod)                 AS 'OP/GS - Kod',
    COALESCE(
            operacniProgramNazev,
            grantoveSchemaNazev)               AS 'OP/GS - Nazev',
    rozhodnutiDotacePoskytovatelKod            AS 'Poskytovatel - Kod',
    rozhodnutiDotacePoskytovatelNazev          AS 'Poskytovatel - Nazev',
    rozhodnutiTuzemskyZdroj                    AS 'Zdroj je CR',
    rozhodnutiRokRozhodnuti                    AS 'Rok Rozhodnuti',
    prijemceOkresNutsKod                       AS 'Okres - NUTS',
    prijemceOkresNazev                         AS 'Okres - Nazev',
    prijemceObecNutsKod                        AS 'Obec - NUTS',
    prijemceObecNazev                          AS 'Obec - Nazev',
    rozhodnutiCastkaPozadovana                 AS 'Castka - Pozadovana',
    SUM(obdobiCastkaSpotrebovana)              AS 'Castka - Spotrebovana',
    idPrijemce                                 AS 'ID Prijemce',
    idDotace                                   AS 'ID Dotace',
    idRozhodnuti                               AS 'ID Rozhodnuti'
FROM viewCombined
WHERE
      rozhodnutiRefundaceIndikator = 0
GROUP BY
    idDotace,
    idPrijemce,
    idRozhodnuti,
    prijemceIco,
    prijemceJmenoPrijemce,
    dotaceTitulKod,
    ucelZnakKod,
    dotaceTitulNazev,
    ucelZnakNazev,
    dotaceProjektKod,
    dotaceProjektIdentifikator,
    dotaceProjektNazev,
    operacniProgramKod,
    grantoveSchemaKod,
    operacniProgramNazev,
    grantoveSchemaNazev,
    rozhodnutiDotacePoskytovatelKod,
    rozhodnutiDotacePoskytovatelNazev,
#     rozhodnuti.tuzemskyZdroj,
    rozhodnutiRokRozhodnuti,
    prijemceOkresNutsKod,
    prijemceOkresNazev,
    prijemceObecNutsKod,
    prijemceObecNazev,
    rozhodnutiCastkaPozadovana
