-- Zad 37
-- Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów o
-- najwyższym całkowitym przydziale myszy. Wynik wyświetlić na ekranie.

--1. MOZNA W SELECT KURSORA DAC ZEBY WYBIERALO 5 KOTOW
--2. MOZNA WYJSC Z FOR'A GDY ROWNUM > 5. NIE DO KONCA WIEM, KTORA WERSJA JEST PREFEROWANA

DECLARE
  CURSOR KURSOR IS
    SELECT ROWNUM, PSEUDO, SUMA
    FROM
      (SELECT
      PSEUDO,
      NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) SUMA
      FROM KOCURY
      ORDER BY SUMA DESC);

--   KOT KURSOR%ROWTYPE;

BEGIN
  DBMS_OUTPUT.PUT_LINE('NR' || '   ' || 'PSEUDONIM' || '   ' || 'ZJADA' );

  FOR KOT IN KURSOR
  LOOP
    EXIT WHEN KOT.ROWNUM > 5;
    DBMS_OUTPUT.PUT_LINE(KOT.ROWNUM || '    ' || KOT.PSEUDO || '    ' || KOT.SUMA);
  END LOOP;

END;

