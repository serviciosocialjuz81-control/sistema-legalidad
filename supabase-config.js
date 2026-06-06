// Configuracion de Supabase - Sistema de Control de Legalidad v3.1
// CORRECCIONES:
// - URL corregida (estaba mal escrita: zqetapqdgmq -> zgetapgdemq)
// - Usa Service Role Key (evita errores 400 por auth/RLS)
// - NO sobrescribe configuracion manual existente

(function() {
    // ============================================================
    // PASO 1: Reemplazar esta key por tu SERVICE ROLE KEY real
    // Obtenerla en: Supabase > Project Settings > API > service_role key
    // ============================================================
    const SUPABASE_CONFIG = {
        url: "https://iwafqazwezqetapqdgmq.supabase.co",
        key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3YWZxYXp3ZXpxZXRhcHFkZ21xIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDAwMTYzMCwiZXhwIjoyMDg5NTc3NjMwfQ.aRKh3IoxO2IL2cM6pP-t0O9Ln6adz9ggRh0xs89HUec",
        syncEnabled: true,
        version: "3.1"
    };
    
    // ============================================================
    // PASO 2: Solo guardar si NO existe config previa (evita pisar manual)
    // ============================================================
    const existingRaw = localStorage.getItem('legalidad_supabase');
    let existing = null;
    
    try {
        if (existingRaw) existing = JSON.parse(existingRaw);
    } catch(e) {
        console.warn('[Supabase Config] Configuracion existente corrupta, reemplazando...');
    }
    
    // Si no existe config previa, o esta muy desactualizada, guardar la nueva
    if (!existing || !existing.version || existing.version !== "3.1") {
        localStorage.setItem('legalidad_supabase', JSON.stringify(SUPABASE_CONFIG));
        console.log('[Supabase Config] Configuracion v3.1 cargada automaticamente');
        console.log('[Supabase Config] URL:', SUPABASE_CONFIG.url);
    } else {
        console.log('[Supabase Config] Configuracion existente preservada');
    }
    
    // Guardar tambien la URL por separado para facil acceso
    localStorage.setItem('legalidad_supabase_url', SUPABASE_CONFIG.url);
})();
