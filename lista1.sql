ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

--1 
-- Znajdź imiona wrogów, którzy dopuścili się incydentów w 2009r.

SELECT 
	imie_wroga "WROG", 
	opis_incydentu "PRZEWINA"
FROM Wrogowie_Kocurow
WHERE data_incydentu LIKE '2009%';


--2
-- Znajdź wszystkie kotki (płeć żeńska), które przystąpiły do stada między 1 września 2005r. a 31 lipca 2007r.
SELECT 
	imie, 
	funkcja,
	w_stadku_od "Z NAMI OD"
FROM Kocury
WHERE plec = 'D' AND w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31';

--3
-- Wyświetl imiona, gatunki i stopnie wrogości nieprzekupnych wrogów. 
-- Wyniki mają być uporządkowane rosnąco według stopnia wrogości.

SELECT 
	imie_wroga "WROG", 
	gatunek, 
	stopien_wrogosci "STOPIEN WROGOSCI"
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

--4 
-- Wyświetlić dane o kotach płci męskiej zebrane w jednej kolumnie postaci:
-- JACEK zwany PLACEK (fun. LOWCZY) lowi myszki w bandzie2 od 2008-12-01
-- Wyniki należy uporządkować malejąco wg daty przystąpienia do stada. 
-- W przypadku tej samej daty przystąpienia wyniki uporządkować alfabetycznie wg  pseudonimów.

SELECT imie || ' zwany ' || pseudo || ' (fun. ' || funkcja || ') lowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od "WSZYSTKO O KOCURACH"
FROM Kocury
WHERE plec = 'M'
ORDER BY w_stadku_od DESC, pseudo;

--5
-- Znaleźć pierwsze wystąpienie litery A i pierwsze wystąpienie litery L w każdym pseudonimie a następnie zamienić znalezione litery
-- na odpowiednio # i %. Wykorzystać funkcje działające na łańcuchach. Brać pod uwagę tylko te imiona, w których występują obie litery.

SELECT 
	pseudo, 
	REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'A', '#', 1, 1), 'L', '%', 1, 1) "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';


--6
-- Wyświetlić imiona kotów z co najmniej ośmioletnim stażem (które dodatkowo przystępowały do stada od 1 marca do 30 września), 
-- daty ich przystąpienia do stada, początkowy przydział myszy (obecny przydział, ze względu na podwyżkę po pół roku członkostwa,  
-- jest o 10% wyższy od początkowego) , datę wspomnianej podwyżki o 10% oraz aktualnym przydział myszy. 
-- Wykorzystać odpowiednie funkcje działające na datach. W poniższym rozwiązaniu datą bieżącą jest 11.07.2017

SELECT 
	imie,
	w_stadku_od "W STADKU", 
	round(przydzial_myszy / 1.1) "ZJADAL", 
	ADD_MONTHS(w_stadku_od, 6) "PODWYZKA", 
	przydzial_myszy "ZJADA"
FROM Kocury
WHERE (MONTHS_BETWEEN(SYSDATE, w_stadku_od) / 12) >= 8 
	AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9;

--7
-- Wyświetlić imiona, kwartalne przydziały myszy i kwartalne przydziały dodatkowe dla wszystkich kotów, 
-- u których przydział myszy jest większy od dwukrotnego przydziału dodatkowego ale nie mniejszy od 55.

SELECT 
	imie, 
	NVL(przydzial_myszy, 0) * 3 "MYSZY KWARTALNIE", 
	NVL(myszy_extra, 0) * 3 "KWARTALNE DODATKI"
FROM Kocury
WHERE NVL(przydzial_myszy, 0) > NVL(myszy_extra, 0) * 2 AND NVL(przydzial_myszy, 0) >= 55;

--8
-- Wyświetlić dla każdego kota (imię) następujące informacje o całkowitym rocznym spożyciu myszy: 
-- wartość całkowitego spożycia jeśli przekracza 660, ’Limit’ jeśli jest równe 660, ’Ponizej 660’ jeśli jest mniejsze od 660. 
-- Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).

SELECT 
	imie, 
	CASE 
		WHEN (przydzial_myszy + NVL(myszy_extra, 0)) * 12 < 660 THEN 'Ponizej 660'
		WHEN (przydzial_myszy + NVL(myszy_extra, 0)) * 12 = 660 THEN 'Limit'
		ELSE (przydzial_myszy + NVL(myszy_extra, 0)) * 12 || ''
	END "Zjada rocznie"
FROM Kocury;

-- 9
-- Po kilkumiesięcznym, spowodowanym kryzysem, zamrożeniu wydawania myszy Tygrys z dniem bieżącym wznowił wypłaty zgodnie z zasadą, że koty,
-- które przystąpiły do stada w pierwszej połowie miesiąca (łącznie z 15-m) otrzymują pierwszy po przerwie przydział myszy
-- w ostatnią środę bieżącego miesiąca, natomiast koty, które przystąpiły do stada po 15-ym, 
-- pierwszy po przerwie przydział myszy otrzymują w ostatnią środę następnego miesiąca.
-- W kolejnych miesiącach myszy wydawane są wszystkim kotom w ostatnią środę każdego miesiąca. 
-- Wyświetlić dla każdego kota jego pseudonim, datę przystąpienia do stada oraz datę pierwszego po przerwie przydziału myszy,
-- przy założeniu, że  datą bieżącą jest 23 i 26 październik 2017.

SELECT
	pseudo,
	w_stadku_od "W stadku",
	CASE
		WHEN EXTRACT(MONTH FROM NEXT_DAY('2017-10-23', 3)) = 10 THEN
			CASE
				WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 THEN NEXT_DAY('2017-10-23', 3)
				ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-23', 1)) - 7, 3)
			END
		ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-23', 1)) - 7 , 3)
	END "Wyplata"S
FROM Kocury;

SELECT 
	pseudo,
	w_stadku_od "W stadku",
	CASE 
		WHEN EXTRACT(MONTH FROM NEXT_DAY('2017-10-26', '�RODA')) = 10 THEN
			CASE 
				WHEN EXTRACT(DAY FROM w_stadku_od) <= 15 THEN NEXT_DAY('2017-10-26', '�RODA')
				ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-26', 1)) - 7, '�RODA')
			END
		ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2017-10-26', 1)) - 7 , '�RODA')
	END "Wyplata"
FROM Kocury;

--10 
-- Atrybut pseudo w tabeli Kocury jest kluczem głównym tej tabeli. 
-- Sprawdzić, czy rzeczywiście wszystkie pseudonimy są wzajemnie różne. Zrobić to samo dla atrybutu szef.

SELECT 
	pseudo || 
	CASE COUNT(*)
		WHEN 1 THEN ' - UNIKALNY'
		ELSE ' - NIEUNIKALNY' 
    END "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo;

SELECT 
	szef || 
	CASE COUNT(*)
		WHEN 1 THEN ' - UNIKALNY'
		ELSE ' - NIEUNIKALNY' 
    END "Unikalnosc atr. SZEF"
FROM Kocury
WHERE  NOT (szef IS NULL) 
GROUP BY szef;

--11
-- Znaleźć pseudonimy kotów posiadających co najmniej dwóch wrogów.

SELECT 
	pseudo "Pseudonim",
	COUNT(pseudo) "Liczba wrogow"
FROM Wrogowie_Kocurow
GROUP BY pseudo
HAVING COUNT(*) >= 2;

--12
-- Znaleźć maksymalny całkowity przydział myszy dla wszystkich grup funkcyjnych (z pominięciem SZEFUNIA i kotów płci męskiej) 
-- o średnim całkowitym przydziale (z uwzględnieniem dodatkowych przydziałów – myszy_extra) większym  od 50.

SELECT 
	'Liczba kotow = ' " ",
    COUNT(*) " ",
    ' lowi jako ' " ",
    funkcja " ",
    ' i zjada max. ' " ",
    MAX(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) " ",
    ' myszy miesiecznie' " "
FROM Kocury
WHERE funkcja != 'SZEFUNIO' AND plec = 'D'
GROUP BY funkcja
HAVING AVG(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) > 50;

--13
-- Wyświetlić minimalny przydział myszy w każdej bandzie z podziałem na płcie.

SELECT 
	nr_bandy "Nr bandy", 
	plec "Plec", 
	MIN(przydzial_myszy) "Minimalny przydzial myszy"
FROM Kocury
GROUP BY nr_bandy, plec;

--14
-- Wyświetlić informację o kocurach (płeć męska) posiadających w hierarchii przełożonych 
-- szefa pełniącego funkcję BANDZIOR (wyświetlić także dane tego przełożonego). 
-- Dane kotów podległych konkretnemu szefowi mają być wyświetlone zgodnie z ich miejscem w hierarchii podległości.

SELECT 
	level "Poziom", 
	pseudo "Pseudonim", 
	funkcja "Funkcja", 
	nr_bandy "Nr bandy"
FROM Kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo = szef
START WITH funkcja = 'BANDZIOR';

--15
-- Przedstawić informację o podległości kotów posiadających dodatkowy przydział myszy tak aby imię kota stojącego najwyżej w hierarchii
-- było wyświetlone z najmniejszym wcięciem a pozostałe imiona z wcięciem odpowiednim do miejsca w hierarchii.

SELECT 
    lpad('===>', (level - 1) * 4, '===>') || (level - 1) || lpad(' ', 10) || imie "Hierarchia", 
    NVL(szef, 'sam sobie szefem') "Pseudo szefa", 
    funkcja "Funkcja"
FROM Kocury
WHERE NVL(myszy_extra, 0) != 0
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

--16
-- Wyświetlić określoną pseudonimami drogę służbową (przez wszystkich kolejnych przełożonych do głównego szefa) 
-- kotów płci męskiej o stażu dłuższym niż osiem lat (w poniższym rozwiązaniu datą bieżącą jest 11.07.2017) 
-- nie posiadających dodatkowego przydziału myszy. 

SELECT 
	lpad(' ', (level - 1) * 4) || pseudo "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH myszy_extra IS NULL AND plec = 'M' AND (MONTHS_BETWEEN('2017-07-11', w_stadku_od) / 12) > 8;

SELECT 
	lpad(' ', (level - 1) * 4) || pseudo "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH myszy_extra IS NULL AND plec = 'M' AND (MONTHS_BETWEEN(SYSDATE, w_stadku_od) / 12) > 8;

