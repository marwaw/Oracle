CREATE OR REPLACE PROCEDURE WYPLATA_MIESIECZNA AS
  MYSZY_DO_ROZDANIA NUMBER;
  TYPE PSEUDOSY IS TABLE OF KOCURY.PSEUDO%TYPE;
  TYPE TAB_NUM IS TABLE OF NUMBER;

  GLODNE_KOTY PSEUDOSY;
  ILE_JEDZONE TAB_NUM;
  ILE_DOSTAL TAB_NUM;
  NUMERY_MYSZY TAB_NUM;

  ZJADACZE PSEUDOSY;
  ILE_ROZDANYCH NUMBER := 0;

  CZY_JESZCZE_GLODNE BOOLEAN := FALSE;

BEGIN

  SELECT NR_MYSZY
  BULK COLLECT INTO NUMERY_MYSZY
  FROM MYSZY
  WHERE ZJADACZ IS NULL;

  MYSZY_DO_ROZDANIA := NUMERY_MYSZY.LAST;

  SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA, 0), 0
  BULK COLLECT INTO GLODNE_KOTY, ILE_JEDZONE, ILE_DOSTAL
  FROM KOCURY
  CONNECT BY PRIOR pseudo = szef
  START WITH szef IS NULL
  ORDER BY LEVEL;

  WHILE ILE_ROZDANYCH < MYSZY_DO_ROZDANIA AND CZY_JESZCZE_GLODNE
  LOOP
    CZY_JESZCZE_GLODNE := FALSE;
    FOR IND IN 1..GLODNE_KOTY.COUNT
    LOOP
      IF ILE_DOSTAL(IND) != ILE_JEDZONE(IND) THEN
        ILE_ROZDANYCH := ILE_ROZDANYCH + 1;
        ZJADACZE.extend;
        ZJADACZE(ZJADACZE.LAST) := GLODNE_KOTY(IND);
        CZY_JESZCZE_GLODNE := TRUE;
      END IF;
      EXIT WHEN ILE_ROZDANYCH = MYSZY_DO_ROZDANIA;
    END LOOP;
  END LOOP;

FORALL I IN 1..ZJADACZE.LAST
  UPDATE MYSZY
    SET ZJADACZ = ZJADACZE(I),
      DATA_WYDANIA = SYSDATE
  WHERE NR_MYSZY = NUMERY_MYSZY(I);

END;