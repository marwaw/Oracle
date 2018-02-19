-- ZAD 34
-- Napisać blok PL/SQL, który wybiera z relacji Kocury koty o funkcji podanej z
-- klawiatury. Jedynym efektem działania bloku ma być komunikat informujący czy znaleziono,
-- czy też nie, kota pełniącego podaną funkcję (w przypadku znalezienia kota wyświetlić nazwę
-- odpowiedniej funkcji)

DECLARE
  NUM_KOC NUMBER;
  FUN VARCHAR2(25);
BEGIN
  FUN := :x;

  SELECT COUNT(FUNKCJA)
  INTO NUM_KOC
    FROM KOCURY
  WHERE FUNKCJA = FUN;

  IF NUM_KOC > 0 THEN
    DBMS_OUTPUT.PUT_LINE('ZNALEZIONO ' || FUN);
  ELSE
    DBMS_OUTPUT.PUT_LINE('NIE ZNALEZIONO');
  END IF;

END;