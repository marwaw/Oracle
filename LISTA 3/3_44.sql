--ZAD 44
-- Tygrysa zaniepokoiło niewytłumaczalne obniżenie zapasów "myszowych".
-- Postanowił więc wprowadzić podatek pogłówny, który zasiliłby spiżarnię. Zarządził więc, że
-- każdy kot ma obowiązek oddawać 5% (zaokrąglonych w górę) swoich całkowitych
-- "myszowych" przychodów. Dodatkowo od tego co pozostanie:
-- - koty nie posiadające podwładnych oddają po dwie myszy za nieudolność w
-- umizgach o awans,
-- - koty nie posiadające wrogów oddają po jednej myszy za zbytnią ugodowość,
-- - koty płacą dodatkowy podatek, którego formę określa wykonawca zadania.
-- Napisać funkcję, której parametrem jest pseudonim kota, wyznaczającą należny podatek
-- pogłówny kota. Funkcję tą razem z procedurą z zad. 40 należy umieścić w pakiecie, a
-- następnie wykorzystać ją do określenia podatku dla wszystkich kotów.


CREATE OR REPLACE FUNCTION Oblicz_podatek
  (PSEUDONIM KOCURY.PSEUDO%TYPE)
  RETURN NUMBER
  AS
  PODATEK NUMBER := 0;
  PRZYDZIAL KOCURY.PRZYDZIAL_MYSZY%TYPE;
  EXTRA KOCURY.MYSZY_EXTRA%TYPE;
  ILE_PODWLAD NUMBER;
  ILE_WROGOW NUMBER;

BEGIN
  SELECT NVL(PRZYDZIAL_MYSZY,0), NVL(MYSZY_EXTRA,0)
  INTO PRZYDZIAL, EXTRA
  FROM KOCURY
  WHERE PSEUDO = PSEUDONIM;

  SELECT COUNT(PSEUDO)
  INTO ILE_PODWLAD
  FROM KOCURY
  WHERE SZEF = PSEUDONIM;

  SELECT COUNT(IMIE_WROGA)
  INTO ILE_WROGOW
  FROM WROGOWIE_KOCUROW
  WHERE PSEUDO = PSEUDONIM;

--   PODATEK KAZDEGO KOTA
  PODATEK := PODATEK + CEIL(0.05 * PRZYDZIAL);

--   GDY KOT NIE MA PODWLADNYCH
  IF ILE_PODWLAD = 0 THEN
    PODATEK := PODATEK + 2;
  END IF;

--   GDY KOT NIE MA WROGOW
  IF ILE_WROGOW = 0 THEN
    PODATEK := PODATEK + 1;
  END IF;

--   GDY KOT NIE MA MYSZY EXTRA, BO MOŻE JEST ZBYT LENIWY ŻEBY SIĘ O NIE STARAĆ
  IF EXTRA = 0 THEN
    PODATEK := PODATEK +1;
  END IF;

  RETURN PODATEK;
END Oblicz_podatek;