-- ------------------------------------------------------------
-- TABLA: usuarios
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(255) NOT NULL,
    apellido        VARCHAR(255) NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    telefono        VARCHAR(50),
    rfid_tag        VARCHAR(50) UNIQUE,
    tipo_usuario    VARCHAR(50) NOT NULL DEFAULT 'estudiante'
                    CHECK(tipo_usuario IN ('estudiante','docente','administrativo','externo')),
    activo          SMALLINT NOT NULL DEFAULT 1 CHECK(activo IN (0,1)),
    max_prestamos   INTEGER NOT NULL DEFAULT 3,
    fecha_registro  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_vigencia  TIMESTAMP,
    notas           TEXT
);

-- ------------------------------------------------------------
-- TABLA: libros
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS libros (
    id              SERIAL PRIMARY KEY,
    isbn            VARCHAR(50) UNIQUE,
    titulo          VARCHAR(255) NOT NULL,
    autor           VARCHAR(255) NOT NULL,
    editorial       VARCHAR(255),
    anio_publicacion INTEGER,
    genero          VARCHAR(100),
    descripcion     TEXT,
    qr_codigo       VARCHAR(50) UNIQUE NOT NULL,
    imagen_url      TEXT,
    ubicacion       VARCHAR(100),
    activo          SMALLINT NOT NULL DEFAULT 1 CHECK(activo IN (0,1)),
    fecha_alta      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- TABLA: ejemplares
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ejemplares (
    id              SERIAL PRIMARY KEY,
    libro_id        INTEGER NOT NULL REFERENCES libros(id) ON DELETE RESTRICT,
    codigo_barras   VARCHAR(50) UNIQUE,
    estado          VARCHAR(50) NOT NULL DEFAULT 'disponible'
                    CHECK(estado IN ('disponible','prestado','reservado','mantenimiento','baja')),
    condicion       VARCHAR(50) NOT NULL DEFAULT 'bueno'
                    CHECK(condicion IN ('nuevo','bueno','regular','deteriorado')),
    fecha_adquisicion DATE,
    notas           TEXT
);

-- ------------------------------------------------------------
-- TABLA: prestamos
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS prestamos (
    id              SERIAL PRIMARY KEY,
    usuario_id      INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    ejemplar_id     INTEGER NOT NULL REFERENCES ejemplares(id) ON DELETE RESTRICT,
    fecha_prestamo  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_devolucion_esperada TIMESTAMP NOT NULL,
    fecha_devolucion_real     TIMESTAMP,
    estado          VARCHAR(50) NOT NULL DEFAULT 'activo'
                    CHECK(estado IN ('activo','devuelto','vencido','perdido')),
    rfid_prestamo   VARCHAR(50),
    qr_prestamo     VARCHAR(50),
    rfid_devolucion VARCHAR(50),
    notas           TEXT
);

-- ------------------------------------------------------------
-- TABLA: audit_log
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_log (
    id          SERIAL PRIMARY KEY,
    timestamp   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo        VARCHAR(50) NOT NULL,
    origen      VARCHAR(50) NOT NULL DEFAULT 'sistema',
    usuario_id  INTEGER REFERENCES usuarios(id),
    ejemplar_id INTEGER REFERENCES ejemplares(id),
    mensaje     TEXT NOT NULL,
    payload_raw TEXT
);

-- ------------------------------------------------------------
-- ÍNDICES
-- ------------------------------------------------------------
CREATE INDEX idx_usuarios_rfid    ON usuarios(rfid_tag);
CREATE INDEX idx_libros_qr        ON libros(qr_codigo);
CREATE INDEX idx_ejemplares_libro ON ejemplares(libro_id);
CREATE INDEX idx_ejemplares_estado ON ejemplares(estado);
CREATE INDEX idx_prestamos_usuario ON prestamos(usuario_id);
CREATE INDEX idx_prestamos_estado  ON prestamos(estado);
CREATE INDEX idx_audit_timestamp   ON audit_log(timestamp);

-- ------------------------------------------------------------
-- VISTA: prestamos_activos
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW prestamos_activos AS
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
        WHEN p.fecha_devolucion_esperada < CURRENT_TIMESTAMP THEN 1 ELSE 0
    END AS vencido
FROM prestamos p
JOIN usuarios  u ON p.usuario_id  = u.id
JOIN ejemplares e ON p.ejemplar_id = e.id
JOIN libros    l ON e.libro_id    = l.id
WHERE p.estado = 'activo';

-- ------------------------------------------------------------
-- VISTA: estadisticas_dashboard
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW estadisticas_dashboard AS
SELECT
    (SELECT COUNT(*) FROM usuarios WHERE activo = 1) AS total_usuarios,
    (SELECT COUNT(*) FROM libros   WHERE activo = 1) AS total_libros,
    (SELECT COUNT(*) FROM ejemplares WHERE estado = 'disponible') AS ejemplares_disponibles,
    (SELECT COUNT(*) FROM ejemplares WHERE estado = 'prestado')   AS ejemplares_prestados,
    (SELECT COUNT(*) FROM prestamos  WHERE estado = 'activo')     AS prestamos_activos,
    (SELECT COUNT(*) FROM prestamos
     WHERE estado = 'activo'
     AND fecha_devolucion_esperada < CURRENT_TIMESTAMP) AS prestamos_vencidos;
