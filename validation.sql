# NOTE: Vsichni prijemci existuji
SELECT count(*) FROM Dotace WHERE NOT EXISTS(SELECT * FROM PrijemcePomoci WHERE PrijemcePomoci.idPrijemce = Dotace.idPrijemce);

# NOTE: 7309 Prijemcu pomoci nema vubec zadnou adresu
SELECT count(*) FROM PrijemcePomoci WHERE NOT EXISTS(SELECT * FROM AdresaBydliste WHERE PrijemcePomoci.idPrijemce = AdresaBydliste.idPrijemce)
                                          AND NOT EXISTS(SELECT * FROM AdresaSidlo WHERE PrijemcePomoci.idPrijemce = AdresaSidlo.idPrijemce)
                                          AND NULLIF(PrijemcePomoci.iriOsoba, '') IS NULL;

# NOTE: Vsechny osoby maji kod bydliste obce
SELECT count(*) FROM Osoba WHERE NULLIF(bydlisteObecKod, '') IS NULL;

# NOTE: Zadny prijemce nema vice adres bydliste ani sidla, pokud uz nejakou ma
SELECT idPrijemce, COUNT(*) FROM AdresaBydliste GROUP BY idPrijemce HAVING COUNT(*) > 1;
SELECT idPrijemce, COUNT(*) FROM AdresaSidlo GROUP BY idPrijemce HAVING COUNT(*) > 1;

# NOTE: Vsechny obce maji jen jeden aktualni nazev
SELECT obecKod, count(*) FROM ciselnikObecv01 WHERE zaznamPlatnostDoDatum > NOW() GROUP BY obecKod HAVING count(*) > 1;

# NOTE: Vsechny dotace maji alespon jedno rozhodnuti
SELECT COUNT(*) FROM Dotace WHERE NOT EXISTS(SELECT * FROM Rozhodnuti WHERE Rozhodnuti.idDotace = Dotace.idDotace);
