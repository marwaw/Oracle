-- Zad 36
-- W związku z dużą wydajnością w łowieniu myszy SZEFUNIO postanowił
-- wynagrodzić swoich podwładnych. Ogłosił więc, że podwyższa indywidualny przydział
-- myszy każdego kota o 10% poczynając od kotów o najniższym przydziale. Jeśli w którymś
-- momencie suma wszystkich przydziałów przekroczy 1050, żaden inny kot nie dostanie
-- podwyżki. Jeśli przydział myszy po podwyżce przekroczy maksymalną wartość należną dla
-- pełnionej funkcji (relacja Funkcje), przydział myszy po podwyżce ma być równy tej wartości.
-- Napisać blok PL/SQL z kursorem, który wyznacza sumę przydziałów przed podwyżką a
-- realizuje to zadanie. Blok ma działać tak długo, aż suma wszystkich przydziałów
-- rzeczywiście przekroczy 1050 (liczba „obiegów podwyżkowych” może być większa od 1 a
-- więc i podwyżka może być większa niż 10%). Wyświetlić na ekranie sumę przydziałów
-- myszy po wykonaniu zadania wraz z liczbą podwyżek (liczbą zmian w relacji Kocury). Na
-- końcu wycofać wszystkie zmiany

SELECT IMIE, PRZYDZIAL_MYSZY
FROM KOCURY
ORDER BY PRZYDZIAL_MYSZY;
DECLARE
  CURSOR KURSOR IS
  SELECT IMIE, NVL(PRZYDZIAL_MYSZY,0) PM, NVL(MAX_MYSZY,0) MM
  FROM KOCURY JOIN FUNKCJE USING(FUNKCJA)
  ORDER BY NVL(PRZYDZIAL_MYSZY,0) ASC
  FOR UPDATE OF PRZYDZIAL_MYSZY;
  SUMA NUMBER;
  ILE NUMBER;
  re KURSOR%ROWTYPE;

BEGIN
  SELECT SUM(PRZYDZIAL_MYSZY)
  INTO SUMA
  FROM KOCURY;
  ILE := 0;

  WHILE SUMA <= 1050
  LOOP
    OPEN KURSOR;
    WHILE suma <= 1050
    LOOP
      FETCH KURSOR INTO RE;
      EXIT WHEN KURSOR%NOTFOUND;

      IF ROUND(RE.PM * 1.1) <= RE.MM THEN
        UPDATE KOCURY
          SET PRZYDZIAL_MYSZY = RE.PM * 1.1
        WHERE CURRENT OF KURSOR;
        SUMA := SUMA + ROUND(RE.PM * 1.1) - RE.PM;
        ILE := ILE + 1;

      ELSIF RE.PM < RE.MM THEN
        UPDATE KOCURY
          SET PRZYDZIAL_MYSZY = RE.MM
        WHERE CURRENT OF KURSOR;
        SUMA := SUMA + RE.MM - RE.PM ;
        ILE := ILE + 1;
      END IF;
    END LOOP;
    CLOSE KURSOR;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('CALK. PRZYDZIAL W STADKU ' || SUMA || ' ZMIAN - ' || ILE);
END;
SELECT IMIE, PRZYDZIAL_MYSZY "MYSZKI PO PODWYŻCE"
FROM KOCURY
ORDER BY PRZYDZIAL_MYSZY DESC;
ROLLBACK;
SELECT IMIE, PRZYDZIAL_MYSZY
FROM KOCURY;



UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 67
WHERE IMIE = 'JACEK';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 56
WHERE IMIE = 'BARI';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 25
WHERE IMIE='MICKA';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 43
WHERE IMIE = 'LUCEK';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 20
WHERE IMIE = 'SONIA';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 40
WHERE IMIE = 'LATKA';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 40
WHERE IMIE = 'DUDEK';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 103
WHERE IMIE = 'MRUCZEK';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 50
WHERE IMIE = 'CHYTRY';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 75
WHERE IMIE = 'KOREK';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 72
WHERE IMIE = 'BOLEK';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 65
WHERE IMIE = 'ZUZIA';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 22
WHERE IMIE = 'RUDA';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 65
WHERE IMIE = 'PUCEK';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 61
WHERE IMIE = 'PUNIA';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 24
WHERE IMIE = 'BELA';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 51
WHERE IMIE = 'KSAWERY';

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 51
WHERE IMIE = 'MELA';
COMMIT;