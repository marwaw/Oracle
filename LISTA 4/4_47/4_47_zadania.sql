-- 5) wykonać przykładowe zapytania SQL, operujące na rozszerzonym schemacie bazy,
-- wykorzystujące referencje (jako realizacje złączeń), podzapytania, grupowanie oraz metody
-- zdefiniowane w ramach typów. Dla każdego z mechanizmów (referencja, podzapytanie, grupowanie) należy przedstawić jeden taki przykład. OKK
-- 6) Zrealizować dodatkowo, w ramach nowego, relacyjno-obiektowego schematu, po dwa wybrane zadania z list nr 2 i 3. okk

--!!!
-- Możliwość odwołania się bezpośrednio do pól i metod
-- wskazywanych przez odniesienie istnieje tylko dla SQL’a.
-- W PL/SQL’u należałoby w takim przypadku wykorzystać funkcję DEREF przetwarzającą,
-- będące parametrem funkcji, odniesienie na obiekt."
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

--REFERENCJE
SELECT ET.KOT.PSEUDO "CZLONEK ELITY",
  ET.KOT.CALK_PRZYDZIAL_MYSZY() "ILE MYSZY POŻERA",
  ET.SLUGA.KOT.PSEUDO "SLUGA"
FROM ELITA_T ET;

--PODZAPYTANIE
SELECT
  KT.WLASCICIEL.KOT.PSEUDO "PAN I WLADCA",
  KT.DATA_WPROWADZENIA "KIEDY DOSTAŁ"
  FROM KONTO_T KT
WHERE KT.CZY_USUNIETE() = 0 AND
      KT.WLASCICIEL.SLUGA.KOT.PSEUDO IN
      (SELECT PT.KOT.PSEUDO
        FROM PLEBS_T PT
        WHERE PT.KOT.NR_BANDY = 3);

--GROUP BY
SELECT
  KT.WLASCICIEL.KOT.PSEUDO "PAN I WLADCA",
  COUNT(*) "MA NA KONCIE"
  FROM KONTO_T KT
WHERE KT.DATA_USUNIECIA IS NOT NULL
GROUP BY KT.WLASCICIEL.KOT.PSEUDO;

-- LISTA 2
-- ZAD 18

SELECT KT.IMIE, KT.W_STADKU_OD "POLUJE OD"
FROM KOCURY_T KT
WHERE KT.POROWNAJ_DATY_WSTAP('JACEK') < 0
ORDER BY KT.W_STADKU_OD DESC;

-- ZAD 22

SELECT MIN(WK.KOT.FUNKCJA), WK.KOT.PSEUDO "PSEUDONIM KOTA", COUNT(*)
FROM WROGOWIE_KOCUROW_T WK
GROUP BY WK.KOT.PSEUDO
HAVING COUNT(*) > 1;

--LISTA 3
--zad 37

DECLARE
  CURSOR KURSOR IS
    SELECT ROWNUM, PSEUDO, SUMA
    FROM
      (SELECT
      PSEUDO,
      KT.CALK_PRZYDZIAL_MYSZY() SUMA
      FROM KOCURY_T KT
      ORDER BY SUMA DESC);

BEGIN
  DBMS_OUTPUT.PUT_LINE('NR' || '   ' || 'PSEUDONIM' || '   ' || 'ZJADA' );

  FOR KOT IN KURSOR
  LOOP
    EXIT WHEN KOT.ROWNUM > 5;
    DBMS_OUTPUT.PUT_LINE(KOT.ROWNUM || '    ' || KOT.PSEUDO || '    ' || KOT.SUMA);
  END LOOP;
END;

--36
DECLARE
  PSEUDO_KOTA VARCHAR2(15);
  KOT KOCURY_O;

BEGIN
  PSEUDO_KOTA := :X;

  SELECT VALUE(KT)
  INTO KOT
    FROM KOCURY_T KT
  WHERE PSEUDO = PSEUDO_KOTA;

  IF KOT.CALK_PRZYDZIAL_MYSZY() * 12 > 700 THEN
    DBMS_OUTPUT.PUT_LINE(KOT.IMIE || ' CALKOWITY ROCZNY PRZYDZIAL MYSZY > 700');
  END IF;

  IF KOT.CZY_ZAWIERA('A') = 1 THEN
    DBMS_OUTPUT.PUT_LINE(KOT.IMIE || ' IMIE ZAWIERA LITERE A');
  END IF;

  IF KOT.MIESIAC_PRZYSTAPIENIA() = 1 THEN
    DBMS_OUTPUT.PUT_LINE(KOT.IMIE || ' STYCZEN JEST MIESIĄCEM PRZYSTAPIENIA DO STADA');
  END IF;

  IF
    KOT.CALK_PRZYDZIAL_MYSZY() * 12 * 12 <= 700
    AND
     KOT.CZY_ZAWIERA('A') = 0
    AND
    KOT.MIESIAC_PRZYSTAPIENIA() != 1
  THEN
    DBMS_OUTPUT.PUT_LINE(KOT.IMIE || ' NIE ODPOWIADA KRYTERIOM');
  END IF;

END;