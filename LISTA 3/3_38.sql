-- ZAD 38
-- Napisać blok, który zrealizuje wersję a. lub wersję b. zad. 19 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o głębokości drzewa). Daną wejściową ma być
-- maksymalna liczba wyświetlanych przełożonych.

DECLARE
  obecny_poz NUMBER;
  max_poz NUMBER;
  n NUMBER DEFAULT :n;

BEGIN
  SELECT MAX(level)-1
  INTO max_poz
  FROM Kocury
  CONNECT BY PRIOR pseudo = szef
  START WITH szef IS NULL;
 
  IF n > max_poz THEN
    n := max_poz;
  END IF;
   
  DBMS_OUTPUT.PUT(RPAD('Imie', 10));
   
  FOR i IN 1..n
  LOOP
    DBMS_OUTPUT.PUT('  |  ' || RPAD('Szef ' || i, 10));
  END LOOP;
   
  DBMS_OUTPUT.PUT_LINE(' ');
  DBMS_OUTPUT.PUT('----------');
  FOR i IN 1..n
  LOOP
    DBMS_OUTPUT.PUT(' --- ----------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ');
 
  FOR kot IN (
    SELECT * FROM Kocury
    WHERE funkcja IN ('KOT', 'MILUSIA'))
  LOOP
    obecny_poz := 1;
    DBMS_OUTPUT.PUT(RPAD(kot.imie, 10));

    WHILE obecny_poz <= n
    LOOP
      IF kot.szef IS NULL THEN
        DBMS_OUTPUT.PUT('  |  ' || RPAD(' ', 10));
      ELSE
        SELECT *
        INTO kot
        FROM Kocury
        WHERE pseudo = kot.szef;
        DBMS_OUTPUT.put('  |  ' || RPAD(kot.imie, 10));
      END IF;
      obecny_poz := obecny_poz + 1;    
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(' ');
  END LOOP;
END;