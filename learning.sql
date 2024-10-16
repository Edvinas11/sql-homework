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

-- ND 
-- https://joins.spathon.com/
-- join , =
-- left join
-- right join
-- outer join
-- table ir table

-- Join/Inner Join = Keep only that which matches
-- Left join = Keep every thing from left table, only matches from right table
-- Right join = Keep everything from right table, only matches from left table
-- Outer join = Keep everything

SELECT *
FROM stud.knyga AS kn,
    stud.autorius AS au
WHERE kn.isbn = au.isbn;

SELECT kn.isbn, kn.pavadinimas, eg.nr, eg.skaitytojas
FROM stud.knyga kn
JOIN stud.egzempliorius eg
ON kn.isbn = eg.isbn;

SELECT kn.isbn, kn.pavadinimas, eg.nr, eg.skaitytojas
FROM stud.knyga kn
LEFT JOIN stud.egzempliorius eg
ON kn.isbn = eg.isbn;

SELECT kn.isbn, kn.pavadinimas, eg.nr, eg.skaitytojas
FROM stud.knyga kn
RIGHT JOIN stud.egzempliorius eg
ON kn.isbn = eg.isbn;

SELECT kn.isbn, kn.pavadinimas, eg.nr, eg.skaitytojas
FROM stud.knyga kn
FULL OUTER JOIN stud.egzempliorius eg
ON kn.isbn = eg.isbn;

SELECT kn1.isbn AS isbn1, kn1.pavadinimas AS book1,
    kn2.isbn AS isbn2, kn2.pavadinimas AS book2
FROM stud.knyga kn1
JOIN stud.knyga kn2
ON kn1.puslapiai = kn2.puslapiai AND
    kn1.isbn <> kn2.isbn;

SELECT kn1.isbn AS isbn1, kn1.pavadinimas AS book1,
    kn2.isbn AS isbn2, kn2.pavadinimas AS book2
FROM stud.knyga kn1, stud.knyga kn2
WHERE kn1.puslapiai = kn2.puslapiai AND
    kn1.isbn != kn2.isbn;

SELECT kn1.isbn AS isbn1, kn1.pavadinimas AS book1,
    kn2.isbn AS isbn2, kn2.pavadinimas AS book2
FROM stud.knyga kn1
JOIN stud.knyga kn2
ON kn1.puslapiai = kn2.puslapiai AND
    kn1.isbn <> kn2.isbn;

SELECT eg.nr, eg.paimta, eg.grazinti, 
    sk.vardas, sk.pavarde, kn.pavadinimas
FROM stud.egzempliorius eg
JOIN stud.knyga kn
ON eg.isbn = kn.isbn
JOIN stud.skaitytojas sk
ON eg.skaitytojas = sk.nr;

SELECT eg.nr, eg.paimta, eg.grazinti, 
    sk.vardas, sk.pavarde, kn.pavadinimas
FROM stud.egzempliorius eg, 
    stud.knyga kn,
    stud.skaitytojas sk
WHERE eg.isbn = kn.isbn 
    AND eg.skaitytojas = sk.nr;

-- get all egzemplioriai with titles
SELECT Nr, Pavadinimas 
FROM Stud.Knyga kn, Stud.Egzempliorius eg
WHERE eg.isbn = kn.isbn;

SELECT Nr, Pavadinimas 
FROM Stud.Knyga kn, Stud.Egzempliorius eg
WHERE eg.isbn = kn.isbn
ORDER BY Nr;

SELECT Nr, Pavadinimas 
FROM Stud.Knyga kn, Stud.Egzempliorius eg
WHERE eg.isbn = kn.isbn
ORDER BY 2 DESC;

SELECT CAST(AVG(COALESCE(kn.verte, 0)) AS DECIMAL(6, 2))
FROM stud.knyga kn
LEFT JOIN stud.autorius au
ON kn.isbn = au.isbn
WHERE INITCAP(au.vardas)='Jonas' AND
    INITCAP(au.pavarde)='Jonaitis';

SELECT kn.isbn, 
    au.vardas,
    au.pavarde,
    kn.pavadinimas,
    eg.nr,
    sk.vardas,
    sk.pavarde
FROM stud.knyga kn
LEFT JOIN stud.autorius au
ON kn.isbn = au.isbn
JOIN stud.egzempliorius eg
ON au.isbn = eg.isbn
LEFT JOIN stud.skaitytojas sk
ON eg.skaitytojas = sk.nr
WHERE INITCAP(au.vardas)='Jonas' AND
    INITCAP(au.pavarde)='Jonaitis';

-- GROUP BY

SELECT gimimas, COUNT(*)
FROM stud.skaitytojas sk
GROUP BY gimimas;

SELECT kn.isbn, kn.pavadinimas, COUNT(*) AS Kiekis
FROM stud.knyga kn, 
    stud.egzempliorius eg
WHERE eg.isbn = kn.isbn
GROUP BY kn.isbn;

SELECT kn.isbn, kn.pavadinimas, COUNT(*) AS Kiekis
FROM stud.knyga kn, 
    stud.egzempliorius eg
WHERE kn.isbn = eg.isbn
GROUP BY kn.isbn
HAVING COUNT(*) > 2;

SELECT sk.vardas, 
    sk.pavarde,
    eg.paimta,
    COUNT(*) AS Paimta
FROM stud.skaitytojas sk,
    stud.egzempliorius eg
WHERE sk.nr = eg.skaitytojas
GROUP BY sk.vardas, 
    sk.pavarde,
    eg.paimta
HAVING COUNT(*) > 0
ORDER BY sk.vardas, eg.paimta;

-- use GROUP BY CUBE
-- prideda sumine eilute
SELECT kn.leidykla,
    CAST(SUM(COALESCE(kn.verte, 0)) AS DECIMAL(6,1))
FROM stud.knyga kn
GROUP BY CUBE(kn.leidykla);

-- papildo suminėmis eil.
-- pagal visas grupavimo stulpelių kombinacijas
SELECT kn.leidykla,
    kn.pavadinimas,
    CAST(SUM(COALESCE(kn.verte, 0)) AS DECIMAL(6,1))
FROM stud.knyga kn
GROUP BY CUBE(kn.leidykla, kn.pavadinimas);

-- GROUP BY ROLLUP
-- sumos kaupiamos tik kairiau
-- esantiems grupavimo stulpeliams
SELECT kn.leidykla,
    kn.pavadinimas,
    CAST(SUM(COALESCE(kn.verte, 0)) AS DECIMAL(6,1))
FROM stud.knyga kn
GROUP BY ROLLUP(kn.leidykla, kn.pavadinimas);



