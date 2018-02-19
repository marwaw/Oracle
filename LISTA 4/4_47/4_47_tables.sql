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

CREATE TABLE KOCURY_T OF KOCURY_O(
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
DROP TABLE ELITA_T;
DROP TABLE PLEBS_T;
DROP TABLE WROGOWIE_KOCUROW_T;
DROP TABLE KOCURY_T;

DROP TYPE KONTO;
DROP TYPE ELITA;
DROP TYPE PLEBS;
DROP TYPE WROGOWIE_KOCUROW_O;
DROP TYPE KOCURY_O;
