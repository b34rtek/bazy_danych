use biuro
go

--Inwestor chce kupiæ mieszkanie inwestycyjne na wynajem krótkoterminowy w
--konkretnym mieœcie (np. Gdañsku) jako apartament niewymagaj¹cy remontu.
--Wyœwietl oferty odpowiadaj¹ce podanemu zapotrzebowaniu.
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
    n.nazwa_miasta IN ('Gdañsk' , 'Warszawa') 
    AND n.stan NOT IN ('Do remontu', 'Do odœwie¿enia')
    AND o.status = 'Aktywna'
ORDER BY 
    o.cena ASC



--SprawdŸ ró¿nicê czasu, który up³ywa od momentu publikacji oferty do sprzeda¿y
--transakcji dla mieszkañ posiadaj¹cych balkon oraz ogródek w celu sprawdzenia teorii
--dot. d³u¿szej sprzeda¿y mieszkañ na parterze.
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
SELECT 
    CASE 
        WHEN n.pietro = 0 THEN 'Parter'
        ELSE 'Wy¿sze piêtra'
    END AS typ_lokalu,
    COUNT(t.id_transakcji) AS liczba_transakcji,
    AVG(DATEDIFF(day, o.data_publikacji, t.data_sprzedazy)) AS sredni_czas_sprzedazy_dni
FROM Transakcja t
JOIN Oferta o ON t.id_oferty = o.id_oferty
JOIN Nieruchomosc n ON o.id_nieruchomosci = n.id_nieruchomosci
GROUP BY 
    CASE 
        WHEN n.pietro = 0 THEN 'Parter'
        ELSE 'Wy¿sze piêtra'
    END;





--Wyœwietl listê mieszkañ o statusie "do remontu", których cena ofertowa jest ni¿sza
--ni¿ 80% œredniej ceny transakcyjnej w tym samym mieœcie w celu znalezienia
--nieruchomoœci z potencja³em inwestycyjnym dla flipperów.
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