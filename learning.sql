------- CONNECTION -------
psql -h <DB serverio vardas> -d <DB vardas> -f <SQL failo vardas>
psql -h pgsql3.mif -d biblio -f pirmas-laboras-1.sql

------- SELECT -------
SELECT * 
FROM stud.Autorius;

SELECT vardas, pavarde 
FROM stud.Autorius
WHERE isbn = '9998-01-103-5';

SELECT aut.vardas, aut.pavarde
FROM stud.Autorius AS aut
WHERE aut.isbn = '9998-01-103-5';

SELECT vardas
FROM stud.Autorius AS aut; 

-- panaikiname vienodas eilutes
SELECT DISTINCT vardas
FROM stud.Autorius AS aut;

SELECT leidykla, 
    puslapiai * 2 
FROM stud.Knyga AS kn;

SELECT leidykla, 
    puslapiai * 2 AS puslapiai
FROM stud.Knyga AS kn;

SELECT leidykla,
    leidykla AS "knygos leidykla",
    puslapiai AS psl
FROM stud.Knyga AS kn;

SELECT * 
FROM stud.Knyga AS kn;

SELECT kn.* 
FROM stud.Knyga AS kn;

SELECT vardas
FROM stud.Autorius AS aut
ORDER BY vardas;

-- nuo 2 stulpelio tvarkys abėcėlės tvarka,
-- esant vienodoms reikšmėms, tvarkys
-- pagal kategorija (mažėjimo tvarka)
SELECT isbn, vardas, pavarde
FROM stud.Autorius AS aut
ORDER BY 2, pavarde DESC;

SELECT *
FROM stud.knyga AS kn
ORDER BY COALESCE(kn.verte, 0);

SELECT COUNT(*) 
FROM stud.Autorius AS aut;

SELECT COUNT(DISTINCT vardas)
FROM stud.Autorius AS aut;

SELECT SUM(puslapiai)
FROM stud.Knyga AS kn
WHERE INITCAP(leidykla)='Juodoji';

SELECT pavadinimas, puslapiai
FROM stud.Knyga AS kn
WHERE pavadinimas LIKE '%SQL%' AND 
verte IN (22.50, 19.90, 45.20);

SELECT *
FROM stud.Knyga as kn
WHERE (verte=22.50 OR verte=19.90) AND 
    SUBSTRING(pavadinimas, 1, 1)='O';

SELECT *
FROM stud.Knyga as kn
WHERE (verte=22.50 OR verte=19.90) AND 
    LOWER(SUBSTRING(pavadinimas, 1, 1))='o';

SELECT COUNT(*) 
FROM stud.egzempliorius AS egz
WHERE grazinti = CAST(FORMAT('2024-10-04', 'yyyy-MM-dd') AS DATE);

-- Reikšmę paverčiame į DATE tipą
SELECT COUNT(*) 
FROM stud.egzempliorius AS egz
WHERE egz.grazinti = CAST(FORMAT('10/04/2024', 'MM/dd/yyyy') AS DATE);

SELECT COUNT(*) 
FROM stud.egzempliorius AS egz
WHERE EXTRACT(DAY FROM egz.grazinti) = 4;

SELECT COUNT(*)
FROM stud.egzempliorius AS egz
WHERE EXTRACT(DAY FROM egz.grazinti) = 4 AND 
    EXTRACT(MONTH FROM egz.grazinti) = 10 AND
    EXTRACT(YEAR FROM egz.grazinti) = 2024;

SELECT COUNT(*) "Visi egz."
FROM stud.egzempliorius AS egz
WHERE CAST(egz.grazinti AS DATE) BETWEEN 
    '2024-10-04' AND '2024-10-05';

SELECT COUNT(*)
FROM stud.egzempliorius AS egz
WHERE egz.grazinti IS NOT NULL;

SELECT COUNT(*)
FROM stud.egzempliorius AS egz
WHERE egz.grazinti IS NOT NULL AND
    CAST(egz.grazinti AS DATE) = '10/04/2024';

SELECT COUNT(*) 
FROM stud.egzempliorius AS egz
WHERE grazinti < '2024-10-10';

SELECT COUNT(*) "Visi egz.",
    COUNT(egz.paimta) "Visi paimti egz.",
    COUNT(CASE WHEN egz.skaitytojas IS NULL
        THEN 1
        ELSE NULL END) "Viso neskaitomu egz."
FROM stud.egzempliorius AS egz;

SELECT COUNT(*) AS "Visi egz.",
    COUNT(DISTINCT egz.isbn) AS "Visos kn.",
    COUNT(egz.skaitytojas) AS "Visos sk. knygos",
    COUNT(CASE WHEN egz.skaitytojas IS NULL 
        THEN 1 
        ELSE NULL END) AS "Viso neskaitomu kn."
FROM stud.egzempliorius AS egz;

SELECT COUNT(*) "Visos kn.",
    SUM(puslapiai) "Puslapiu sk."
FROM stud.knyga as kn;

-- ne NULL reikšmių skaičius
SELECT COUNT(skaitytojas)
FROM stud.egzempliorius AS egz;

SELECT SUM(puslapiai)
FROM stud.knyga AS kn;

SELECT MAX(puslapiai)
FROM stud.knyga AS kn;

SELECT MIN(verte)
FROM stud.knyga AS kn;

SELECT CAST(AVG(COALESCE(verte, 0)) AS DECIMAL(6,2)) AS "I vidurkis", 
    CAST(AVG(verte) AS DECIMAL(6,2)) AS "II vidurkis"
FROM stud.knyga AS kn;

SELECT ROUND(AVG(COALESCE(verte, 0)), 3) AS "Pirmas vidurkis", 
    ROUND(AVG(verte), 3) AS "Antras vidurkis"
FROM stud.knyga AS kn;

SELECT * 
FROM stud.knyga AS kn
WHERE COALESCE(kn.verte, 0) > 50 OR
    COALESCE(kn.verte, 0) = 22.50;

SELECT * 
FROM stud.knyga AS kn
WHERE (COALESCE(kn.verte, 0) > 50 OR
    COALESCE(kn.verte, 0) = 22.50) AND
    LOWER(kn.pavadinimas) LIKE '%duomenu%';

SELECT *
FROM stud.egzempliorius AS egz
JOIN stud.knyga AS kn
ON egz.isbn = kn.isbn
ORDER BY COALESCE(kn.pavadinimas, '');

SELECT *
FROM stud.egzempliorius AS egz
RIGHT JOIN stud.knyga AS kn
ON egz.isbn = kn.isbn
ORDER BY COALESCE(kn.verte, 0);

SELECT DISTINCT(kn.pavadinimas)
FROM stud.egzempliorius AS egz
JOIN stud.knyga AS kn
ON egz.isbn = kn.isbn
ORDER BY kn.pavadinimas;

SELECT DISTINCT(kn.pavadinimas)
FROM stud.egzempliorius AS egz
JOIN stud.knyga AS kn
ON egz.isbn = kn.isbn
WHERE kn.metai = '2016'
ORDER BY kn.pavadinimas;

SELECT *
FROM stud.egzempliorius AS egz
JOIN stud.knyga AS kn
ON egz.isbn = kn.isbn;

SELECT egz.nr, kn.pavadinimas, kn.leidykla
FROM stud.egzempliorius AS egz
JOIN stud.knyga AS kn
ON egz.isbn = kn.isbn;

SELECT *
FROM stud.egzempliorius AS egz
JOIN stud.knyga AS kn
ON egz.isbn = kn.isbn
WHERE LOWER(TRIM(kn.pavadinimas)) = 'objektinis programavimas';

SELECT nr, pavadinimas
FROM stud.knyga AS kn, 
    stud.egzempliorius AS egz
WHERE egz.isbn = kn.isbn;

SELECT egz.Nr, vardas, pavarde
FROM stud.egzempliorius AS egz, 
    stud.skaitytojas AS sk
WHERE egz.skaitytojas = sk.nr;

SELECT sk.pavarde, egz.nr
FROM stud.egzempliorius egz,
    stud.skaitytojas sk
WHERE egz.skaitytojas = sk.nr AND
    sk.nr = 1000;

SELECT gimimas, 
    COUNT(*)
FROM stud.skaitytojas sk
GROUP BY gimimas;

-- ND 
-- join , =
-- left join
-- right join
-- outer join
-- table ir table
