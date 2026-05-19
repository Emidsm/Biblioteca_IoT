-- ============================================================
-- SISTEMA DE BIBLIOTECA - DATOS DE PRUEBA
-- Archivo: 02_seed_data.sql
-- Descripción: DML con datos realistas para desarrollo/pruebas
-- ============================================================

-- ------------------------------------------------------------
-- USUARIOS (12 registros con tags RFID simulados)
-- ------------------------------------------------------------
INSERT INTO usuarios (nombre, apellido, email, telefono, rfid_tag, tipo_usuario, max_prestamos, fecha_vigencia) VALUES
('Carlos',    'Mendoza Rivera',    'cmendoza@uni.edu.mx',      '4921234567', 'A3F2B1C4', 'estudiante',    3, '2026-12-31'),
('Sofía',     'Torres Guzmán',     'storres@uni.edu.mx',       '4929876543', 'B7D4E2F1', 'estudiante',    3, '2026-12-31'),
('Dr. Marco', 'López Hernández',   'mlopez@docentes.uni.edu.mx','4923456789','C1A5F3B2', 'docente',       5, NULL),
('Ana',       'Jiménez Castro',    'ajimenez@uni.edu.mx',      '4924567890', 'D8C6E4A3', 'estudiante',    3, '2026-06-30'),
('Roberto',   'Flores Martínez',   'rflores@admin.uni.edu.mx', '4925678901', 'E2B7D5C4', 'administrativo',4, NULL),
('Valentina', 'Ruiz Sánchez',      'vruiz@uni.edu.mx',         '4926789012', 'F4A1C8B5', 'estudiante',    3, '2026-12-31'),
('Dra. Laura','García Morales',    'lgarcia@docentes.uni.edu.mx','4927890123','A6D3F7E2','docente',       5, NULL),
('Miguel',    'Hernández Vega',    'mhernandez@uni.edu.mx',    '4928901234', 'B5E8A2D6', 'estudiante',    3, '2027-01-15'),
('Isabel',    'Martínez Delgado',  'imartinez@uni.edu.mx',     '4920123456', 'C7F1B4A8', 'estudiante',    3, '2026-12-31'),
('Luis',      'Ramírez Ortiz',     'lramirez@extern.mx',       '4921357924', 'D3A9E6C1', 'externo',       2, '2025-06-01'),  -- expirado a propósito
('Paola',     'Chávez Núñez',      'pchavez@uni.edu.mx',       '4922468135', 'E9B2F4D7', 'estudiante',    3, '2026-12-31'),
('Javier',    'Moreno Aguilar',    'jmoreno@docentes.uni.edu.mx','4923579246','F1C5A8E3','docente',       5, NULL);

-- ------------------------------------------------------------
-- LIBROS (15 títulos con QR único y ubicación física)
-- ------------------------------------------------------------
INSERT INTO libros (isbn, titulo, autor, editorial, anio_publicacion, genero, qr_codigo, ubicacion, descripcion) VALUES
('978-0-13-468599-1','Clean Code: A Handbook of Agile Software Craftsmanship','Robert C. Martin','Prentice Hall',2008,'Programación','LIB-00001','A1-01','Guía para escribir código limpio y mantenible.'),
('978-0-201-63361-0','Design Patterns: Elements of Reusable Object-Oriented Software','Gang of Four','Addison-Wesley',1994,'Programación','LIB-00002','A1-02','Los 23 patrones de diseño clásicos de software.'),
('978-0-13-235088-4','The Pragmatic Programmer','David Thomas, Andrew Hunt','Addison-Wesley',2019,'Programación','LIB-00003','A1-03','De aprendiz a maestro en desarrollo de software.'),
('978-607-438-458-1','Cien años de soledad','Gabriel García Márquez','Editorial Sudamericana',1967,'Literatura','LIB-00004','B2-01','Obra cumbre del realismo mágico latinoamericano.'),
('978-84-233-3633-4','El nombre de la rosa','Umberto Eco','Lumen',1980,'Novela histórica','LIB-00005','B2-02','Investigación de una serie de muertes en una abadía medieval.'),
('978-0-13-110362-7','The C Programming Language','Brian Kernighan, Dennis Ritchie','Prentice Hall',1988,'Programación','LIB-00006','A1-04','El libro definitivo del lenguaje C.'),
('978-0-596-51774-8','JavaScript: The Good Parts','Douglas Crockford','O''Reilly Media',2008,'Programación','LIB-00007','A1-05','Las partes esenciales y elegantes de JavaScript.'),
('978-607-07-3823-5','Física universitaria vol. 1','Hugh Young, Roger Freedman','Pearson',2013,'Ciencias','LIB-00008','C3-01','Mecánica, termodinámica y ondas para ingeniería.'),
('978-970-26-0991-7','Cálculo de una variable','James Stewart','Cengage Learning',2008,'Matemáticas','LIB-00009','C3-02','Límites, derivadas e integrales de una variable.'),
('978-0-321-12521-7','Domain-Driven Design','Eric Evans','Addison-Wesley',2003,'Programación','LIB-00010','A1-06','Cómo modelar software complejo con DDD.'),
('978-0-13-792025-5','Artificial Intelligence: A Modern Approach','Stuart Russell, Peter Norvig','Pearson',2020,'IA/ML','LIB-00011','A2-01','El texto de referencia más completo sobre Inteligencia Artificial.'),
('978-1-491-95229-7','Hands-On Machine Learning with Scikit-Learn','Aurélien Géron','O''Reilly Media',2019,'IA/ML','LIB-00012','A2-02','ML práctico con Python, Scikit-Learn y TensorFlow.'),
('978-607-17-0736-5','Introducción a los sistemas de bases de datos','C.J. Date','Pearson',2001,'Bases de Datos','LIB-00013','A3-01','Fundamentos teóricos y prácticos de bases de datos relacionales.'),
('978-1-491-91205-8','Learning Python','Mark Lutz','O''Reilly Media',2013,'Programación','LIB-00014','A1-07','El manual más completo del lenguaje Python.'),
('978-0-13-598128-8','Computer Networks','Andrew Tanenbaum','Pearson',2010,'Redes','LIB-00015','A4-01','Fundamentos de redes de computadoras y protocolos.');

-- ------------------------------------------------------------
-- EJEMPLARES (2-3 por libro popular, 1 para el resto)
-- ------------------------------------------------------------
-- Clean Code (3 ejemplares)
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(1, 'EJ-001-A', 'disponible', 'bueno',   '2021-03-15'),
(1, 'EJ-001-B', 'prestado',   'bueno',   '2021-03-15'),
(1, 'EJ-001-C', 'disponible', 'regular', '2019-08-20');

-- Design Patterns (2 ejemplares)
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(2, 'EJ-002-A', 'disponible',    'nuevo',  '2023-01-10'),
(2, 'EJ-002-B', 'mantenimiento', 'deteriorado', '2018-05-05');

-- The Pragmatic Programmer (2 ejemplares)
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(3, 'EJ-003-A', 'prestado',   'bueno', '2022-09-01'),
(3, 'EJ-003-B', 'disponible', 'nuevo', '2023-11-20');

-- Cien años de soledad (3 ejemplares)
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(4, 'EJ-004-A', 'disponible', 'bueno',      '2020-06-15'),
(4, 'EJ-004-B', 'disponible', 'regular',    '2017-03-22'),
(4, 'EJ-004-C', 'prestado',   'bueno',      '2022-01-08');

-- El nombre de la rosa
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(5, 'EJ-005-A', 'disponible', 'bueno', '2021-07-30');

-- The C Programming Language (2 ejemplares)
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(6, 'EJ-006-A', 'disponible', 'regular',    '2015-04-10'),
(6, 'EJ-006-B', 'prestado',   'deteriorado','2010-11-25');

-- JavaScript: The Good Parts
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(7, 'EJ-007-A', 'disponible', 'bueno', '2022-02-14');

-- Física universitaria (3 ejemplares)
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(8, 'EJ-008-A', 'disponible', 'bueno',   '2020-08-01'),
(8, 'EJ-008-B', 'prestado',   'regular', '2020-08-01'),
(8, 'EJ-008-C', 'disponible', 'nuevo',   '2024-01-15');

-- Cálculo (2 ejemplares)
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(9,  'EJ-009-A', 'disponible', 'regular', '2019-08-15'),
(9,  'EJ-009-B', 'disponible', 'bueno',   '2022-08-15');

-- Los demás: 1 ejemplar c/u
INSERT INTO ejemplares (libro_id, codigo_barras, estado, condicion, fecha_adquisicion) VALUES
(10, 'EJ-010-A', 'disponible', 'nuevo',  '2023-05-01'),
(11, 'EJ-011-A', 'disponible', 'nuevo',  '2023-05-01'),
(12, 'EJ-012-A', 'prestado',   'bueno',  '2022-11-10'),
(13, 'EJ-013-A', 'disponible', 'regular','2018-03-20'),
(14, 'EJ-014-A', 'disponible', 'bueno',  '2021-09-05'),
(15, 'EJ-015-A', 'disponible', 'bueno',  '2023-03-12');

-- ------------------------------------------------------------
-- PRÉSTAMOS ACTIVOS Y HISTÓRICOS
-- ------------------------------------------------------------
-- Préstamos activos (estado='prestado' en ejemplares)
INSERT INTO prestamos (usuario_id, ejemplar_id, fecha_prestamo, fecha_devolucion_esperada, estado, rfid_prestamo, qr_prestamo) VALUES
(1,  2,  datetime('now','-5 days','localtime'),  datetime('now','+9 days','localtime'),  'activo', 'A3F2B1C4', 'LIB-00001'), -- Carlos tiene Clean Code B
(3,  6,  datetime('now','-2 days','localtime'),  datetime('now','+12 days','localtime'), 'activo', 'C1A5F3B2', 'LIB-00003'), -- Dr. Marco tiene Pragmatic B
(4,  12, datetime('now','-8 days','localtime'),  datetime('now','+6 days','localtime'),  'activo', 'D8C6E4A3', 'LIB-00004'), -- Ana tiene Cien años C
(6,  14, datetime('now','-3 days','localtime'),  datetime('now','+11 days','localtime'), 'activo', 'F4A1C8B5', 'LIB-00006'), -- Valentina tiene C lang B
(8,  18, datetime('now','-10 days','localtime'), datetime('now','+4 days','localtime'),  'activo', 'B5E8A2D6', 'LIB-00008'), -- Miguel tiene Física B
(11, 23, datetime('now','-15 days','localtime'), datetime('now','-1 days','localtime'),  'activo', 'E9B2F4D7', 'LIB-00012'); -- Paola tiene ML (VENCIDO)

-- Historial devuelto (últimos 3 meses)
INSERT INTO prestamos (usuario_id, ejemplar_id, fecha_prestamo, fecha_devolucion_esperada, fecha_devolucion_real, estado, rfid_prestamo, qr_prestamo, rfid_devolucion) VALUES
(2,  1,  datetime('now','-30 days','localtime'), datetime('now','-16 days','localtime'), datetime('now','-18 days','localtime'), 'devuelto', 'B7D4E2F1', 'LIB-00001', 'B7D4E2F1'),
(5,  7,  datetime('now','-45 days','localtime'), datetime('now','-31 days','localtime'), datetime('now','-32 days','localtime'), 'devuelto', 'E2B7D5C4', 'LIB-00003', 'E2B7D5C4'),
(7,  10, datetime('now','-20 days','localtime'), datetime('now','-6 days','localtime'),  datetime('now','-7 days','localtime'),  'devuelto', 'A6D3F7E2', 'LIB-00004', 'A6D3F7E2'),
(9,  16, datetime('now','-60 days','localtime'), datetime('now','-46 days','localtime'), datetime('now','-44 days','localtime'), 'devuelto', 'C7F1B4A8', 'LIB-00006', 'C7F1B4A8'),
(12, 21, datetime('now','-14 days','localtime'), datetime('now','localtime'),            datetime('now','-1 days','localtime'),  'devuelto', 'F1C5A8E3', 'LIB-00009', 'F1C5A8E3');

-- ------------------------------------------------------------
-- AUDIT LOG inicial
-- ------------------------------------------------------------
INSERT INTO audit_log (tipo, origen, mensaje) VALUES
('backup', 'sistema', 'Respaldo inicial del sistema completado.'),
('login',  'api',     'Sistema IoT iniciado correctamente.');
