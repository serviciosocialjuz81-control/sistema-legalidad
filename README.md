# Sistema de Control de Legalidad - Ley 26.061

[![Version](https://img.shields.io/badge/version-3.0-blue.svg)](https://github.com)
[![GitHub Pages](https://img.shields.io/badge/deploy-GitHub%20Pages-green.svg)](https://pages.github.com)
[![Supabase](https://img.shields.io/badge/database-Supabase-3ECF8E.svg)](https://supabase.com)

Sistema web para el control de legalidad de casos de niños, niñas y adolescentes bajo la Ley 26.061 de Argentina.

## 🌐 Demo en vivo

**URL del sistema**: `https://TU_USUARIO.github.io/sistema-legalidad`

> Reemplaza `TU_USUARIO` con tu nombre de usuario de GitHub después de la configuración.

## ✨ Características

### Gestión de Casos
- ✅ Registro completo de NNA (datos personales, expediente, medidas)
- ✅ Control de vencimientos con alertas automáticas
- ✅ Estados: Por vencer, Vencido, Sin plazo, Archivado
- ✅ Tipos de medida: Restitución, Adoptabilidad, Guarda, Alojamiento

### Audiencias
- ✅ Múltiples tipos de audiencias (Art 12 CDN, ART 607/609 CCyCN, ART 40 Ley 26061)
- ✅ Selección múltiple de artículos por audiencia
- ✅ Fecha, hora y despachante por audiencia
- ✅ Visualización en calendario

### Calendario
- ✅ Vista mensual con indicadores de eventos
- ✅ Vencimientos (rojo/naranja)
- ✅ Audiencias (ámbar)
- ✅ Casos completados (verde)
- ✅ Click en día para ver detalles

### Notificaciones
- ✅ Notificaciones del navegador (requiere página abierta)
- ✅ Emails automáticos (vía EmailJS)
- ✅ Configurable: días de anticipación
- ✅ Alertas separadas para vencimientos y audiencias

### Panel de Administración
- ✅ Gestión de usuarios (Administrador / Usuario)
- ✅ Control de permisos
- ✅ Primer ingreso obliga cambio de contraseña
- ✅ Historial de cambios

### Exportación
- ✅ Excel (.xlsx) con todos los datos
- ✅ PDF con resumen de casos
- ✅ Sin columna ID (datos limpios)

### Sincronización
- ✅ Base de datos en Supabase (PostgreSQL)
- ✅ Sincronización automática
- ✅ Funciona offline con localStorage
- ✅ Respaldo en la nube

## 🚀 Instalación Rápida

### Requisitos
- Cuenta de GitHub (gratis)
- Cuenta de Supabase (gratis - 500MB)
- (Opcional) Cuenta de EmailJS (gratis - 200 emails/mes)

### Paso 1: GitHub Pages

1. Crea un nuevo repositorio en GitHub
2. Sube los archivos `index.html`, `README.md` y `supabase_schema.sql`
3. Ve a Settings → Pages → Enable (Source: main branch)
4. Tu sitio estará en: `https://TU_USUARIO.github.io/nombre-repo`

### Paso 2: Supabase

1. Crea un proyecto en [supabase.com](https://supabase.com)
2. Ve a SQL Editor → New query
3. Copia y ejecuta el contenido de `supabase_schema.sql`
4. Ve a Settings → API → Copia URL y anon key

### Paso 3: Configurar App

1. Abre tu sitio de GitHub Pages
2. Login: `admin` / `admin123`
3. Cambia la contraseña
4. Menú usuario → Configurar Supabase → Pega URL y Key
5. (Opcional) Configura EmailJS para emails

📖 **Guía detallada**: Ver `CONFIGURACION_RAPIDA.md`

## 📸 Capturas de pantalla

### Dashboard
![Dashboard](https://via.placeholder.com/800x400?text=Dashboard+con+estadisticas)

### Lista de Casos
![Casos](https://via.placeholder.com/800x400?text=Lista+de+casos+con+filtros)

### Formulario de Caso
![Formulario](https://via.placeholder.com/800x400?text=Formulario+completo)

### Calendario
![Calendario](https://via.placeholder.com/800x400?text=Calendario+con+eventos)

## 🛠️ Tecnologías

- **Frontend**: HTML5, CSS3, JavaScript (vanilla)
- **Estilos**: Tailwind CSS (CDN)
- **Base de datos**: Supabase (PostgreSQL)
- **Hosting**: GitHub Pages
- **Emails**: EmailJS
- **Exportación**: SheetJS (Excel), jsPDF (PDF)

## 📁 Estructura del proyecto

```
sistema-legalidad/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions para deploy automático
├── index.html                  # Aplicación principal (todo en uno)
├── supabase_schema.sql         # Esquema de base de datos
├── README.md                   # Este archivo
├── CONFIGURACION_RAPIDA.md     # Guía de configuración paso a paso
└── GUIA_CONFIGURACION.md       # Guía detallada completa
```

## 🔐 Credenciales por defecto

| Usuario | Contraseña | Rol |
|---------|------------|-----|
| admin | admin123 | Administrador |

> ⚠️ **IMPORTANTE**: El sistema exige cambiar la contraseña en el primer ingreso.

## 📋 Tipos de Audiencia

- **Art 12 CDN** - Convención sobre los Derechos del Niño
- **ART 607 CCyCN** - Código Civil y Comercial (restitución)
- **ART 609 CCyCN** - Código Civil y Comercial (adopción)
- **ART 607 Y 609 CCyCN** - Ambos artículos
- **ART 40 Ley 26061** - Protección integral de NNA

## 🔔 Notificaciones

### Configuración recomendada

| Tipo | Anticipación | Canal |
|------|--------------|-------|
| Vencimientos | 3 días | Navegador + Email |
| Audiencias | 3 días | Navegador |

### Frecuencia
- Las notificaciones se verifican cada 5 minutos
- Solo funcionan cuando la página está abierta
- Para emails, configurar EmailJS

## 👥 Roles de Usuario

### Administrador
- ✅ Acceso total al sistema
- ✅ Panel de administración
- ✅ Configuración de Supabase
- ✅ Gestión de usuarios

### Usuario
- ✅ Ver y editar casos
- ✅ Ver calendario
- ✅ Exportar datos
- ❌ Sin acceso a Panel Admin
- ❌ Sin acceso a Configuración Supabase

## 🔄 Actualización

Para actualizar el sistema:

1. Sube los nuevos archivos a GitHub
2. GitHub Actions despliega automáticamente
3. Los usuarios recargan la página (F5)

## 🐛 Solución de problemas

### No sincroniza con Supabase
- Verificar URL y Key en Configuración
- Verificar que RLS esté habilitado en tablas
- Revisar consola del navegador (F12)

### No llegan notificaciones
- Verificar permisos del navegador
- La página debe estar abierta
- Para emails, verificar configuración EmailJS

### Error al guardar
- Completar campos obligatorios (*)
- Verificar formato de fecha

## 📞 Soporte

Para reportar problemas o sugerencias:
1. Revisar la consola del navegador (F12)
2. Verificar configuraciones
3. Contactar al administrador del sistema

## 📄 Licencia

Este proyecto es de uso libre para organismos de protección de derechos de NNA.

## 🙏 Créditos

Desarrollado para facilitar el control de legalidad según la Ley 26.061 de Argentina.

---

**Versión**: 3.0  
**Última actualización**: Marzo 2026
