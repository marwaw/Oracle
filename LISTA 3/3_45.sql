--ZAD 45
-- Tygrys zauważył dziwne zmiany wartości swojego prywatnego przydziału myszy
-- (patrz zadanie 42). Nie niepokoiły go zmiany na plus ale te na minus były, jego zdaniem,
-- niedopuszczalne. Zmotywował więc jednego ze swoich szpiegów do działania i dzięki temu
-- odkrył niecne praktyki Miluś (zadanie 42). Polecił więc swojemu informatykowi
-- skonstruowanie mechanizmu zapisującego w relacji Dodatki_extra (patrz Wykłady - cz.
-- 2) dla każdej z Miluś -10 (minus dziesięć) myszy dodatku extra przy zmianie na plus
-- któregokolwiek z przydziałów myszy Miluś, wykonanej przez innego operatora niż on sam.
-- Zaproponować taki mechanizm, w zastępstwie za informatyka Tygrysa. W rozwiązaniu
-- wykorzystać funkcję LOGIN_USER zwracającą nazwę użytkownika aktywującego
-- wyzwalacz oraz elementy dynamicznego SQL'a.

CREATE SEQUENCE DODATKI_NUMER;

CREATE TABLE Dodatki_extra
( nr NUMBER(5),
  pseudo VARCHAR2(15),
  dod_extra NUMBER);
COMMIT;

CREATE OR REPLACE TRIGGER MILUSIOM_NIE
  BEFORE UPDATE ON KOCURY
  FOR EACH ROW
  DECLARE
  UZ VARCHAR2(15);
  OP VARCHAR2(1000);
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UZ := LOGIN_USER;
    IF (:NEW.FUNKCJA = 'MILUSIA' AND :NEW.PRZYDZIAL_MYSZY > :OLD.PRZYDZIAL_MYSZY AND LOGIN_USER != 'TYGRYS') THEN
      :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
      EXECUTE IMMEDIATE '
      DECLARE
        CURSOR MILUSIE IS SELECT PSEUDO FROM KOCURY WHERE FUNKCJA = :FUNKCJA;
      BEGIN
        FOR MIL IN MILUSIE
        LOOP
          INSERT INTO Dodatki_extra VALUES (DODATKI_NUMER.nextval, MIL.PSEUDO, -10);
        END LOOP;
      END;' USING 'MILUSIA' ;
      COMMIT;
    END IF;
  END;

SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 10 WHERE PSEUDO = 'LOLA';
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 10 WHERE PSEUDO = 'ZERO';
SELECT * FROM Kocury;
SELECT * FROM Dodatki_extra;
ROLLBACK;
