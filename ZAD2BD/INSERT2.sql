use biuro
GO

INSERT INTO Nieruchomosc (id_nieruchomosci, adres, metraz, pietro, liczba_pokoi, stan, id_wlasciciela, nazwa_miasta) VALUES
(30, 'Zielona Dolina 1', 55.00, 0, 3, 'Deweloperski', 1, 'Gdañsk'), -- Parter
(31, 'Podniebna 5', 55.00, 4, 3, 'Deweloperski', 1, 'Gdañsk'),    -- Piêtro
(26, 'Przyjazna 1', 45.00, 0, 2, 'Do remontu', 1, 'Warszawa'),
(27, 'Wysoka 10', 60.00, 3, 3, 'Do remontu', 1, 'Kraków'),
(40, 'Szafarnia 10', 95.00, 3, 3, 'Luksusowy', 1, 'Gdañsk');

INSERT INTO Nieruchomosc_udogodnienia (id_nieruchomosc_udogodnienie, id_nieruchomosci, id_udogodnienia) VALUES
(30, 30, 4), -- ogródek
(31, 31, 1), -- balkon
(26, 27, 3); -- winda

INSERT INTO Oferta (id_oferty, cena, data_publikacji, marza, status, id_nieruchomosci) VALUES
(30, 600000.00, '2023-06-01', 0.03, 'Zrealizowana', 30),
(31, 620000.00, '2023-06-01', 0.03, 'Zrealizowana', 31),
(26, 950000.00, '2024-01-20', 0.05, 'Aktywna', 1), --flip
(27, 420000.00, '2024-01-22', 0.03, 'Aktywna', 26), --parterowe mieszkanie
(28, 580000.00, '2024-01-23', 0.03, 'Aktywna', 27), -- z winda
(40, 1800000.00, '2024-01-26', 0.05, 'Aktywna', 40);

INSERT INTO Transakcja (id_transakcji, cena_sprzedazy, data_sprzedazy, id_oferty, id_kupujacego) VALUES
(30, 590000.00, '2023-09-01', 30, 2), --ogródek
(31, 615000.00, '2023-06-10', 31, 3); --balkon



INSERT INTO Osoba (PESEL, imie, nazwisko, nr_telefonu) VALUES
('75010199999', 'Izabela', 'Bogacka', '700800900');

INSERT INTO Kupujacy (id_kupujacego, PESEL) VALUES
(30, '75010199999');

INSERT INTO Zapotrzebowanie (id_zapotrzebowania, pref_liczba_pokoi, budzet, pref_pietro, pref_metraz, pref_stan, data, id_kupujacego, lokalizacja) VALUES
(30, 4, 2000000.00, 2, 100.00, 'Wysoki standard', '2024-01-25', 30, 'Gdañsk');
