// weather_control_init.sqf - File di inizializzazione per il sistema di controllo meteo
// Versione: 1.0
// Autore: Assistente AI

// Esegui gli script di controllo meteo
[] execVM "weather\weather_control_static.sqf";
[] execVM "weather\weather_control_cellphone.sqf";

// Crea directory per le icone se non esiste
if (isServer) then {
    // Questo codice deve essere eseguito solo sul server
    private _iconDir = "weather\ico";
    
    if (!isDirectory _iconDir) then {
        // Crea messaggio di avviso
        diag_log "[WCS_INIT] AVVISO: Directory icone non trovata. Le icone potrebbero non apparire correttamente.";
    };
};

diag_log "[WCS_INIT] Inizializzazione del sistema di controllo meteo completata.";