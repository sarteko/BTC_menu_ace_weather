diag_log "BTC weather system CfgFunction initialization";

// La funzione verrà chiamata automaticamente grazie a postInit = 1
if (!isDedicated && hasInterface) then {
    diag_log "Weather function initialized on client";
};

if (isServer) then {
    diag_log "Weather function initialized on server";
};

true