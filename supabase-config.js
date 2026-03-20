// Configuracion de Supabase - Sistema de Control de Legalidad
// Este archivo fue generado automaticamente. No lo modifique manualmente.
// Suba este archivo a GitHub junto con index.html para que todos los dispositivos
// se conecten automaticamente a Supabase.

(function() {
    // Configuracion de Supabase
    const SUPABASE_CONFIG = {
        url: "https://iwafqazwezqetapqdgmq.supabase.co",
        key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3YWZxYXp3ZXpxZXRhcHFkZ21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwMDE2MzAsImV4cCI6MjA4OTU3NzYzMH0.QhYpyUP7R9zM6vcSQsSVbBoh7h1Ne7vJResIXhkPXqU",
        syncEnabled: true
    };
    
    // Guardar en localStorage automaticamente
    localStorage.setItem('legalidad_supabase', JSON.stringify(SUPABASE_CONFIG));
    
    // Notificar que la configuracion esta lista
    console.log('[Supabase Config] Configuracion cargada automaticamente');
})();