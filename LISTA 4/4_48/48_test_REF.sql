CREATE OR REPLACE TYPE KOCURY_test_O AS OBJECT
(IMIE            VARCHAR2(15),
 PLEC            VARCHAR2(1),
 PSEUDO          VARCHAR2(15),
 FUNKCJA         VARCHAR2(10),
 SZEF            REF KOCURY_test_O,
 W_STADKU_OD     DATE,
 PRZYDZIAL_MYSZY NUMBER(3),
 MYSZY_EXTRA     NUMBER(3),
 NR_BANDY        NUMBER(2),
MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2,
MEMBER FUNCTION CALK_PRZYDZIAL_MYSZY RETURN NUMBER,
MEMBER FUNCTION POROWNAJ_DATY_WSTAP(KOT VARCHAR2) RETURN NUMBER,
MEMBER FUNCTION CZY_ZAWIERA(LITERA VARCHAR2) RETURN NUMBER,
MEMBER FUNCTION MIESIAC_PRZYSTAPIENIA RETURN NUMBER);

CREATE OR REPLACE TYPE BODY KOCURY_test_O AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    BEGIN
      RETURN PSEUDO;
    END;

  MEMBER FUNCTION CALK_PRZYDZIAL_MYSZY RETURN NUMBER IS
    BEGIN
      RETURN NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA,0);
    END;

  MEMBER FUNCTION POROWNAJ_DATY_WSTAP(KOT VARCHAR2) RETURN NUMBER IS
    INNY_KOT KOCURY_test_O;
    BEGIN
      SELECT VALUE(KT)
        INTO INNY_KOT
      FROM KOCURY_test_PER KT
      WHERE IMIE = KOT;

      IF SELF.W_STADKU_OD < INNY_KOT.W_STADKU_OD THEN
        RETURN -1;

      ELSIF SELF.W_STADKU_OD = INNY_KOT.W_STADKU_OD THEN
        RETURN 0;

      ELSE
        RETURN 1;
      END IF;

    END;

  MEMBER FUNCTION CZY_ZAWIERA(LITERA VARCHAR2) RETURN NUMBER IS
    BEGIN
      IF INSTR(SELF.IMIE, LITERA) > 0 THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END;

  MEMBER FUNCTION MIESIAC_PRZYSTAPIENIA RETURN NUMBER IS
    BEGIN
      RETURN EXTRACT(MONTH FROM SELF.W_STADKU_OD);
    END;
  END;


CREATE OR REPLACE TYPE PLEBS_test_O AS OBJECT (
  NR_PLEBS NUMBER(3),
  KOT      REF KOCURY_test_O,
  MAP MEMBER  FUNCTION POROWNAJ RETURN VARCHAR2,
  MEMBER FUNCTION DAJ_PSEUDO RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY PLEBS_test_O AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    TMP KOCURY_test_O;
    BEGIN
      SELECT DEREF(KOT) INTO TMP FROM DUAL;
      RETURN 'PLEBS' || TMP.PSEUDO;
    END;

  MEMBER FUNCTION DAJ_PSEUDO RETURN VARCHAR2 IS
    TMP KOCURY_test_O;
    BEGIN
      SELECT DEREF(KOT) INTO TMP FROM DUAL;
      RETURN TMP.PSEUDO;
    END;
  END;

CREATE OR REPLACE TYPE ELITA_test_O AS OBJECT
(NR_ELITA NUMBER(3),
 KOT      REF KOCURY_test_O,
 SLUGA    REF PLEBS_test_O,
 MAP MEMBER  FUNCTION POROWNAJ RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY ELITA_test_O AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    TMP KOCURY_test_O;
    BEGIN
      SELECT DEREF(KOT) INTO TMP FROM DUAL;
      RETURN 'ELITA' || TMP.PSEUDO;
    END;
  END;


CREATE OR REPLACE TYPE KONTO_test_O AS OBJECT
(
  NR                NUMBER(3),
  WLASCICIEL        REF ELITA_test_O,
  DATA_WPROWADZENIA DATE,
  DATA_USUNIECIA    DATE,
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2,
  MEMBER FUNCTION CZY_USUNIETE RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY KONTO_test_O AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    TMP KOCURY_test_O;
    BEGIN
      SELECT DEREF(DEREF(WLASCICIEL).KOT) INTO TMP FROM DUAL;
      RETURN TMP.PSEUDO || DATA_WPROWADZENIA || NVL(DATA_USUNIECIA, '');
    END;
  MEMBER FUNCTION CZY_USUNIETE RETURN NUMBER IS
    BEGIN
      IF DATA_USUNIECIA IS NOT NULL THEN
        RETURN 0;
      ELSE
        RETURN 1;
      END IF;
    END;
  END;

CREATE OR REPLACE TYPE WROGOWIE_KOCUROW_test_O AS OBJECT
(NR_INCYDENTU   NUMBER(3),
 KOT            REF KOCURY_test_O,
 IMIE_WROGA     VARCHAR2(15),
 DATA_INCYDENTU DATE,
 OPIS_INCYDENTU VARCHAR2(50),
MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY WROGOWIE_KOCUROW_test_O AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    BEGIN
      RETURN NR_INCYDENTU;
    END;
  END;


CREATE OR REPLACE FORCE VIEW KOCURY_test_PER OF KOCURY_TEST_O
WITH OBJECT IDENTIFIER (PSEUDO) AS
  SELECT
    imie,
    plec,
    pseudo,
    funkcja,
    MAKE_REF(KOCURY_test_PER, SZEF) SZEF,
    w_stadku_od,
    przydzial_myszy,
    myszy_extra,
    nr_bandy
FROM KOCURY;


CREATE OR REPLACE VIEW PLEBS_test_PER OF PLEBS_test_O
WITH OBJECT IDENTIFIER (NR_PLEBS) AS
  SELECT NR_PLEBS, MAKE_REF(KOCURY_test_PER, PSEUDO) PSEUDO
  FROM PLEBS_REL;

CREATE OR REPLACE VIEW ELITA_test_PER OF ELITA_test_O
WITH OBJECT IDENTIFIER (NR_ELITA) AS
  SELECT NR_ELITA, MAKE_REF(KOCURY_test_PER, PSEUDO) PSEUDO, MAKE_REF(PLEBS_test_PER, SLUGA_NR) SLUGA
  FROM ELITA_REL;

CREATE OR REPLACE VIEW KONTO_test_PER OF KONTO_test_O
WITH OBJECT IDENTIFIER (NR) AS
  SELECT NR, MAKE_REF(ELITA_test_PER, WLASCICIEL_NR) WLASCICIEL, DATA_WPROWADZANIA, DATA_USUNIECIA
  FROM KONTO_REL;

CREATE OR REPLACE VIEW WROGOWIE_KOC_test_PER OF WROGOWIE_KOCUROW_test_O
WITH OBJECT IDENTIFIER (NR_INCYDENTU) AS
  SELECT ROWNUM NR_INCYDENTU, MAKE_REF(KOCURY_test_PER, PSEUDO) PSEUDO, IMIE_WROGA, DATA_INCYDENTU, OPIS_INCYDENTU
  FROM WROGOWIE_KOCUROW;

SELECT PSEUDO, DEREF(SZEF).PSEUDO FROM KOCURY_TEST_PER;