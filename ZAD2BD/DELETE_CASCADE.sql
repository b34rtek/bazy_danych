USE biuro;
GO

SELECT * FROM Wlasciciel WHERE id_wlasciciela = 1;
SELECT * FROM Nieruchomosc WHERE id_wlasciciela = 1;

DELETE FROM Osoba WHERE PESEL = '80010112345'; 

SELECT * FROM Wlasciciel WHERE id_wlasciciela = 1;
SELECT * FROM Nieruchomosc WHERE id_wlasciciela = 1;
SELECT * FROM Oferta WHERE id_nieruchomosci IN (1, 21);