--ZAD 39
-- Napisać blok PL/SQL wczytujący trzy parametry reprezentujące nr bandy, nazwę
-- bandy oraz teren polowań. Skrypt ma uniemożliwiać wprowadzenie istniejących już wartości
-- parametrów poprzez obsługę odpowiednich wyjątków. Sytuacją wyjątkową jest także
-- wprowadzenie numeru bandy <=0. W przypadku zaistnienia sytuacji wyjątkowej należy
-- wyprowadzić na ekran odpowiedni komunikat. W przypadku prawidłowych parametrów
-- należy stworzyć nową bandę w relacji Bandy. Zmianę należy na końcu wycofać.

DECLARE
  NRB KOCURY.NR_BANDY%TYPE;
  NAZWAB BANDY.NAZWA%TYPE;
  TERENB BANDY.TEREN%TYPE;
  ILE_NR NUMBER;
  ILE_NAZWA NUMBER;
  ILE_TEREN NUMBER;
  ZLY_NUMER EXCEPTION;
  ZNALEZIONO EXCEPTION;
  INFO VARCHAR2(50) := ' ';

BEGIN
  NRB := :numer;
  NAZWAB := :nazwa;
  TERENB := :teren;

  IF NRB <= 0 THEN
    RAISE ZLY_NUMER;
  END IF;

  SELECT COUNT(*)
  INTO ILE_NR
  FROM BANDY
  WHERE NR_BANDY = NRB;

  SELECT COUNT(*)
  INTO ILE_NAZWA
  FROM BANDY
  WHERE NAZWA = NAZWAB;

  SELECT COUNT(*)
  INTO ILE_TEREN
  FROM BANDY
  WHERE TEREN = TERENB;

  IF ILE_NR = 0 AND ILE_NAZWA = 0 AND ILE_TEREN = 0 THEN
     INSERT INTO BANDY
      (NR_BANDY, NAZWA , TEREN)
    VALUES
      (NRB, NAZWAB, TERENB);
  ELSE
     IF ILE_NR > 0 THEN INFO := INFO || NRB || ' ';
       END IF;
     IF ILE_NAZWA > 0 THEN  INFO := INFO || NAZWAB || ' ';
        END IF;
    IF ILE_TEREN > 0 THEN INFO := INFO || TERENB || ' ';
      END IF;
    RAISE ZNALEZIONO;
  END IF;

  EXCEPTION
    WHEN ZLY_NUMER
      THEN DBMS_OUTPUT.PUT_LINE('PODANO NIEODPOWIEDNI NUMER BANDY');
    WHEN ZNALEZIONO
      THEN DBMS_OUTPUT.PUT_LINE(INFO || ' JUZ ISTNIEJE');

END;
SELECT * FROM BANDY;
ROLLBACK;
