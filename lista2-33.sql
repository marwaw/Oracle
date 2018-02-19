--33
-- Napisać zapytanie, w ramach którego obliczone zostaną sumy całkowitego spożycia
-- myszy przez koty sprawujące każdą z funkcji z podziałem na bandy i płcie kotów.
-- Podsumować przydziały dla każdej z funkcji. Zadanie wykonać na dwa sposoby:
--     a. z wykorzystaniem tzw. raportu macierzowego,
--     b. z wykorzystaniem klauzuli PIVOT

--a
SELECT
    DECODE(plec, 'Kocur', ' ', nazwa) "NAZWA BANDY",
    PLEC,
    SZEFUNIO,
    BANDZIOR,
    LOWCZY,
    LAPACZ,
    KOT,
    MILUSIA,
    DZIELCZY,
    SUMA
FROM
(SELECT 
    nazwa,
    DECODE(plec, 'D', 'Kotka', 'Kocur') "PLEC",
    TO_CHAR(COUNT(*)) "ILE",
    TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) "SZEFUNIO",
    TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) "BANDZIOR",
    TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) "LOWCZY",
    TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) "LAPACZ",
    TO_CHAR(SUM(DECODE(funkcja, 'KOT', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) "KOT",
    TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) "MILUSIA",
    TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0))) "DZIELCZY",
    TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "SUMA"
FROM Kocury JOIN Bandy USING(nr_bandy)
GROUP BY nazwa, plec

UNION

SELECT
      'Z----------------' nazwa,
      '------' plec,
      '----',
      '---------',
      '---------',
      '---------',
      '---------',
      '---------',
      '---------',
      '---------',
      '-------'
FROM DUAL

UNION

SELECT
    'ZJADA RAZEM' nazwa,
    '      ' plec,
    '    ',
    TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'KOT', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)))
FROM Kocury
ORDER BY nazwa, plec DESC);

--b
SELECT
    DECODE(plec, 'Kocur', ' ', nazwa) "NAZWA BANDY",
    PLEC,
    SZEFUNIO,
    BANDZIOR,
    LOWCZY,
    LAPACZ,
    KOT,
    MILUSIA,
    DZIELCZY,
    SUMA
FROM

(SELECT 
    nazwa,
    DECODE(plec, 'D', 'Kotka', 'Kocur') "PLEC",
    TO_CHAR(ILE) ILE,
    TO_CHAR(NVL(SZEFUNIO,0)) SZEFUNIO,
    TO_CHAR(NVL(BANDZIOR,0)) BANDZIOR,
    TO_CHAR(NVL(LOWCZY,0)) LOWCZY,
    TO_CHAR(NVL(LAPACZ,0)) LAPACZ,
    TO_CHAR(NVL(KOT,0)) KOT,
    TO_CHAR(NVL(MILUSIA,0)) MILUSIA,
    TO_CHAR(NVL(DZIELCZY,0)) DZIELCZY,
    TO_CHAR(SUMA) suma
FROM
    ((SELECT 
        nr_bandy,
        nazwa,
        plec,
        funkcja,
        NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ILE ZJADA"
    FROM
        Kocury JOIN Bandy USING(nr_bandy))
    PIVOT(
        SUM("ILE ZJADA")
        FOR funkcja
        IN
        ('SZEFUNIO' SZEFUNIO, 'BANDZIOR' BANDZIOR, 'LOWCZY' LOWCZY, 'LAPACZ' LAPACZ, 'KOT' KOT, 'MILUSIA' MILUSIA, 'DZIELCZY' DZIELCZY) ) )   
JOIN 
    (SELECT 
        nr_bandy,
        plec,
        COUNT(*) "ILE",
        SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) "SUMA"
    FROM Kocury
    GROUP BY nr_bandy, plec)
USING (nr_bandy, plec)

UNION

SELECT
      'Z----------------' nazwa,
      '------' plec,
      '----',
      '---------',
      '---------',
      '---------',
      '---------',
      '---------',
      '---------',
      '---------',
      '-------'
FROM DUAL

UNION

SELECT
    'ZJADA RAZEM' nazwa,
    '      ' plec,
    '    ',
    TO_CHAR(SUM(DECODE(funkcja, 'SZEFUNIO', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'BANDZIOR', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'LOWCZY', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'LAPACZ', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'KOT', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'MILUSIA', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(DECODE(funkcja, 'DZIELCZY', NVL(przydzial_myszy,0) + NVL(myszy_extra,0), 0))),
    TO_CHAR(SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)))
FROM Kocury)
ORDER BY nazwa, PLEC DESC;