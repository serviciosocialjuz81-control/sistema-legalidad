-- =====================================================
-- SISTEMA DE CONTROL DE LEGALIDAD - LEY 26.061
-- Version 3.0 - Esquema de Base de datos Supabase
-- =====================================================

-- Eliminar tablas si existen (para actualizacion limpia)
DROP TABLE IF EXISTS historial CASCADE;
DROP TABLE IF EXISTS casos CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- Tabla de casos con todos los campos del formulario
CREATE TABLE IF NOT EXISTS casos (
    id BIGINT PRIMARY KEY,
    
    -- Datos del nino/a
    nombre TEXT NOT NULL,
    fecha_nacimiento DATE,
    dni TEXT,
    
    -- Datos del expediente
    expediente TEXT NOT NULL,
    juzgado TEXT,
    tipo_medida TEXT,
    estado TEXT DEFAULT 'Por vencer',
    fecha_vencimiento DATE,
    defensoria TEXT,
    hogar TEXT,
    ubicacion TEXT,
    
    -- Estrategia
    estrategia TEXT DEFAULT 'Evaluacion en curso',
    
    -- Datos de audiencias (JSON array con tipos, fecha, hora, despachante)
    audiencias JSONB DEFAULT '[]',
    
    -- Contactos para notificacion (JSON array)
    contactos JSONB DEFAULT '[]',
    
    -- Observaciones y CIF
    observaciones TEXT,
    cif TEXT DEFAULT 'no',
    
    -- Metadatos
    creado_por TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Datos completos como JSON (backup)
    data JSONB DEFAULT '{}'
);

-- Tabla de historial de cambios
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
    cambios JSONB DEFAULT '[]'
);

-- Tabla de usuarios del sistema (para sincronizacion multi-dispositivo)
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

-- Tabla de usuarios (legacy, mantenida por compatibilidad)
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    rol TEXT DEFAULT 'usuario',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indices para optimizacion
CREATE INDEX IF NOT EXISTS idx_casos_estado ON casos(estado);
CREATE INDEX IF NOT EXISTS idx_casos_tipo_medida ON casos(tipo_medida);
CREATE INDEX IF NOT EXISTS idx_casos_fecha_vencimiento ON casos(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_casos_defensoria ON casos(defensoria);
CREATE INDEX IF NOT EXISTS idx_casos_hogar ON casos(hogar);
CREATE INDEX IF NOT EXISTS idx_casos_estrategia ON casos(estrategia);
CREATE INDEX IF NOT EXISTS idx_historial_caso_id ON historial(caso_id);
CREATE INDEX IF NOT EXISTS idx_historial_fecha ON historial(fecha);
CREATE INDEX IF NOT EXISTS idx_usuarios_sistema_username ON usuarios_sistema(username);

-- Politicas de seguridad (RLS)
ALTER TABLE casos ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios_sistema ENABLE ROW LEVEL SECURITY;

-- Politicas para casos (permitir todo para desarrollo)
CREATE POLICY "Allow all casos" ON casos
    FOR ALL USING (true) WITH CHECK (true);

-- Politicas para historial
CREATE POLICY "Allow all historial" ON historial
    FOR ALL USING (true) WITH CHECK (true);

-- Politicas para usuarios (legacy)
CREATE POLICY "Allow all usuarios" ON usuarios
    FOR ALL USING (true) WITH CHECK (true);

-- Politicas para usuarios_sistema (sincronizacion multi-dispositivo)
CREATE POLICY "Allow all usuarios_sistema" ON usuarios_sistema
    FOR ALL USING (true) WITH CHECK (true);

-- Funcion para actualizar fecha de actualizacion
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar fecha automaticamente en casos
CREATE TRIGGER update_casos_updated_at
    BEFORE UPDATE ON casos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para actualizar fecha automaticamente en usuarios_sistema
CREATE TRIGGER update_usuarios_sistema_updated_at
    BEFORE UPDATE ON usuarios_sistema
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios
COMMENT ON TABLE casos IS 'Casos de control de legalidad - Ley 26.061';
COMMENT ON TABLE historial IS 'Historial de cambios de casos (sistema de versionado)';
COMMENT ON TABLE usuarios_sistema IS 'Usuarios del sistema sincronizados en todos los dispositivos';
COMMENT ON COLUMN casos.contactos IS 'Array de contactos para notificaciones {tipo, valor}';
COMMENT ON COLUMN casos.audiencias IS 'Array de audiencias {tipos[], fecha, hora, despachante}';
COMMENT ON COLUMN casos.data IS 'Datos completos del caso en formato JSON (backup)';

-- Insertar usuario admin por defecto (tabla legacy)
INSERT INTO usuarios (username, nombre, rol, activo) 
VALUES ('admin', 'Administrador', 'admin', true)
ON CONFLICT (username) DO NOTHING;

-- Insertar usuario admin por defecto (tabla de sincronizacion)
INSERT INTO usuarios_sistema (id, username, password, nombre, rol, activo, primer_ingreso) 
VALUES (1, 'admin', 'admin123', 'Administrador', 'admin', true, true)
ON CONFLICT (id) DO UPDATE SET 
    password = EXCLUDED.password,
    nombre = EXCLUDED.nombre,
    rol = EXCLUDED.rol,
    activo = EXCLUDED.activo,
    primer_ingreso = EXCLUDED.primer_ingreso;

-- =====================================================
-- INSTRUCCIONES DE CONFIGURACION
-- =====================================================
-- 1. Crear proyecto en Supabase: https://supabase.com
-- 2. Ir a SQL Editor y ejecutar este script COMPLETO
-- 3. Ir a Settings > API para obtener:
--    - URL del proyecto
--    - anon/public key
-- 4. Configurar en la aplicacion: Menu > Configurar Supabase
-- 
-- NOTA: La tabla usuarios_sistema permite sincronizar usuarios
-- en todos los dispositivos. Los usuarios creados en un dispositivo
-- estaran disponibles en todos los demas.
-- =====================================================
