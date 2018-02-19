--ZAD 42
-- Milusie postanowiły zadbać o swoje interesy. Wynajęły więc informatyka, aby
-- zapuścił wirusa w system Tygrysa. Teraz przy każdej próbie zmiany przydziału myszy na
-- plus (o minusie w ogóle nie może być mowy) o wartość mniejszą niż 10% przydziału myszy
-- Tygrysa żal Miluś ma być utulony podwyżką ich przydziału o tą wartość oraz podwyżką
-- myszy extra o 5. Tygrys ma być ukarany stratą wspomnianych 10%. Jeśli jednak podwyżka
-- będzie satysfakcjonująca, przydział myszy extra Tygrysa ma wzrosnąć o 5.
-- Zaproponować dwa rozwiązania zadania, które ominą podstawowe ograniczenie dla
-- wyzwalacza wierszowego aktywowanego poleceniem DML tzn. brak możliwości odczytu lub
-- zmiany relacji, na której operacja (polecenie DML) „wyzwala” ten wyzwalacz. W pierwszym
-- rozwiązaniu (klasycznym) wykorzystać kilku wyzwalaczy i pamięć w postaci specyfikacji
-- dedykowanego zadaniu pakietu, w drugim wykorzystać wyzwalacz COMPOUND.
-- Podać przykład funkcjonowania wyzwalaczy a następnie zlikwidować wprowadzone przez
-- nie zmiany

CREATE OR REPLACE PACKAGE PAKIET42 AS
  przydzial_tygrysa NUMBER;
  kara NUMBER := 0;
  nagroda NUMBER := 0;
END PAKIET42;

CREATE OR REPLACE TRIGGER SprawdzTygrysa
BEFORE UPDATE ON KOCURY
  BEGIN
    SELECT PRZYDZIAL_MYSZY
    INTO PAKIET42.przydzial_tygrysa
    FROM KOCURY WHERE pseudo = 'TYGRYS';
  END;

CREATE OR REPLACE TRIGGER ZWIEKSZ_PRZYDZIAL_BEFORE
BEFORE UPDATE ON KOCURY
FOR EACH ROW
DECLARE
  TYGRYS10 NUMBER := ROUND(PAKIET42.przydzial_tygrysa * 0.1);
  fmax NUMBER;
BEGIN
  SELECT MAX_MYSZY INTO fmax FROM FUNKCJE WHERE FUNKCJA = :NEW.FUNKCJA;

  IF :NEW.FUNKCJA = 'MILUSIA' THEN
    IF :NEW.PRZYDZIAL_MYSZY < :OLD.PRZYDZIAL_MYSZY THEN
      :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;

    ElSIF :NEW.PRZYDZIAL_MYSZY - :OLD.PRZYDZIAL_MYSZY < TYGRYS10 THEN
      :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY + TYGRYS10;
      :NEW.MYSZY_EXTRA := :OLD.MYSZY_EXTRA + 5;
      PAKIET42.kara := TYGRYS10;

    ELSE
      PAKIET42.nagroda := 5;
    END IF;

    IF :NEW.PRZYDZIAL_MYSZY > fmax THEN
      :NEW.PRZYDZIAL_MYSZY := fmax;
    END IF;

  END IF;
END;

CREATE OR REPLACE TRIGGER ZWIEKSZ_PRZYDZIAL_AFTER
AFTER UPDATE ON KOCURY
DECLARE
  NAGRODA NUMBER := PAKIET42.nagroda;
  KARA NUMBER := PAKIET42.kara;
  fmin_tygrysa NUMBER;
BEGIN
  SELECT MIN_MYSZY INTO fmin_tygrysa FROM FUNKCJE WHERE FUNKCJE.FUNKCJA = 'SZEFUNIO';

  IF PAKIET42.nagroda > 0 THEN
    PAKIET42.nagroda := 0;
    UPDATE KOCURY
    SET MYSZY_EXTRA = MYSZY_EXTRA + NAGRODA
    WHERE PSEUDO = 'TYGRYS';
  END IF;

  IF PAKIET42.kara > 0 THEN
    PAKIET42.kara := 0;

    IF PAKIET42.przydzial_tygrysa - KARA < fmin_tygrysa THEN
      UPDATE KOCURY
      SET PRZYDZIAL_MYSZY = fmin_tygrysa
      WHERE PSEUDO = 'TYGRYS';
    ELSE
      UPDATE KOCURY
      SET PRZYDZIAL_MYSZY = PRZYDZIAL_MYSZY - KARA
      WHERE PSEUDO = 'TYGRYS';
    END IF;
  END IF;
END;
  


SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy - 1;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy - 1;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy - 1;
SELECT * FROM Kocury;
ROLLBACK;