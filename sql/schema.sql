-- ============================================================
-- SISTEMA DE BIBLIOTECA - ESQUEMA SQLite
-- Archivo: 01_schema.sql
-- Descripción: DDL completo para el sistema de biblioteca IoT
-- Versión: 1.0.0
-- ============================================================

PRAGMA journal_mode = WAL;       -- Write-Ahead Logging para mejor concurrencia
PRAGMA foreign_keys = ON;        -- Activar integridad referencial
PRAGMA synchronous = NORMAL;     -- Balance entre seguridad y rendimiento

-- ------------------------------------------------------------
-- TABLA: usuarios
-- Almacena lectores/miembros de la biblioteca
-- El campo rfid_tag es el identificador del lector RFID físico
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre          TEXT    NOT NULL,
    apellido        TEXT    NOT NULL,
    email           TEXT    UNIQUE NOT NULL,
    telefono        TEXT,
    rfid_tag        TEXT    UNIQUE,          -- UID del tag RFID (p.ej. "A3F2B1C4")
    tipo_usuario    TEXT    NOT NULL DEFAULT 'estudiante'
                            CHECK(tipo_usuario IN ('estudiante','docente','administrativo','externo')),
    activo          INTEGER NOT NULL DEFAULT 1 CHECK(activo IN (0,1)),
    max_prestamos   INTEGER NOT NULL DEFAULT 3,
    fecha_registro  TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    fecha_vigencia  TEXT,                    -- NULL = sin vencimiento
    notas           TEXT
);

-- ------------------------------------------------------------
-- TABLA: libros
-- Catálogo bibliográfico (metadata del título)
-- El campo qr_codigo es el identificador único del QR impreso
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS libros (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    isbn            TEXT    UNIQUE,
    titulo          TEXT    NOT NULL,
    autor           TEXT    NOT NULL,
    editorial       TEXT,
    anio_publicacion INTEGER,
    genero          TEXT,
    descripcion     TEXT,
    qr_codigo       TEXT    UNIQUE NOT NULL, -- Código QR (p.ej. "LIB-00042")
    imagen_url      TEXT,                    -- URL portada (opcional)
    ubicacion       TEXT,                    -- Estante/pasillo (p.ej. "A3-12")
    activo          INTEGER NOT NULL DEFAULT 1 CHECK(activo IN (0,1)),
    fecha_alta      TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

-- ------------------------------------------------------------
-- TABLA: ejemplares
-- Copias físicas de cada libro (un libro puede tener N ejemplares)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ejemplares (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    libro_id        INTEGER NOT NULL REFERENCES libros(id) ON DELETE RESTRICT,
    codigo_barras   TEXT    UNIQUE,          -- Etiqueta interna (opcional)
    estado          TEXT    NOT NULL DEFAULT 'disponible'
                            CHECK(estado IN ('disponible','prestado','reservado',
                                             'mantenimiento','baja')),
    condicion       TEXT    NOT NULL DEFAULT 'bueno'
                            CHECK(condicion IN ('nuevo','bueno','regular','deteriorado')),
    fecha_adquisicion TEXT,
    notas           TEXT
);

-- ------------------------------------------------------------
-- TABLA: prestamos
-- Registro de préstamos y devoluciones
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS prestamos (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id      INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    ejemplar_id     INTEGER NOT NULL REFERENCES ejemplares(id) ON DELETE RESTRICT,
    fecha_prestamo  TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    fecha_devolucion_esperada TEXT NOT NULL,  -- Se calcula al crear
    fecha_devolucion_real     TEXT,           -- NULL = aún prestado
    estado          TEXT    NOT NULL DEFAULT 'activo'
                            CHECK(estado IN ('activo','devuelto','vencido','perdido')),
    -- Campos de auditoría IoT
    rfid_prestamo   TEXT,   -- Tag RFID escaneado al prestar
    qr_prestamo     TEXT,   -- QR escaneado al prestar
    rfid_devolucion TEXT,   -- Tag RFID escaneado al devolver
    notas           TEXT
);

-- ------------------------------------------------------------
-- TABLA: audit_log
-- Registro de todas las operaciones del sistema (IoT + manual)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_log (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp   TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    tipo        TEXT    NOT NULL, -- 'prestamo','devolucion','error','backup','login'
    origen      TEXT    NOT NULL DEFAULT 'sistema', -- 'rfid','qr','api','manual'
    usuario_id  INTEGER REFERENCES usuarios(id),
    ejemplar_id INTEGER REFERENCES ejemplares(id),
    mensaje     TEXT    NOT NULL,
    payload_raw TEXT    -- JSON crudo recibido del hardware (para debugging)
);

-- ------------------------------------------------------------
-- ÍNDICES para optimizar consultas frecuentes
-- ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_usuarios_rfid    ON usuarios(rfid_tag);
CREATE INDEX IF NOT EXISTS idx_libros_qr        ON libros(qr_codigo);
CREATE INDEX IF NOT EXISTS idx_ejemplares_libro ON ejemplares(libro_id);
CREATE INDEX IF NOT EXISTS idx_ejemplares_estado ON ejemplares(estado);
CREATE INDEX IF NOT EXISTS idx_prestamos_usuario ON prestamos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_prestamos_estado  ON prestamos(estado);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp   ON audit_log(timestamp);

-- ------------------------------------------------------------
-- VISTA: prestamos_activos
-- Facilita la consulta del estado actual de préstamos
-- ------------------------------------------------------------
CREATE VIEW IF NOT EXISTS prestamos_activos AS
SELECT
    p.id            AS prestamo_id,
    u.nombre || ' ' || u.apellido AS usuario_nombre,
    u.rfid_tag,
    u.email,
    l.titulo,
    l.autor,
    l.qr_codigo,
    e.id            AS ejemplar_id,
    e.codigo_barras,
    p.fecha_prestamo,
    p.fecha_devolucion_esperada,
    CASE
        WHEN p.fecha_devolucion_esperada < datetime('now','localtime')
        THEN 1 ELSE 0
    END             AS vencido
FROM prestamos p
JOIN usuarios  u ON p.usuario_id  = u.id
JOIN ejemplares e ON p.ejemplar_id = e.id
JOIN libros    l ON e.libro_id    = l.id
WHERE p.estado = 'activo';

-- ------------------------------------------------------------
-- VISTA: estadisticas_dashboard
-- Métricas rápidas para el panel administrativo
-- ------------------------------------------------------------
CREATE VIEW IF NOT EXISTS estadisticas_dashboard AS
SELECT
    (SELECT COUNT(*) FROM usuarios WHERE activo = 1)          AS total_usuarios,
    (SELECT COUNT(*) FROM libros   WHERE activo = 1)          AS total_libros,
    (SELECT COUNT(*) FROM ejemplares WHERE estado = 'disponible') AS ejemplares_disponibles,
    (SELECT COUNT(*) FROM ejemplares WHERE estado = 'prestado')   AS ejemplares_prestados,
    (SELECT COUNT(*) FROM prestamos  WHERE estado = 'activo')     AS prestamos_activos,
    (SELECT COUNT(*) FROM prestamos
     WHERE estado = 'activo'
     AND fecha_devolucion_esperada < datetime('now','localtime'))  AS prestamos_vencidos;
