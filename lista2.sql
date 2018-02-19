ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

--17
-- Wyświetlić określoną pseudonimami drogę służbową (przez wszystkich kolejnych przełożonych do głównego szefa) kotów płci męskiej 
-- o stażu dłuższym niż osiem lat (w poniższym rozwiązaniu datą bieżącą jest 11.07.2017) nie posiadających dodatkowego przydziału myszy.

SELECT
    pseudo "POLUJE W POLU", 
    przydzial_myszy "PRZYDZIAL MYSZY", 
    nazwa "BANDA"
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE teren in ('POLE', 'CALOSC') AND NVL(przydzial_myszy,0) > 50;

--18
-- Wyświetlić bez stosowania podzapytania imiona i daty przystąpienia do stada
-- kotów, które przystąpiły do stada przed kotem o imieniu ’JACEK’. Wyniki uporządkować
-- malejąco wg daty przystąpienia do stadka.

SELECT K1.imie, K1.w_stadku_od "POLUJE OD"
FROM Kocury K1 
    JOIN Kocury K2 ON K2.imie = 'JACEK' AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY K1.w_stadku_od DESC;

--19
-- Dla kotów pełniących funkcję KOT i MILUSIA wyświetlić w kolejności hierarchii
-- imiona wszystkich ich szefów. Zadanie rozwiązać na trzy sposoby:
--      a. z wykorzystaniem tylko złączeń,
--      b. z wykorzystaniem drzewa, operatora CONNECT_BY_ROOT i tabel przestawnych,
--      c. z wykorzystaniem drzewa i funkcji SYS_CONNECT_BY_PATH i operatora CONNECT_BY_ROOT

--a
SELECT 
    K1.imie "Imie", 
     ' | ' " ",
    K1.funkcja, NVL(K2.imie, ' ') "szef 1", 
     ' | ' "  ",
    NVL(K3.imie, ' ') "szef 2", 
     ' | ' "   ",
    NVL(K4.imie, ' ') "szef 3"
FROM Kocury K1 
    LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo 
    LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo 
    LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo
WHERE K1.funkcja = 'MILUSIA' OR K1.funkcja = 'KOT';

--b
SELECT 
    "Imie",
     ' | ' " ",
    "Funkcja",
    ' | ' "  ",
    "Szef 1",
    ' | ' "   ",
    "Szef 2",
    ' | ' "    ",
    "Szef 3"
FROM
  (SELECT
      imie "Imie szefa",
      LEVEL "Poziom",
      CONNECT_BY_ROOT imie "Imie",
      CONNECT_BY_ROOT funkcja "Funkcja"
    FROM Kocury
    WHERE CONNECT_BY_ROOT pseudo != pseudo
    CONNECT BY PRIOR szef = pseudo
    START WITH funkcja IN ('MILUSIA', 'KOT')) 
PIVOT (
  MAX("Imie szefa")
  FOR ("Poziom")
  IN
  (
    '2' "Szef 1",
    '3' "Szef 2",
    '4' "Szef 3"));

--c
SELECT
  CONNECT_BY_ROOT imie "Imie",
  ' | ' "   ",
  CONNECT_BY_ROOT funkcja "Funkcja",
  SUBSTR(SYS_CONNECT_BY_PATH(RPAD(IMIE, 12), '| ') || '|', 14, 38) "Imiona kolejnych szefów"
FROM KOCURY
WHERE CONNECT_BY_ISLEAF = 1
CONNECT BY PRIOR SZEF = PSEUDO
START WITH FUNKCJA IN ('MILUSIA', 'KOT');

--20 
-- Wyświetlić imiona wszystkich kotek, które uczestniczyły w incydentach po
-- 01.01.2007. Dodatkowo wyświetlić nazwy band do których należą kotki, imiona ich wrogów
-- wraz ze stopniem wrogości oraz datę incydentu.

SELECT 
    K.imie "Imie kotki", 
    B.nazwa "Nazwa bandy", 
    W.imie_wroga "Imie wroga", 
    W.stopien_wrogosci "Ocena wroga",
    WK.data_incydentu
FROM Kocury K 
	JOIN Bandy B ON K.nr_bandy = B.nr_bandy 
	JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo
    JOIN Wrogowie W ON W.imie_wroga = WK.imie_wroga
WHERE K.plec = 'D' AND WK.data_incydentu > '2007-01-01'; 


--21
-- Określić ile kotów w każdej z band posiada wrogów

SELECT nazwa "Nazwa bandy", COUNT(DISTINCT K.pseudo) "Koty z wrogami"
FROM Kocury K 
    JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo
    JOIN Bandy B ON B.nr_bandy = K.nr_bandy 
GROUP BY nazwa;

--22
-- Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.

SELECT K.funkcja "Funkcja", K.pseudo "Pseudonim kota", WK.LW "Liczba Wrogow"
FROM Kocury K 
    JOIN (SELECT pseudo, COUNT(*) "LW"
    FROM Wrogowie_Kocurow 
    GROUP BY pseudo
    HAVING COUNT(*) > 1) WK 
    ON K.pseudo = WK.pseudo;

--23
-- Wyświetlić imiona kotów, które dostają „myszą” premię wraz z ich całkowitym
-- rocznym spożyciem myszy. Dodatkowo jeśli ich roczna dawka myszy przekracza 864
-- wyświetlić tekst ’powyzej 864’, jeśli jest równa 864 tekst ’864’, jeśli jest mniejsza od 864
-- tekst ’poniżej 864’. Wyniki uporządkować malejąco wg rocznej dawki myszy. Do
-- rozwiązania wykorzystać operator zbiorowy UNION.

SELECT *
FROM
(SELECT imie "IMIE", (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
FROM Kocury
WHERE myszy_extra IS NOT NULL AND (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12 > 864)
UNION
(SELECT imie "IMIE", (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 "DAWKA ROCZNA", '864' "DAWKA"
FROM Kocury
WHERE myszy_extra IS NOT NULL AND (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 = 864)
UNION
(SELECT imie "IMIE", (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
FROM Kocury
WHERE myszy_extra IS NOT NULL AND (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12 < 864)
ORDER BY "DAWKA ROCZNA" DESC;

--24
-- Znaleźć bandy, które nie posiadają członków. Wyświetlić ich numery, nazwy i
-- tereny operowania. Zadanie rozwiązać na dwa sposoby: bez podzapytań i operatorów
-- zbiorowych oraz wykorzystując operatory zbiorowe.

SELECT 
    B.nr_bandy "NR BANDY", 
    nazwa, 
    teren 
FROM Bandy B LEFT JOIN Kocury K ON B.nr_bandy = K.nr_bandy
WHERE K.pseudo IS NULL;

(SELECT 
    nr_bandy "NR BANDY",
    nazwa,
    teren
FROM Bandy)
MINUS
(SELECT
    B.nr_bandy,
    nazwa,
    teren
FROM Bandy B JOIN Kocury K ON B.nr_bandy = K.nr_bandy); 


--25
-- Znaleźć koty, których przydział myszy jest nie mniejszy od potrojonego
-- najwyższego przydziału spośród przydziałów wszystkich MILUŚ operujących w SADZIE.
-- Nie stosować funkcji MAX.

SELECT 
    imie "IMIE", 
    funkcja "FUNKCJA", 
    przydzial_myszy "PRZYDZIAL MYSZY"
FROM Kocury 
WHERE przydzial_myszy >= ALL
	(SELECT przydzial_myszy * 3 
	FROM Kocury JOIN Bandy USING (nr_bandy)
	WHERE funkcja = 'MILUSIA' AND teren IN ('SAD', 'CALOSC'));

--26
-- Znaleźć funkcje (pomijając SZEFUNIA), z którymi związany jest najwyższy i
-- najniższy średni całkowity przydział myszy. Nie używać operatorów zbiorowych (UNION,
-- INTERSECT, MINUS).

SELECT funkcja "Funkcja", ROUND(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "SR" 
FROM Kocury
WHERE funkcja != 'SZEFUNIO'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) IN (
    (SELECT MAX(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) 
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja),
    
    (SELECT MIN(AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)))
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja));

--27
-- Znaleźć koty zajmujące pierwszych n miejsc pod względem całkowitej liczby
-- spożywanych myszy (koty o tym samym spożyciu zajmują to samo miejsce!). Zadanie
-- rozwiązać na cztery sposoby:
--      a. wykorzystując podzapytanie skorelowane,
--      b. wykorzystując pseudokolumnę ROWNUM,
--      c. wykorzystując złączenie relacji Kocury z relacją Kocury
--      d. wykorzystując funkcje analityczne.

--a
SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) ZJADA
FROM KOCURY K
WHERE (SELECT COUNT(*)
      FROM
        (SELECT NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) 
        FROM KOCURY
        GROUP BY NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
        HAVING NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
             >= NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0))) <= 6
ORDER BY 2 DESC;

--b
SELECT pseudo, NVL(przydzial_myszy, 0) + NVL(myszy_extra,0) "ZJADA"
FROM Kocury
WHERE NVL(przydzial_myszy, 0) + NVL(myszy_extra,0) IN 
    (SELECT *
    FROM (SELECT NVL(przydzial_myszy, 0) + NVL(myszy_extra,0)
            FROM Kocury
            GROUP BY NVL(przydzial_myszy, 0) + NVL(myszy_extra,0)
            ORDER BY 1 DESC)
    WHERE rownum <= 6);
    
--c
SELECT 
    K1.pseudo, 
    NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra,0) "ZJADA"
FROM Kocury K1 LEFT JOIN 
    Kocury K2 ON NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra,0) < NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra,0)
GROUP BY K1.pseudo, K1.przydzial_myszy, K1.myszy_extra
HAVING COUNT(*) <= 6
ORDER BY NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra,0) DESC;

--d

SELECT 
    pseudo, 
    ZJADA
FROM 
    (SELECT 
        pseudo, 
        NVL(przydzial_myszy, 0) + NVL(myszy_extra,0) "ZJADA", 
        DENSE_RANK()
        OVER (ORDER BY NVL(przydzial_myszy, 0) + NVL(myszy_extra,0) DESC) pozycja
    FROM Kocury)
WHERE pozycja <= 6;


--28
-- Określić lata, dla których liczba wstąpień do stada jest najbliższa (od góry i od dołu)
-- średniej liczbie wstąpień dla wszystkich lat (średnia z wartości określających liczbę wstąpień
-- w poszczególnych latach). Nie stosować perspektywy.

SELECT
    TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
    COUNT(*) "LICZBA WSTAPIEN"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
HAVING COUNT(*) = 
    (SELECT *
    FROM 
    (SELECT COUNT(*)
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(*) <= (SELECT AVG(COUNT(*))
                               FROM KOCURY
                               GROUP BY EXTRACT(YEAR FROM w_stadku_od))
      ORDER BY COUNT(*) DESC)
    WHERE ROWNUM = 1)

UNION

SELECT
    'Srednia' "ROK",
    ROUND(AVG(COUNT(*)), 7) "LICZBA WSTAPIEN"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)

UNION

SELECT
    TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
    COUNT(*) "LICZBA WSTAPIEN"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
HAVING COUNT(*) = 
    (SELECT *
    FROM 
    (SELECT COUNT(*)
      FROM KOCURY
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(*) >= (SELECT AVG(COUNT(*))
                               FROM KOCURY
                               GROUP BY EXTRACT(YEAR FROM w_stadku_od))
      ORDER BY COUNT(*) ASC)
    WHERE ROWNUM = 1)
ORDER BY 2;

--29
-- Dla kocurów (płeć męska), dla których całkowity przydział myszy nie przekracza
-- średniej w ich bandzie wyznaczyć następujące dane: imię, całkowite spożycie myszy, numer
-- bandy, średnie całkowite spożycie w bandzie. Nie stosować perspektywy. Zadanie rozwiązać
-- na trzy sposoby:
--      a. ze złączeniem ale bez podzapytań,
--      b. ze złączenie i z jedynym podzapytaniem w klauzurze FROM,
--      c. bez złączeń i z dwoma podzapytaniami: w klauzurach SELECT i WHERE.

--a zlaczenie, bez podzapytan
SELECT 
    K1.imie,
    NVL(K1.przydzial_myszy,0) + NVL(K1.myszy_extra,0) "ZJADA", 
    K1.nr_bandy "NR BANDY",
    AVG(NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0)) "SREDNIA BANDY"
FROM Kocury K1 JOIN Kocury K2 ON K1.nr_bandy = K2.nr_bandy 
WHERE K1.plec = 'M'
GROUP BY K1.imie, K1.przydzial_myszy, K1.myszy_extra, K1.nr_bandy
HAVING NVL(K1.przydzial_myszy,0) + NVL(K1.myszy_extra,0) < AVG(NVL(K2.przydzial_myszy,0) + NVL(K2.myszy_extra,0));

--b zlaczenie, podzapytanie w klauzurze FROM
SELECT 
    imie,
    NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA", 
    K.nr_bandy "NR BANDY",
    sre "SREDNIA BANDY"
FROM Kocury K JOIN 
    (SELECT nr_bandy, AVG(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) sre
    FROM Kocury
    GROUP BY nr_bandy) SR ON K.nr_bandy = SR.nr_bandy 
WHERE plec = 'M' AND NVL(przydzial_myszy,0) + NVL(myszy_extra,0) <= sre;

--c bez zlaczen, dwa podzapytania w SELECT, WHERE
SELECT 
    imie,
    NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA", 
    nr_bandy "NR BANDY",
    (SELECT AVG(NVL(przydzial_myszy,0) + NVL(myszy_extra,0))
    FROM Kocury
    WHERE nr_bandy = K.nr_bandy) "SREDNIA BANDY"
FROM Kocury K
WHERE plec = 'M' AND NVL(przydzial_myszy,0) + NVL(myszy_extra,0) <= 
    (SELECT AVG(NVL(przydzial_myszy,0) + NVL(myszy_extra,0))
    FROM Kocury
    WHERE nr_bandy = K.nr_bandy);
    
--30
-- Wygenerować listę kotów z zaznaczonymi kotami o najwyższym i o najniższym
-- stażu w swoich bandach. Zastosować operatory zbiorowe.

(SELECT 
    K.imie,
    w_stadku_od || '<---' "WSTAPIL DO STADKA",
    'NAJSTARSZY STAZEM W BANDZIE ' || nazwa "  "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE w_stadku_od < ALL 
    (SELECT w_stadku_od 
    FROM Kocury
    WHERE pseudo != K.pseudo AND nr_bandy = K.nr_bandy))  
UNION
(SELECT 
    K.imie,
    w_stadku_od || '<---' "WSTAPIL DO STADKA",
    'NAJMLODSZY STAZEM W BANDZIE ' || nazwa "  "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE w_stadku_od > ALL 
    (SELECT w_stadku_od 
    FROM Kocury
    WHERE pseudo != K.pseudo AND nr_bandy = K.nr_bandy))
UNION
(SELECT 
    imie,
    w_stadku_od || '    ' "WSTAPIL DO STADKA",
    '  ' "  "
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE w_stadku_od > ANY 
    (SELECT w_stadku_od 
    FROM Kocury
    WHERE pseudo != K.pseudo AND nr_bandy = K.nr_bandY)
    AND
    w_stadku_od < ANY 
    (SELECT w_stadku_od 
    FROM Kocury
    WHERE pseudo != K.pseudo AND nr_bandy = K.nr_bandy));

--31
-- Zdefiniować perspektywę wybierającą następujące dane: nazwę bandy, średni,
-- maksymalny i minimalny przydział myszy w bandzie, całkowitą liczbę kotów w bandzie oraz
-- liczbę kotów pobierających w bandzie przydziały dodatkowe. Posługując się zdefiniowaną
-- perspektywą wybrać następujące dane o kocie, którego pseudonim podawany jest
-- interaktywnie z klawiatury: pseudonim, imię, funkcja, przydział myszy, minimalny i
-- maksymalny przydział myszy w jego bandzie oraz datę wstąpienia do stada.

CREATE VIEW Info_bandy
AS
SELECT 
    nazwa "NAZWA_BANDY", 
    AVG(NVL(przydzial_myszy,0)) "SRE_SPOZ", 
    MAX(NVL(przydzial_myszy,0)) "MAX_SPOZ", 
    MIN(NVL(przydzial_myszy,0)) "MIN_SPOZ", 
    COUNT(*) "KOTY",
    COUNT(myszy_extra) "KOTY_Z_DOD"
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
GROUP BY K.nr_bandy, nazwa;
---PO CO PO TYM I PO TYM GRUPOWAC?

SELECT 
    pseudo "PSEUDONIM",
    imie,
    funkcja,
    NVL(przydzial_myszy,0) "ZJADA",
    'OD ' || I.MIN_SPOZ || ' DO ' || I.MAX_SPOZ  "GRANICE SPOZYCIA",
    w_stadku_od "LOWI OD"
FROM Kocury K JOIN
    Bandy B ON K.nr_bandy = B.nr_bandy JOIN 
    Info_bandy I ON I.NAZWA_BANDY = B.nazwa
WHERE pseudo = '&x';

--32
-- Dla kotów o trzech najdłuższym stażach w połączonych bandach CZARNI
-- RYCERZE i ŁACIACI MYŚLIWI zwiększyć przydział myszy o 10% minimalnego
-- przydziału w całym stadzie lub o 10 w zależności od tego czy podwyżka dotyczy kota płci
-- żeńskiej czy kota płci męskiej. Przydział myszy extra dla kotów obu płci zwiększyć o 15%
-- średniego przydziału extra w bandzie kota. Wyświetlić na ekranie wartości przed i po
-- podwyżce a następnie wycofać zmiany.

CREATE VIEW Spozycie_bandy
AS
SELECT 
    K.nr_bandy "NR BANDY",
    nazwa "NAZWA_BANDY",  
    MAX(NVL(przydzial_myszy,0)) "MAX_SPOZ", 
    MIN(NVL(przydzial_myszy,0)) "MIN_SPOZ",
    AVG(NVL(myszy_extra,0)) "SRE_EXTRA",
    (SELECT MIN(przydzial_myszy)
    FROM Kocury) "MIN_W_STADZIE"
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
GROUP BY K.nr_bandy, nazwa;


CREATE OR REPLACE VIEW Najlepsze_koty
AS
(SELECT pseudo
FROM
    (SELECT 
        pseudo,
        nazwa,
        DENSE_RANK()
        OVER (PARTITION BY nr_bandy
        ORDER BY w_stadku_od) pozycja
    FROM Kocury JOIN Bandy USING(nr_bandy))
WHERE pozycja <= 3 AND nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI'));

SELECT 
    pseudo,
    plec,
    NVL(przydzial_myszy, 0) "Myszy przed podw.", 
    NVL(myszy_extra, 0) "Extra przed podw."
FROM Najlepsze_koty JOIN Kocury USING(pseudo);

UPDATE Kocury K
SET przydzial_myszy = 
    przydzial_myszy + 
    DECODE(plec, 'D', 0.1 * (SELECT MIN(przydzial_myszy) FROM Kocury), 10),

myszy_extra = 
    NVL(myszy_extra,0) + 
    0.15 * (SELECT AVG(NVL(myszy_extra,0)) FROM Kocury K1 WHERE K.nr_bandy = K1.nr_bandy)
WHERE pseudo IN (SELECT pseudo FROM Najlepsze_koty);

SELECT 
    pseudo,
    plec,
    NVL(przydzial_myszy, 0) "Myszy po podw.", 
    NVL(myszy_extra, 0) "Extra pod podw."
FROM Najlepsze_koty JOIN Kocury USING(pseudo);

ROLLBACK;
    
    
