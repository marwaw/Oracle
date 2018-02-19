--ZAD 46
-- Napisać wyzwalacz, który uniemożliwi wpisanie kotu przydziału myszy spoza
-- przedziału (min_myszy, max_myszy) określonego dla każdej funkcji w relacji Funkcje.
-- Każda próba wykroczenia poza obowiązujący przedział ma być dodatkowo monitorowana w
-- osobnej relacji (kto, kiedy, jakiemu kotu, jaką operacją).

CREATE TABLE MONITORING_ZMIAN
( nr NUMBER(5),
  kto VARCHAR2(15),
  data DATE,
  komu VARCHAR2(15) CONSTRAINT mz_km_fk REFERENCES Kocury(pseudo),
  operacja VARCHAR2(10)
);
COMMIT;

CREATE SEQUENCE NR_ZMIANY;

CREATE OR REPLACE TRIGGER POZA_PRZEDZIALEM
  BEFORE INSERT OR UPDATE OF PRZYDZIAL_MYSZY ON KOCURY
  FOR EACH ROW
  DECLARE
  FMIN FUNKCJE.MIN_MYSZY%TYPE;
  FMAX FUNKCJE.MAX_MYSZY%TYPE;

  UZ MONITORING_ZMIAN.KTO%TYPE;
  ODBIORCA MONITORING_ZMIAN.KOMU%TYPE;
  OP MONITORING_ZMIAN.OPERACJA%TYPE;

  BEGIN
    SELECT MIN_MYSZY, MAX_MYSZY
    INTO FMIN, FMAX
    FROM FUNKCJE
    WHERE FUNKCJA = :NEW.FUNKCJA;

    IF :NEW.PRZYDZIAL_MYSZY > FMAX OR :NEW.PRZYDZIAL_MYSZY < FMIN THEN
      IF :NEW.PRZYDZIAL_MYSZY > FMAX THEN
        :NEW.PRZYDZIAL_MYSZY := FMAX;
      ELSIF :NEW.PRZYDZIAL_MYSZY < FMIN THEN
        :NEW.PRZYDZIAL_MYSZY := FMIN;
      END IF;

      IF INSERTING THEN
        OP := 'INSERT';
      ELSIF UPDATING THEN
        OP := 'UPDATE';
      END IF;

      UZ := LOGIN_USER;
      ODBIORCA := :NEW.PSEUDO;
      INSERT INTO MONITORING_ZMIAN VALUES (NR_ZMIANY.nextval, UZ, SYSDATE, ODBIORCA, OP);
    END IF;
  END;

SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 10 WHERE PSEUDO = 'TYGRYS';
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 10 WHERE PSEUDO = 'TYGRYS';
SELECT * FROM Kocury;
SELECT * FROM MONITORING_ZMIAN;
ROLLBACK;