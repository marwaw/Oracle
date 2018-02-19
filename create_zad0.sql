ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

CREATE TABLE Bandy
(nr_bandy NUMBER(2) CONSTRAINT ba_nr_pk PRIMARY KEY,
nazwa VARCHAR2(20) CONSTRAINT ba_na_nn NOT NULL,
teren VARCHAR2(15) CONSTRAINT ba_te_uq UNIQUE,
szef_bandy VARCHAR2(15) CONSTRAINT ba_sz_uq UNIQUE); 

CREATE TABLE Funkcje
(funkcja VARCHAR2(10) CONSTRAINT fu_fu_pk PRIMARY KEY,
min_myszy NUMBER(3) CONSTRAINT fu_min_ch CHECK(min_myszy > 5),
max_myszy NUMBER(3) CONSTRAINT fu_max_max CHECK(max_myszy < 200),
CONSTRAINT fu_max_min CHECK(max_myszy >= min_myszy));

CREATE TABLE Wrogowie
(imie_wroga VARCHAR2(15) CONSTRAINT wr_im_pk PRIMARY KEY,
stopien_wrogosci NUMBER(2) CONSTRAINT wr_st_ch CHECK(stopien_wrogosci BETWEEN 1 AND 10),
gatunek VARCHAR2(15),
lapowka VARCHAR2(20));

CREATE TABLE Kocury
(imie VARCHAR2(15) CONSTRAINT ko_im_nn NOT NULL,
plec VARCHAR2(1) CONSTRAINT ko_pl_ch CHECK(plec IN('M', 'D')),
pseudo VARCHAR2(15) CONSTRAINT ko_ps_pk PRIMARY KEY,
funkcja VARCHAR2(10) CONSTRAINT ko_fu_fk REFERENCES Funkcje(funkcja),
szef VARCHAR2(15),
w_stadku_od DATE DEFAULT SYSDATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2) CONSTRAINT ko_nr_fk REFERENCES Bandy(nr_bandy));

ALTER TABLE Kocury
ADD CONSTRAINT ko_sz_fk FOREIGN KEY (szef) REFERENCES Kocury(pseudo);

CREATE TABLE Wrogowie_Kocurow
(pseudo VARCHAR2(15) CONSTRAINT wk_ps_fk REFERENCES Kocury(pseudo),
imie_wroga VARCHAR2(15) CONSTRAINT wk_im_fk REFERENCES Wrogowie(imie_wroga),
data_incydentu DATE CONSTRAINT wk_da_nn NOT NULL,
opis_incydentu VARCHAR2(50),
CONSTRAINT wk_pk PRIMARY KEY(pseudo, imie_wroga));

ALTER TABLE Bandy
ADD CONSTRAINT ba_sz_fk FOREIGN KEY(szef_bandy) REFERENCES Kocury(pseudo);


