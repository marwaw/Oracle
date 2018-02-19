CREATE OR REPLACE TRIGGER Zad42Compound
FOR UPDATE ON KOCURY
COMPOUND TRIGGER
  przydzial_tygrysa NUMBER;
  kara NUMBER := 0;
  nagroda NUMBER := 0;

  BEFORE STATEMENT IS
    BEGIN
      SELECT PRZYDZIAL_MYSZY
      INTO przydzial_tygrysa
      FROM KOCURY WHERE pseudo = 'TYGRYS';
    END BEFORE STATEMENT;

  BEFORE EACH ROW IS
   TYGRYS10 NUMBER := ROUND(przydzial_tygrysa * 0.1);
   fmax NUMBER;
    BEGIN
      SELECT MAX_MYSZY INTO fmax FROM FUNKCJE WHERE FUNKCJA = :NEW.FUNKCJA;

      IF :NEW.FUNKCJA = 'MILUSIA' THEN
        IF :NEW.PRZYDZIAL_MYSZY < :OLD.PRZYDZIAL_MYSZY THEN
          :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;

        ELSIF :NEW.PRZYDZIAL_MYSZY - :OLD.PRZYDZIAL_MYSZY < TYGRYS10 THEN
          :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY + TYGRYS10;
          :NEW.MYSZY_EXTRA := :OLD.MYSZY_EXTRA + 5;
          kara := TYGRYS10;

        ELSE
          nagroda := 5;
        END IF;

        IF :NEW.PRZYDZIAL_MYSZY > fmax THEN
          :NEW.PRZYDZIAL_MYSZY := fmax;
        END IF;

      END IF;

  END BEFORE EACH ROW;

  AFTER STATEMENT IS
    fmin_tygrysa NUMBER;
  BEGIN
    SELECT MIN_MYSZY INTO fmin_tygrysa FROM FUNKCJE WHERE FUNKCJE.FUNKCJA = 'SZEFUNIO';

    IF nagroda > 0 THEN
      UPDATE KOCURY
      SET MYSZY_EXTRA = MYSZY_EXTRA + nagroda
      WHERE PSEUDO = 'TYGRYS';
      nagroda := 0;

    ELSIF kara > 0 THEN
      IF przydzial_tygrysa - kara < fmin_tygrysa THEN
        UPDATE KOCURY
        SET PRZYDZIAL_MYSZY = fmin_tygrysa
        WHERE PSEUDO = 'TYGRYS';
      ELSE
        UPDATE KOCURY
        SET PRZYDZIAL_MYSZY = PRZYDZIAL_MYSZY - kara
        WHERE PSEUDO = 'TYGRYS';
      END IF;
      kara := 0;
    END IF;

    END AFTER STATEMENT ;
  END Zad42Compound;