-- 1. Rozszerzyć relacyjną bazę danych kotów o dodatkowe relacje opisujące:
--  - elitę,
--  - plebs
--  - konta elity (patrz opis z zad. 47) OKKK

-- 2. zdefiniować "nakładkę", w postaci perspektyw obiektowych
-- (bez odpowiedników relacji Funkcje, Bandy, Wrogowie),
-- na tak zmodyfikowaną bazę. OKK

-- 3. Odpowiadające relacjom typy obiektowe mają zawierać przykładowe
-- metody (mogą to być metody z zad. 47). OKK
--
-- 4. Zamodelować wszystkie powiązania referencyjne z wykorzystaniem:
-- - identyfikatorów OID
-- - funkcji MAKE_REF. OKK
--
-- 5. Relacje wypełnić przykładowymi danymi (mogą to być dane z zad. 47). OKK
--
-- 6. Dla tak przygotowanej bazy wykonać wszystkie zapytania SQL i bloki PL/SQL zrealizowane w ramach zad. 47.

-- RELACJE
CREATE TABLE PLEBS_REL(
  NR_PLEBS NUMBER(3) CONSTRAINT PL_NR_PK PRIMARY KEY,
  PSEUDO VARCHAR2(15) CONSTRAINT PL_PS_FK REFERENCES KOCURY(PSEUDO)
);

CREATE TABLE ELITA_REL(
  NR_ELITA NUMBER(3) CONSTRAINT EL_NR_PK PRIMARY KEY,
  PSEUDO VARCHAR2(15) CONSTRAINT EL_NR_FK REFERENCES KOCURY(PSEUDO),
  SLUGA_NR NUMBER(3) CONSTRAINT EL_SL_FK REFERENCES PLEBS_REL(NR_PLEBS)
);

CREATE TABLE KONTO_REL(
  NR NUMBER(3) CONSTRAINT KNT_NR_PK PRIMARY KEY,
  WLASCICIEL_NR NUMBER(3) CONSTRAINT KNT_WL_FK REFERENCES ELITA_REL(NR_ELITA),
  DATA_WPROWADZANIA DATE DEFAULT SYSDATE,
  DATA_USUNIECIA DATE
);







