--ZAD 41
-- Zdefiniować wyzwalacz, który zapewni, że numer nowej bandy będzie zawsze
-- większy o 1 od najwyższego numeru istniejącej już bandy. Sprawdzić działanie wyzwalacza
-- wykorzystując procedurę z zadania 40.

CREATE OR REPLACE TRIGGER PoprawnyNumer
  BEFORE INSERT OR UPDATE ON BANDY
  FOR EACH ROW
  DECLARE
    NUMER BANDY.NR_BANDY%TYPE;

  BEGIN
    SELECT MAX(NR_BANDY)
    INTO NUMER
    FROM BANDY;

    :NEW.NR_BANDY := NUMER +1;
  END;

CALL DODAJBANDE(10, 'DZIEWCZYNKI', 'MIASTO' );
SELECT * FROM BANDY;
ROLLBACK;
SELECT * FROM BANDY;