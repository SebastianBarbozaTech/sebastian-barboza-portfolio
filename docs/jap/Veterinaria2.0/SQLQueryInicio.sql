-- Crear base de datos
CREATE DATABASE Veterinaria;
USE Veterinaria;

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
    ClienteID INT NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Especie NVARCHAR(50) NOT NULL CHECK (Especie IN ('Perro', 'Gato', 'Ave', 'Otro')),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Tabla de Vacunas
CREATE TABLE Vacunas (
    VacunaID INT IDENTITY(1,1) PRIMARY KEY,
    MascotaID INT NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Dosis NVARCHAR(50) NOT NULL CHECK (Dosis IN ('Primera', 'Segunda', 'Tercera')),
    FechaAplicacion DATE NOT NULL,
    FechaVencimiento DATE NOT NULL,
    FOREIGN KEY (MascotaID) REFERENCES Mascotas(MascotaID)
);

-- Tabla de Usuarios (para autenticación)
CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    NombreUsuario NVARCHAR(50) NOT NULL UNIQUE,
    Contrasenia NVARCHAR(255) NOT NULL,
    Rol NVARCHAR(50) NOT NULL CHECK (Rol IN ('Administrador', 'Empleado'))
);