SELECT
    K1.imie "Imie",
     ' | ' " ",
    K1.funkcja, NVL(K2.imie, ' ') "szef 1",
     ' | ' "  ",
    NVL(K3.imie, ' ') "szef 2",
     ' | ' "   ",
    NVL(K4.imie, ' ') "szef 3"
FROM Kocury K1
    LEFT JOIN Kocury K2 ON K1.szef = K2.pseudo
    LEFT JOIN Kocury K3 ON K2.szef = K3.pseudo
    LEFT JOIN Kocury K4 ON K3.szef = K4.pseudo
WHERE K1.funkcja = 'MILUSIA' OR K1.funkcja = 'KOT';


SELECT KP.IMIE, KP.FUNKCJA, KP.SZEF.IMIE, KP.SZEF.SZEF.IMIE, KP.SZEF.SZEF.SZEF.IMIE
FROM KOCURY_test_PER KP
WHERE KP.FUNKCJA = 'MILUSIA' OR KP.FUNKCJA = 'KOT';