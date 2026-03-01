use biuro
go

--Inwestor chce kupi� mieszkanie inwestycyjne na wynajem kr�tkoterminowy w
--konkretnym mie�cie (np. Gda�sku) jako apartament niewymagaj�cy remontu.
--Wy�wietl oferty odpowiadaj�ce podanemu zapotrzebowaniu.
SELECT 
    n.nazwa_miasta,
    n.adres,
    n.metraz,
    n.liczba_pokoi,
    n.stan,
    o.cena,
    o.data_publikacji,
    CAST(ROUND(o.cena / n.metraz, 0) AS INT) AS cena_za_m2
FROM Oferta o
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
WHERE 
    n.nazwa_miasta IN ('Gdańsk' , 'Warszawa') 
    AND n.stan NOT IN ('Do remontu', 'Do odświeżenia')
    AND o.status = 'Aktywna'
ORDER BY 
    o.cena ASC



--Sprawdź różnicę czasu, który upływa od momentu publikacji oferty do sprzedaży
--transakcji dla mieszkań posiadających balkon oraz ogródek w celu sprawdzenia teorii
--dot. dłuższej sprzedaży mieszkań na parterze
SELECT 
    u.nazwa AS udogodnienie,
    COUNT(t.id_transakcji) AS liczba_transakcji,
    AVG(DATEDIFF(day, o.data_publikacji, t.data_sprzedazy)) AS sredni_czas_sprzedazy_dni
FROM Transakcja t
JOIN Oferta o ON t.id_oferty = o.id_oferty
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
JOIN Nieruchomosc_udogodnienia nu ON n.id_nieruchomosci = nu.id_nieruchomosci
JOIN Udogodnienie u ON nu.id_udogodnienia = u.id_udogodnienia
WHERE 
    u.nazwa IN ('Balkon', 'Ogródek')
GROUP BY 
    u.nazwa;

--ALTERNATYWNE ZAPYTANIE JESLI BRAK ZMIANY INSERTOW
--SELECT 
--    CASE 
--        WHEN n.pietro = 0 THEN 'Parter'
--        ELSE 'Wyzsze pietra'
--    END AS typ_lokalu,
--    COUNT(t.id_transakcji) AS liczba_transakcji,
--    AVG(DATEDIFF(day, o.data_publikacji, t.data_sprzedazy)) AS sredni_czas_sprzedazy_dni
--FROM Transakcja t
--JOIN Oferta o ON t.id_oferty = o.id_oferty
--JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
--GROUP BY 
--    CASE 
--        WHEN n.pietro = 0 THEN 'Parter'
--        ELSE 'Wyzsze pietra'
--    END;





--Wyświetl listę mieszkań o statusie "do remontu", których cena ofertowa jest niższa
--niż 80% średniej ceny transakcyjnej w tym samym mieście w celu znalezienia
--nieruchomości z potencjałem inwestycyjnym dla flipperów.

IF OBJECT_ID('v_SrednieCenyMiast', 'V') IS NOT NULL
    DROP VIEW v_SrednieCenyMiast;
GO


CREATE VIEW v_SrednieCenyMiast AS
SELECT 
    n.nazwa_miasta,
    AVG(t.cena_sprzedazy) AS srednia_cena_transakcyjna
FROM Transakcja t
JOIN Oferta o ON t.id_oferty = o.id_oferty
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
GROUP BY n.nazwa_miasta;
GO

SELECT 
    n.nazwa_miasta,
    n.adres,
    n.metraz,
    n.stan,
    CAST(o.cena AS INT) AS cena_ofertowa,
    CAST(v.srednia_cena_transakcyjna AS INT) AS rynkowa_cena_transakcyjna,
    CAST((o.cena / v.srednia_cena_transakcyjna) * 100 AS DECIMAL(5,2)) AS procent_sredniej_ceny
FROM Oferta o
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
JOIN v_SrednieCenyMiast v ON n.nazwa_miasta = v.nazwa_miasta
WHERE 
    --n.stan = 'Do remontu'  AND --WARTO ZAKOMENTOWAC
    o.status = 'Aktywna'
    AND o.cena < (0.8 * v.srednia_cena_transakcyjna)
ORDER BY 
    procent_sredniej_ceny ASC;



--Biuro sprzedaży nieruchomości chce sprawdzić, stosunek zapotrzebowania na
--nieruchomości do ilości mieszkań (dla każdego miasta osobno), które mają w ofercie.
--Napisz zapytanie, które pokaże o ile w każdym mieście zapotrzebowanie przewyższa
--dostępność i posortuj miasta od największego (brakującego) zapotrzebowania.
WITH Popyt AS (
    SELECT 
        lokalizacja, 
        COUNT(id_zapotrzebowania) AS liczba_chetnych
    FROM Zapotrzebowanie
    GROUP BY lokalizacja
),
Podaz AS (
    SELECT 
        n.nazwa_miasta, 
        COUNT(o.id_oferty) AS liczba_mieszkan
    FROM Oferta o
    JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
    WHERE o.status = 'Aktywna'
    GROUP BY n.nazwa_miasta
)

SELECT 
    l.nazwa_miasta,
    ISNULL(p.liczba_chetnych, 0) AS zapotrzebowanie,
    ISNULL(s.liczba_mieszkan, 0) AS dostepne_oferty,
    -- obliczenie deficytu
    (ISNULL(p.liczba_chetnych, 0) - ISNULL(s.liczba_mieszkan, 0)) AS brakujace_mieszkania
FROM Lokalizacja l
LEFT JOIN Popyt p ON l.nazwa_miasta = p.lokalizacja
LEFT JOIN Podaz s ON l.nazwa_miasta = s.nazwa_miasta
-- popyt lub podaż > 0
WHERE ISNULL(p.liczba_chetnych, 0) > 0 OR ISNULL(s.liczba_mieszkan, 0) > 0
ORDER BY 
    brakujace_mieszkania DESC;




--Sporządź zestawienie X ofert z nieruchomościami, które nie sprzedały się najdłużej,
--aby zmniejszych im cenę lub marżę, żeby sprzedać je szybciej.
SELECT TOP 10
    n.nazwa_miasta,
    n.adres,
    o.cena AS aktualna_cena,
    o.marza,
    o.data_publikacji,
    DATEDIFF(day, o.data_publikacji, GETDATE()) AS dni_na_rynku
FROM Oferta o
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
WHERE 
    o.status = 'Aktywna'
ORDER BY 
    o.data_publikacji ASC;


--Biuro sprzedaży nieruchomości chce na swojej stronie opublikować statystyki z
--średnią ceną metra kwadratowego mieszkań w każdym mieście. Napisz zapytanie,
--które obliczy średnią cenę metra kwadratowego mieszkań w każdym mieście.
SELECT 
    n.nazwa_miasta,
    CAST(ROUND(AVG(o.cena / n.metraz), 0) AS INT) AS srednia_cena_m2,
    COUNT(o.id_oferty) AS liczba_analizowanych_ofert
FROM Oferta o
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
GROUP BY 
    n.nazwa_miasta
ORDER BY 
    srednia_cena_m2 DESC;




-- Znajdź mieszkania bez balkonu ale z garażem, dla fana motoryzacji i spalin
SELECT 
    n.id_nieruchomosci,
    n.adres,
    n.nazwa_miasta,
    n.pietro,
    n.metraz,
    o.cena,
STRING_AGG(u.nazwa, ', ') WITHIN GROUP (ORDER BY u.nazwa) AS lista_udogodnien
FROM Nieruchomosc n
JOIN Oferta o ON n.id_nieruchomosci = o.id_nieruchomosci
LEFT JOIN Nieruchomosc_udogodnienia nu ON n.id_nieruchomosci = nu.id_nieruchomosci
LEFT JOIN Udogodnienie u ON nu.id_udogodnienia = u.id_udogodnienia
WHERE
    NOT EXISTS (
        SELECT 1
        FROM Nieruchomosc_udogodnienia nu
        JOIN Udogodnienie u ON nu.id_udogodnienia = u.id_udogodnienia
        WHERE nu.id_nieruchomosci = n.id_nieruchomosci
        AND u.nazwa = 'Balkon'
    )
    AND EXISTS (
        SELECT 1
        FROM Nieruchomosc_udogodnienia nu
        JOIN Udogodnienie u ON nu.id_udogodnienia = u.id_udogodnienia
        WHERE nu.id_nieruchomosci = n.id_nieruchomosci
        AND u.nazwa = 'Garaż podziemny'
    )

GROUP BY
    n.id_nieruchomosci,
    n.adres, 
    n.nazwa_miasta, 
    n.pietro, 
    n.metraz, 
    o.cena
ORDER BY 
    n.id_nieruchomosci ASC,
    o.cena ASC;



--Zestawienie mieszkań, które miały kiedyś zrealizowaną ofertę sprzedaży , i ponownie pojawiły
--się na sprzedaż. (Porównanie cen ofert itp.)
SELECT 
    n.adres,
    n.nazwa_miasta,
    t_old.data_sprzedazy AS data_poprzedniego_zakupu,
    t_old.cena_sprzedazy AS cena_poprzedniego_zakupu,
    o_new.data_publikacji AS data_nowej_oferty,
    o_new.cena AS cena_nowej_oferty,
    (o_new.cena - t_old.cena_sprzedazy) AS roznica_ceny
FROM Oferta o_new
JOIN Nieruchomosc n ON o_new.id_nieruchomosci = n.id_nieruchomosci
JOIN Transakcja t_old ON t_old.id_oferty IN (
    SELECT id_oferty FROM Oferta WHERE id_nieruchomosci = n.id_nieruchomosci AND id_oferty != o_new.id_oferty
)
WHERE 
    o_new.status = 'Aktywna'
ORDER BY 
    roznica_ceny DESC;



-- Znalezienie oferty na mieszkanie w Warszawie z windą lub na parterze dla osoby na wózku.
SELECT 
    n.nazwa_miasta,
    n.adres,
    n.pietro,
    n.stan,
    o.cena,
    CASE 
        WHEN n.pietro = 0 THEN 'Parter'
        ELSE 'Winda'
    END AS powod_dostepnosci
FROM Oferta o
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
WHERE
    n.nazwa_miasta= 'Warszawa'
    AND o.status = 'Aktywna'
    AND (
        n.pietro = 0 
        OR EXISTS (
            SELECT 1 
            FROM Nieruchomosc_udogodnienia nu 
            JOIN Udogodnienie u ON nu.id_udogodnienia = u.id_udogodnienia
            WHERE nu.id_nieruchomosci = n.id_nieruchomosci 
            AND u.nazwa = 'Winda'
        )
    )
ORDER BY o.cena ASC;



--Znajdź osoby, które jeszcze nie kupiły mieszkania, ale mają budżet
--co najmniej 20% wyższy niż średnia cena transakcyjna w danym mieście.
--Dodatkowo policz, ile mamy dla nich aktualnych ofert mieszczących się w budżecie.
SELECT 
    os.imie,
    os.nazwisko,
    os.nr_telefonu,
    z.lokalizacja AS miasto_poszukiwan,
    z.budzet AS deklarowany_budzet,
    
    (SELECT CAST(AVG(t.cena_sprzedazy) AS INT)
     FROM Transakcja t
     JOIN Oferta oft ON t.id_oferty = oft.id_oferty
     JOIN Nieruchomosc n ON oft.id_nieruchomosci = n.id_nieruchomosci
     WHERE n.nazwa_miasta = z.lokalizacja) AS srednia_cena_rynkowa_w_miescie,

    (SELECT COUNT(*)
     FROM Oferta oft2
     JOIN Nieruchomosc n2 ON oft2.id_nieruchomosci = n2.id_nieruchomosci
     WHERE n2.nazwa_miasta = z.lokalizacja
       AND oft2.status = 'Aktywna'
       AND oft2.cena <= z.budzet) AS liczba_dostepnych_ofert_w_budzecie

FROM Zapotrzebowanie z
JOIN Kupujacy k ON z.id_kupujacego = k.id_kupujacego
JOIN Osoba os ON k.PESEL = os.PESEL
WHERE 
    --wykluczenie już klientów
    k.id_kupujacego NOT IN (SELECT id_kupujacego FROM Transakcja)
    
    AND z.budzet > 1.2 * (
        SELECT AVG(t.cena_sprzedazy)
        FROM Transakcja t
        JOIN Oferta oft ON t.id_oferty = oft.id_oferty
        JOIN Nieruchomosc n ON oft.id_nieruchomosci = n.id_nieruchomosci
        WHERE n.nazwa_miasta = z.lokalizacja
    )
ORDER BY 
    z.budzet DESC;