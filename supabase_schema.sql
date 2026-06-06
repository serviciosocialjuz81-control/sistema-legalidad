-- =====================================================
-- SISTEMA DE CONTROL DE LEGALIDAD - LEY 26.061
-- Version 3.2 - Schema corregido (triggers, fechas, constraints)
-- =====================================================

-- LIMPIEZA SEGURA: eliminar solo si existen
DROP TABLE IF EXISTS historial CASCADE;
DROP TABLE IF EXISTS casos CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS usuarios_sistema CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS update_casos_timestamp() CASCADE;
DROP FUNCTION IF EXISTS update_usuarios_timestamp() CASCADE;
DROP FUNCTION IF EXISTS parse_fecha_argentina(TEXT) CASCADE;

-- =====================================================
-- FUNCION AUXILIAR: Parsear fechas argentinas DD/MM/YYYY
-- =====================================================
CREATE OR REPLACE FUNCTION parse_fecha_argentina(fecha_texto TEXT)
RETURNS DATE AS $$
BEGIN
    IF fecha_texto IS NULL OR fecha_texto = '' OR fecha_texto = '-' OR fecha_texto = 'NaN días' THEN
        RETURN NULL;
    END IF;
    -- Formato completo: 30/12/2010
    RETURN TO_DATE(fecha_texto, 'DD/MM/YYYY');
EXCEPTION WHEN OTHERS THEN
    -- Formato corto: 30/12/10
    BEGIN
        RETURN TO_DATE(fecha_texto, 'DD/MM/YY');
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =====================================================
-- TABLA: casos
-- =====================================================
CREATE TABLE IF NOT EXISTS casos (
    id BIGINT PRIMARY KEY,

    -- Datos del nino/a
    nombre TEXT NOT NULL,
    fecha_nacimiento DATE,
    dni TEXT,

    -- Datos del expediente
    expediente TEXT NOT NULL,  -- SIN UNIQUE: un expediente puede tener multiples NNyA
    juzgado TEXT,
    tipo_medida TEXT,
    estado TEXT DEFAULT 'Por vencer',
    fecha_vencimiento DATE,
    defensoria TEXT,
    hogar TEXT,
    ubicacion TEXT,

    -- Estrategia
    estrategia TEXT DEFAULT 'Evaluacion en curso',

    -- Datos de audiencias (JSON array)
    audiencias JSONB DEFAULT '[]'::jsonb,

    -- Contactos para notificacion (JSON array)
    contactos JSONB DEFAULT '[]'::jsonb,

    -- Observaciones y CIF
    observaciones TEXT,
    cif TEXT DEFAULT 'no',

    -- Metadatos
    creado_por TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Datos completos como JSON (backup)
    data JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- TABLA: historial
-- =====================================================
CREATE TABLE IF NOT EXISTS historial (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    caso_id BIGINT REFERENCES casos(id) ON DELETE CASCADE,
    accion TEXT NOT NULL,
    descripcion TEXT,
    motivo TEXT,
    usuario TEXT NOT NULL,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    version_anterior INTEGER,
    version_nueva INTEGER,
    cambios JSONB DEFAULT '[]'::jsonb
);

-- =====================================================
-- TABLA: usuarios_sistema (sincronizacion multi-dispositivo)
-- NOTA: usa updated_at (no fecha_actualizacion)
-- =====================================================
CREATE TABLE IF NOT EXISTS usuarios_sistema (
    id BIGINT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    nombre TEXT NOT NULL,
    rol TEXT DEFAULT 'usuario',
    activo BOOLEAN DEFAULT true,
    primer_ingreso BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA: usuarios (legacy)
-- =====================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    rol TEXT DEFAULT 'usuario',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDICES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_casos_estado ON casos(estado);
CREATE INDEX IF NOT EXISTS idx_casos_tipo_medida ON casos(tipo_medida);
CREATE INDEX IF NOT EXISTS idx_casos_fecha_vencimiento ON casos(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_casos_defensoria ON casos(defensoria);
CREATE INDEX IF NOT EXISTS idx_casos_hogar ON casos(hogar);
CREATE INDEX IF NOT EXISTS idx_casos_estrategia ON casos(estrategia);
CREATE INDEX IF NOT EXISTS idx_historial_caso_id ON historial(caso_id);
CREATE INDEX IF NOT EXISTS idx_historial_fecha ON historial(fecha);
CREATE INDEX IF NOT EXISTS idx_usuarios_sistema_username ON usuarios_sistema(username);

-- =====================================================
-- RLS (abierto para desarrollo)
-- =====================================================
ALTER TABLE casos ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios_sistema ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all casos" ON casos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all historial" ON historial FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all usuarios" ON usuarios FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all usuarios_sistema" ON usuarios_sistema FOR ALL USING (true) WITH CHECK (true);

-- =====================================================
-- TRIGGERS: auto-actualizar timestamps (CORREGIDOS)
-- =====================================================

-- Funcion para tabla casos (usa fecha_actualizacion)
CREATE OR REPLACE FUNCTION update_casos_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Funcion para tabla usuarios_sistema (usa updated_at)
CREATE OR REPLACE FUNCTION update_usuarios_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para casos
CREATE TRIGGER update_casos_updated_at
    BEFORE UPDATE ON casos
    FOR EACH ROW
    EXECUTE FUNCTION update_casos_timestamp();

-- Trigger para usuarios_sistema
CREATE TRIGGER update_usuarios_sistema_updated_at
    BEFORE UPDATE ON usuarios_sistema
    FOR EACH ROW
    EXECUTE FUNCTION update_usuarios_timestamp();

-- =====================================================
-- COMENTARIOS
-- =====================================================
COMMENT ON TABLE casos IS 'Casos de control de legalidad - Ley 26.061';
COMMENT ON TABLE historial IS 'Historial de cambios de casos';
COMMENT ON TABLE usuarios_sistema IS 'Usuarios sincronizados multi-dispositivo';
COMMENT ON FUNCTION parse_fecha_argentina IS 'Convierte DD/MM/YYYY a DATE. Usar si la app envia fechas en formato argentino.';

-- =====================================================
-- DATOS INICIALES
-- =====================================================
INSERT INTO usuarios (username, nombre, rol, activo) 
VALUES ('admin', 'Administrador', 'admin', true)
ON CONFLICT (username) DO NOTHING;

INSERT INTO usuarios_sistema (id, username, password, nombre, rol, activo, primer_ingreso) 
VALUES (1, 'admin', 'admin123', 'Administrador', 'admin', true, true)
ON CONFLICT (id) DO UPDATE SET 
    password = EXCLUDED.password,
    nombre = EXCLUDED.nombre,
    rol = EXCLUDED.rol,
    activo = EXCLUDED.activo,
    primer_ingreso = EXCLUDED.primer_ingreso;

-- =====================================================
-- INSTRUCCIONES
-- =====================================================
-- 1. Ejecutar TODO este script en Supabase > SQL Editor
-- 2. Ir a Settings > API > Copy Service Role Key
-- 3. Pegar esa key en la app (Configuracion Supabase)
-- 4. IMPORTANTE: Las fechas desde la app deben llegar como YYYY-MM-DD
--    o usar la funcion parse_fecha_argentina() via RPC
-- =====================================================
