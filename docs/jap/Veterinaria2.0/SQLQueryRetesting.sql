CREATE DATABASE VeterinariaGuauGuau;
USE VeterinariaGuauGuau;

-- Tabla de Clientes
CREATE TABLE Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL,
    Apellido NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Direccion NVARCHAR(255) NOT NULL
);

-- Tabla de Mascotas
CREATE TABLE Mascotas (
    MascotaID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT FOREIGN KEY REFERENCES Clientes(ClienteID),
    Nombre NVARCHAR(50) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Especie NVARCHAR(50) NOT NULL
);

-- Tabla de Vacunas
CREATE TABLE Vacunas (
    VacunaID INT IDENTITY(1,1) PRIMARY KEY,
    MascotaID INT FOREIGN KEY REFERENCES Mascotas(MascotaID),
    Nombre NVARCHAR(100) NOT NULL,
    Dosis NVARCHAR(50) NOT NULL,
    FechaAplicacion DATE NOT NULL,
    FechaVencimiento DATE NOT NULL
);