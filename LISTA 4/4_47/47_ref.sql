-- Zadanie 47
-- Założyć, że w stadzie kotów pojawił się podział na elitę i na plebs.
-- - Członek elity posiadał prawo do jednego sługi wybranego spośród plebsu. OKK
-- - Dodatkowo mógł gromadzić myszy na dostępnym dla każdego członka elity koncie. OKK
-- Konto ma zawierać dane o dacie wprowadzenia na nie pojedynczej myszy i o dacie jej usunięcia. OKK
-- O tym, do kogo należy mysz ma mówić odniesienie do jej właściciela z elity. OKK
-- Przyjmując te dodatkowe założenia:
-- 1) zdefiniować schemat bazy danych kotów (bez odpowiedników relacji Funkcje, Bandy,
-- Wrogowie) w postaci relacyjno-obiektowej, gdzie dane dotyczące kotów, elity, plebsu. kont,
-- incydentów będą określane przez odpowiednie typy obiektowe. OKK
-- 2) Dla każdego z typów zaproponować i zdefiniować przykładowe metody. OKK
-- 3) Powiązania referencyjne należy zdefiniować za pomocą typów odniesienia. OKK
-- 4) Tak przygotowany schemat wypełnić danymi z rzeczywistości kotów (dane do opisu elit, plebsu i kont zaproponować samodzielnie) a
-- następnie OKK


DROP TABLE KONTO_T;
DROP TABLE ELITA_T;
DROP TABLE PLEBS_T;
DROP TABLE WROGOWIE_KOCUROW_T;
DROP TABLE KOCURY_T;

DROP TYPE KONTO;
DROP TYPE ELITA;
DROP TYPE PLEBS;
DROP TYPE WROGOWIE_KOCUROW_O;
DROP TYPE KOCURY_O;


CREATE OR REPLACE TYPE KOCURY_O AS OBJECT
(IMIE            VARCHAR2(15),
 PLEC            VARCHAR2(1),
 PSEUDO          VARCHAR2(15),
 FUNKCJA         VARCHAR2(10),
 SZEF            REF KOCURY_O,
 W_STADKU_OD     DATE,
 PRZYDZIAL_MYSZY NUMBER(3),
 MYSZY_EXTRA     NUMBER(3),
 NR_BANDY        NUMBER(2),
MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2,
MEMBER FUNCTION CALK_PRZYDZIAL_MYSZY RETURN NUMBER);

ALTER TYPE KOCURY_O
    ADD MEMBER FUNCTION POROWNAJ_DATY_WSTAP(KOT VARCHAR2) RETURN NUMBER
CASCADE;

ALTER TYPE KOCURY_O
    ADD MEMBER FUNCTION CZY_ZAWIERA(LITERA VARCHAR2) RETURN NUMBER,
    ADD MEMBER FUNCTION MIESIAC_PRZYSTAPIENIA RETURN NUMBER
CASCADE;

CREATE OR REPLACE TYPE BODY KOCURY_O AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    BEGIN
      RETURN PSEUDO;
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

  MEMBER FUNCTION CALK_PRZYDZIAL_MYSZY RETURN NUMBER IS
    BEGIN
      RETURN NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA,0);
    END;

  MEMBER FUNCTION POROWNAJ_DATY_WSTAP(KOT VARCHAR2) RETURN NUMBER IS
    INNY_KOT KOCURY_O;
    BEGIN
      SELECT VALUE(KT)
        INTO INNY_KOT
      FROM KOCURY_T KT
      WHERE IMIE = KOT;

      IF SELF.W_STADKU_OD < INNY_KOT.W_STADKU_OD THEN
        RETURN -1;

      ELSIF SELF.W_STADKU_OD = INNY_KOT.W_STADKU_OD THEN
        RETURN 0;

      ELSE
        RETURN 1;
      END IF;

    END;
  END;


CREATE OR REPLACE TYPE PLEBS AS OBJECT (
  NR_PLEBS NUMBER(3),
  KOT      REF KOCURY_O,
  MAP MEMBER  FUNCTION POROWNAJ RETURN VARCHAR2
);

ALTER TYPE PLEBS
    ADD MEMBER FUNCTION DAJ_PSEUDO RETURN VARCHAR2
CASCADE;

CREATE OR REPLACE TYPE BODY PLEBS AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    TMP KOCURY_O;
    BEGIN
      SELECT DEREF(KOT) INTO TMP FROM DUAL;
      RETURN 'PLEBS' || TMP.PSEUDO;
    END;

  MEMBER FUNCTION DAJ_PSEUDO RETURN VARCHAR2 IS
    TMP KOCURY_O;
    BEGIN
      SELECT DEREF(KOT) INTO TMP FROM DUAL;
      RETURN TMP.PSEUDO;
    END;
  END;

CREATE OR REPLACE TYPE ELITA AS OBJECT
(NR_ELITA NUMBER(3),
 KOT      REF KOCURY_O,
 SLUGA    REF PLEBS,
 MAP MEMBER  FUNCTION POROWNAJ RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY ELITA AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    TMP KOCURY_O;
    BEGIN
      SELECT DEREF(KOT) INTO TMP FROM DUAL;
      RETURN 'ELITA' || TMP.PSEUDO;
    END;
  END;

CREATE OR REPLACE TYPE KONTO AS OBJECT
(
  NR                NUMBER(3),
  WLASCICIEL        REF ELITA,
  DATA_WPROWADZENIA DATE,
  DATA_USUNIECIA    DATE,
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2,
  MEMBER FUNCTION CZY_USUNIETE RETURN BOOLEAN
);

CREATE OR REPLACE TYPE BODY KONTO AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    TMP KOCURY_O;
    BEGIN
      SELECT DEREF(DEREF(WLASCICIEL).KOT) INTO TMP FROM DUAL;
      RETURN TMP.PSEUDO || DATA_WPROWADZENIA || NVL(DATA_USUNIECIA, '');
    END;
  MEMBER FUNCTION CZY_USUNIETE RETURN BOOLEAN IS
    BEGIN
      RETURN DATA_USUNIECIA IS NOT NULL;
    END;
  END;

CREATE OR REPLACE TYPE WROGOWIE_KOCUROW_O AS OBJECT
(NR_INCYDENTU   NUMBER(3),
 KOT            REF KOCURY_O,
 IMIE_WROGA     VARCHAR2(15),
 DATA_INCYDENTU DATE,
 OPIS_INCYDENTU VARCHAR2(50),
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2);

CREATE OR REPLACE TYPE BODY WROGOWIE_KOCUROW_O AS
  MAP MEMBER FUNCTION POROWNAJ RETURN VARCHAR2 IS
    BEGIN
      RETURN NR_INCYDENTU;
    END;
  END;

CREATE TABLE KOCURY_T OF KOCURY_O
(SZEF SCOPE IS KOCURY_T,
CONSTRAINT kcrt_pk PRIMARY KEY (pseudo),
CONSTRAINT kcrt_pl_ch CHECK (PLEC IN ('M', 'D')),
CONSTRAINT kcrt_im_ch CHECK (IMIE IS NOT NULL));

CREATE TABLE PLEBS_T OF PLEBS
(KOT SCOPE IS KOCURY_T,
CONSTRAINT plbs_PK PRIMARY KEY (NR_PLEBS)
);

CREATE TABLE ELITA_T OF ELITA
(KOT SCOPE IS KOCURY_T,
  SLUGA SCOPE IS PLEBS_T,
CONSTRAINT elt_PK PRIMARY KEY (NR_ELITA)
);

CREATE TABLE KONTO_T OF KONTO
(WLASCICIEL SCOPE IS ELITA_T,
CONSTRAINT KNT_PK PRIMARY KEY (NR),
CONSTRAINT KNT_DW_CH CHECK (DATA_WPROWADZENIA IS NOT NULL)
);

CREATE TABLE WROGOWIE_KOCUROW_T OF WROGOWIE_KOCUROW_O
(KOT SCOPE IS KOCURY_T,
CONSTRAINT WKT_PK PRIMARY KEY (NR_INCYDENTU),
CONSTRAINT WKT_DT_CH CHECK (DATA_INCYDENTU IS NOT NULL)
);



DROP TABLE KONTO_T;
DROP TYPE KONTO;
