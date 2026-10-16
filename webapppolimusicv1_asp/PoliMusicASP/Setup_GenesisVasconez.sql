-- ============================================
-- Script de preparacion de usuarios de prueba
-- Ejecutar en SQL Server DESPUES de BDD_PoliMusic.sql
--
-- Usuarios de prueba (todos con contrasena: 12345678)
--   userAdmin          -> administrador (USER_TYPE = 1)
--   epn.fis            -> usuario normal (USER_TYPE = 0)
--   genesis.vasconez   -> usuario normal (USER_TYPE = 0)
-- ============================================

USE [BDD_PoliMusic];
GO

-- ------------------------------------------------------------
-- Usuario administrador
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM TBL_USER WHERE USERNAME = 'userAdmin')
BEGIN
    INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE)
    VALUES ('userAdmin', '12345678', 'admin@polimusic.ec', '1990-01-01', '~/UserImages/default.jpg', 1);
    PRINT 'Usuario "userAdmin" creado (administrador).';
END
ELSE
BEGIN
    UPDATE TBL_USER SET PASSWORD = '12345678', USER_TYPE = 1 WHERE USERNAME = 'userAdmin';
    PRINT 'Usuario "userAdmin" actualizado (administrador).';
END
GO

-- ------------------------------------------------------------
-- Usuario normal: epn.fis
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM TBL_USER WHERE USERNAME = 'epn.fis')
BEGIN
    INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE)
    VALUES ('epn.fis', '12345678', 'epn.fis@epn.edu.ec', '2002-03-10', '~/UserImages/default.jpg', 0);
    PRINT 'Usuario "epn.fis" creado (usuario normal).';
END
ELSE
BEGIN
    PRINT 'Usuario "epn.fis" ya existe.';
END
GO

-- ------------------------------------------------------------
-- Usuario normal: genesis.vasconez
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM TBL_USER WHERE USERNAME = 'genesis.vasconez')
BEGIN
    INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE)
    VALUES ('genesis.vasconez', '12345678', 'genesis.vasconez@epn.edu.ec', '2003-05-15', '~/UserImages/default.jpg', 0);
    PRINT 'Usuario "genesis.vasconez" creado (usuario normal).';
END
ELSE
BEGIN
    UPDATE TBL_USER SET PASSWORD = '12345678', USER_TYPE = 0 WHERE USERNAME = 'genesis.vasconez';
    PRINT 'Usuario "genesis.vasconez" actualizado (usuario normal).';
END
GO

-- ------------------------------------------------------------
-- Resumen final
-- ------------------------------------------------------------
SELECT ID_USER, USERNAME, EMAIL, USER_TYPE FROM TBL_USER;
GO
