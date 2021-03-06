-- Napisać blok, który zrealizuje zad. 33 w sposób uniwersalny (bez konieczności
-- uwzględniania wiedzy o funkcjach pełnionych przez koty).

DECLARE
  ILE_P NUMBER(2);
  ILE_F NUMBER(4);
  RAZEM_F NUMBER(4);
  PLEC_K VARCHAR2(1);
  CURSOR FUN IS (SELECT DISTINCT FUNKCJA FROM KOCURY);
  CURSOR BANDY IS (SELECT DISTINCT NAZWA, NR_BANDY FROM BANDY JOIN KOCURY USING(NR_BANDY));

BEGIN
  DBMS_OUTPUT.PUT(LPAD('NAZWA BANDY', 20));
  DBMS_OUTPUT.PUT(LPAD('PLEC', 7));
  DBMS_OUTPUT.PUT(LPAD('ILE', 4));

  FOR i IN FUN
  LOOP
    DBMS_OUTPUT.PUT(LPAD(I.FUNKCJA, 10));
  END LOOP;

  DBMS_OUTPUT.PUT(LPAD('SUMA', 6));
  DBMS_OUTPUT.PUT_LINE(' ');

  DBMS_OUTPUT.PUT(LPAD(' ', 20, '-'));
  DBMS_OUTPUT.PUT(LPAD(' ', 7, '-'));
  DBMS_OUTPUT.PUT(LPAD(' ', 4, '-'));

  FOR i IN FUN
  LOOP
    DBMS_OUTPUT.PUT(LPAD(' ', 10, '-'));
  END LOOP;

  DBMS_OUTPUT.PUT(LPAD(' ', 6, '-'));
  DBMS_OUTPUT.PUT_LINE(' ');

  FOR BANDA IN BANDY
  LOOP
    FOR PLEC_KOT IN 1..2
    LOOP
      IF PLEC_KOT = 1 THEN
        PLEC_K := 'D';
        DBMS_OUTPUT.PUT(LPAD(BANDA.NAZWA, 20));
        DBMS_OUTPUT.PUT(LPAD('KOTKA', 7));
      ELSE
        PLEC_K := 'M';
        DBMS_OUTPUT.PUT(LPAD(' ', 20));
        DBMS_OUTPUT.PUT(LPAD('KOCUR', 7));
      END IF;

      SELECT COUNT(PSEUDO) INTO ILE_P FROM KOCURY WHERE PLEC = PLEC_K AND NR_BANDY = BANDA.NR_BANDY;
      DBMS_OUTPUT.PUT(LPAD(ILE_P, 4));

      FOR F IN FUN
      LOOP
        SELECT SUM(CASE
                   WHEN FUNKCJA = F.FUNKCJA THEN NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA,0)
                  ELSE 0 END)
        INTO ILE_F
        FROM KOCURY
        WHERE PLEC = PLEC_K AND NR_BANDY = BANDA.NR_BANDY;
        DBMS_OUTPUT.PUT(LPAD(ILE_F, 10));
      END LOOP;
      SELECT SUM(NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA,0)) INTO RAZEM_F FROM KOCURY WHERE PLEC = PLEC_K AND NR_BANDY = BANDA.NR_BANDY;
      DBMS_OUTPUT.PUT(LPAD(RAZEM_F, 6));
    DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(' ');

  DBMS_OUTPUT.PUT(LPAD(' ', 20, '-'));
  DBMS_OUTPUT.PUT(LPAD(' ', 7, '-'));
  DBMS_OUTPUT.PUT(LPAD(' ', 4, '-'));

  FOR i IN FUN
  LOOP
    DBMS_OUTPUT.PUT(LPAD(' ', 10, '-'));
  END LOOP;

  DBMS_OUTPUT.PUT(LPAD(' ', 6, '-'));
  DBMS_OUTPUT.PUT_LINE(' ');

  DBMS_OUTPUT.PUT(LPAD('ZJADA RAZEM', 20));
  DBMS_OUTPUT.PUT(LPAD(' ', 7));
  DBMS_OUTPUT.PUT(LPAD(' ', 4));

  FOR i IN FUN
  LOOP
    SELECT SUM(NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA,0)) INTO ILE_F FROM KOCURY WHERE FUNKCJA = I.FUNKCJA;
    DBMS_OUTPUT.PUT(LPAD(ILE_F, 10));
  END LOOP;

  SELECT SUM(NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA,0)) INTO RAZEM_F FROM KOCURY;
  DBMS_OUTPUT.PUT(LPAD(RAZEM_F, 6));
  DBMS_OUTPUT.PUT_LINE(' ');

END;