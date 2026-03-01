USE biuro;
GO

--slownikowe
CREATE TABLE Lokalizacja (
    nazwa_miasta VARCHAR(50) PRIMARY KEY,
    wojewodztwo VARCHAR(50) NOT NULL
);

CREATE TABLE Udogodnienie (
    id_udogodnienia INT PRIMARY KEY,
    nazwa VARCHAR(50) NOT NULL
);

CREATE TABLE Osoba (
    PESEL CHAR(11) PRIMARY KEY,
    imie VARCHAR(40) NOT NULL,
    nazwisko VARCHAR(40) NOT NULL,
    nr_telefonu VARCHAR(14) NOT NULL UNIQUE
);

CREATE TABLE Wlasciciel (
    id_wlasciciela INT PRIMARY KEY,
    PESEL CHAR(11) NOT NULL UNIQUE,
    FOREIGN KEY (PESEL) REFERENCES Osoba(PESEL) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Kupujacy (
    id_kupujacego INT PRIMARY KEY,
    PESEL CHAR(11) NOT NULL UNIQUE,
    FOREIGN KEY (PESEL) REFERENCES Osoba(PESEL) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Nieruchomosc (
    id_nieruchomosci INT PRIMARY KEY,
    adres VARCHAR(100) NOT NULL UNIQUE,
    metraz DECIMAL(10,2) NOT NULL CHECK (metraz > 0),
    pietro INT NOT NULL,
    liczba_pokoi INT NOT NULL CHECK (liczba_pokoi > 0),
    stan VARCHAR(50),
    id_wlasciciela INT NOT NULL,
    nazwa_miasta VARCHAR(50) NOT NULL, 
    FOREIGN KEY (id_wlasciciela) REFERENCES Wlasciciel(id_wlasciciela) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (nazwa_miasta) REFERENCES Lokalizacja(nazwa_miasta) ON UPDATE CASCADE 
);

CREATE TABLE Oferta (
    id_oferty INT PRIMARY KEY,
    cena DECIMAL(12,2) NOT NULL CHECK (cena > 0),
    data_publikacji DATE NOT NULL,
    marza DECIMAL(5,2) DEFAULT 0.03,
    status VARCHAR(20) NOT NULL,
    id_nieruchomosci INT NOT NULL,
    FOREIGN KEY (id_nieruchomosci) REFERENCES Nieruchomosc(id_nieruchomosci) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Transakcja (
    id_transakcji INT PRIMARY KEY,
    cena_sprzedazy DECIMAL(12,2) NOT NULL CHECK (cena_sprzedazy>0),
    data_sprzedazy DATE NOT NULL,
    id_oferty INT NOT NULL,
    id_kupujacego INT NOT NULL,
    FOREIGN KEY (id_oferty) REFERENCES Oferta(id_oferty) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_kupujacego) REFERENCES Kupujacy(id_kupujacego) 
);

CREATE TABLE Zapotrzebowanie (
    id_zapotrzebowania INT PRIMARY KEY,
    pref_liczba_pokoi INT,
    budzet DECIMAL(12,2),
    pref_pietro INT,
    pref_metraz DECIMAL(10,2),
    pref_stan VARCHAR(50),
    data DATE NOT NULL,
    id_kupujacego INT NOT NULL,
    lokalizacja VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_kupujacego) REFERENCES Kupujacy(id_kupujacego) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (lokalizacja) REFERENCES Lokalizacja(nazwa_miasta) ON UPDATE CASCADE
);

CREATE TABLE Nieruchomosc_udogodnienia (
    id_nieruchomosc_udogodnienie INT PRIMARY KEY,
    id_nieruchomosci INT NOT NULL,
    id_udogodnienia INT NOT NULL,
    FOREIGN KEY (id_nieruchomosci) REFERENCES Nieruchomosc(id_nieruchomosci) ON DELETE CASCADE,
    FOREIGN KEY (id_udogodnienia) REFERENCES Udogodnienie(id_udogodnienia) ON DELETE CASCADE
);

CREATE TABLE Zapotrzebowanie_udogodnienia (
    id_zapotrzebowanie_udogodnienia INT PRIMARY KEY,
    id_zapotrzebowania INT NOT NULL,
    id_udogodnienia INT NOT NULL,
    FOREIGN KEY (id_zapotrzebowania) REFERENCES Zapotrzebowanie(id_zapotrzebowania) ON DELETE CASCADE,
    FOREIGN KEY (id_udogodnienia) REFERENCES Udogodnienie(id_udogodnienia) ON DELETE CASCADE
);

CREATE TABLE Oferta_zapotrzebowanie (
    id_oferta_zapotrzebowanie INT PRIMARY KEY,
    id_oferty INT NOT NULL,
    id_zapotrzebowania INT NOT NULL,
    FOREIGN KEY (id_oferty) REFERENCES Oferta(id_oferty) ON DELETE CASCADE,
    FOREIGN KEY (id_zapotrzebowania) REFERENCES Zapotrzebowanie(id_zapotrzebowania)
);