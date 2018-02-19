-- ZAD 35
-- Napisać blok PL/SQL, który wyprowadza na ekran następujące informacje o kocie o
-- pseudonimie wprowadzonym z klawiatury (w zależności od rzeczywistych danych):
-- - 'calkowity roczny przydzial myszy >700'
-- - 'imię zawiera litere A'
-- - 'styczeń jest miesiacem przystapienia do stada'
-- - 'nie odpowiada kryteriom'.
-- Powyższe informacje wymienione są zgodnie z hierarchią ważności. Każdą wprowadzaną
-- informację poprzedzić imieniem kota.
--PSEUDO: ZERO (LUCEK) NIE SPEŁNIA KRYTERIÓW

DECLARE
  PSEUDO_KOTA KOCURY.PSEUDO%TYPE;
  IMIE_KOTA KOCURY.IMIE%TYPE;
  PRZYDZIAL KOCURY.PRZYDZIAL_MYSZY%TYPE;
  DODATEK KOCURY.MYSZY_EXTRA%TYPE;
  DATA_WSTAP KOCURY.W_STADKU_OD%TYPE;

BEGIN
  PSEUDO_KOTA := :X;

  SELECT IMIE, PRZYDZIAL_MYSZY, MYSZY_EXTRA, W_STADKU_OD
  INTO IMIE_KOTA, PRZYDZIAL, DODATEK, DATA_WSTAP
    FROM KOCURY
  WHERE PSEUDO = PSEUDO_KOTA;

  IF (NVL(PRZYDZIAL, 0) + NVL(DODATEK,0)) * 12 > 700 THEN
    DBMS_OUTPUT.PUT_LINE(IMIE_KOTA || ' CALKOWITY ROCZNY PRZYDZIAL MYSZY > 700');
  END IF;

  IF INSTR(IMIE_KOTA, 'A') != 0 THEN
    DBMS_OUTPUT.PUT_LINE(IMIE_KOTA || ' IMIE ZAWIERA LITERE A');
  END IF;

  IF EXTRACT(MONTH FROM DATA_WSTAP) = 1 THEN
    DBMS_OUTPUT.PUT_LINE(IMIE_KOTA || ' STYCZEN JEST MIESIĄCEM PRZYSTAPIENIA DO STADA');
  END IF;

  IF
    (NVL(PRZYDZIAL, 0) + NVL(DODATEK,0)) * 12 <= 700
    AND
    INSTR(IMIE_KOTA, 'A') = 0
    AND
    EXTRACT(MONTH FROM DATA_WSTAP) != 1
  THEN
    DBMS_OUTPUT.PUT_LINE(IMIE_KOTA || ' NIE ODPOWIADA KRYTERIOM');
  END IF;

END;
