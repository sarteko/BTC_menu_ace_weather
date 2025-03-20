// weather_control_cellphone.sqf - Sistema di controllo del meteo per cellulare ACE
// Versione: 1.0
// Autore: Assistente AI

// Variabili di configurazione
WCS_CP_weatherControlItem = "ACE_Cellphone"; // Oggetto necessario per controllare il meteo

// ===== FUNZIONI GLOBALI =====

// Funzione per impostare l'ora - versione multiplayer
WCS_CP_fnc_setTime = {
    params ["_hour", "_minute"];
    
    if (!isServer) exitWith {
        // Invia la richiesta al server
        [_hour, _minute] remoteExec ["WCS_CP_fnc_setTime", 2];
    };
    
    private _date = date;
    _date set [3, _hour]; 
    _date set [4, _minute]; 
    setDate _date;
    
    // Notifica tutti i giocatori
    [format ["Ora impostata a: %1:%2", _hour, _minute]] remoteExec ["hint", 0];
    diag_log format ["[WCS_CP] - Ora modificata: %1", _date];
};

// Funzione per impostare il meteo - versione multiplayer
WCS_CP_fnc_setWeather = {
    params ["_weatherType"];
    
    if (!isServer) exitWith {
        // Invia la richiesta al server
        [_weatherType] remoteExec ["WCS_CP_fnc_setWeather", 2];
    };
    
    switch (_weatherType) do {
        case "Sunny": {
            15 setOvercast 0;
            15 setRain 0;
            15 setFog 0;
        };
        case "Few Clouds": {
            15 setOvercast 0.5;
            15 setRain 0;
            15 setFog 0;
        };
        case "Cloudy": {
            15 setOvercast 1;
            15 setRain 0;
            15 setFog 0;
        };
        case "Rain": {
            15 setOvercast 0.7;
            15 setRain 0.6;
            15 setFog 0.05;
        };
        case "Storm": {
            15 setOvercast 1;
            15 setRain 0.8;
            15 setLightnings 1;
            15 setFog 0.1;
        };
        case "Strong Storm": {
            15 setOvercast 1;
            15 setRain 1;
            15 setLightnings 1;
            15 setFog 0.4;
        };
    };
    
    [format ["Meteo impostato a: %1", _weatherType]] remoteExec ["hint", 0];
    forceWeatherChange;
    diag_log format ["[WCS_CP] - Meteo modificato: %1", _weatherType];
};

// Funzione per verificare se il giocatore ha l'oggetto
WCS_CP_fnc_hasWeatherDevice = {
    WCS_CP_weatherControlItem in (items player)
};

// Pubblica le funzioni nello spazio dei nomi pubblico
publicVariable "WCS_CP_fnc_setTime";
publicVariable "WCS_CP_fnc_setWeather";
publicVariable "WCS_CP_fnc_hasWeatherDevice";
publicVariable "WCS_CP_weatherControlItem";

// ===== INIZIALIZZAZIONE LATO SERVER =====
if (isServer) then {
    [] spawn {
        diag_log "[WCS_CP] Weather control system starting on server";
        
        // Attendi che tutti gli oggetti siano inizializzati
        waitUntil {time > 0};
        sleep 5; // Aggiungiamo un ritardo per assicurarci che tutto sia pronto
        
        // Imposta la sincronizzazione del meteo per i client che si connettono
        // Questo assicura che tutti i client vedano lo stesso meteo
        [0, {forceWeatherChange}] remoteExec ["spawn", 0, true];
        
        diag_log "[WCS_CP] Weather control system initialized on server";
    };
};

// ===== INIZIALIZZAZIONE LATO CLIENT =====
if (hasInterface) then {
    [] spawn {
        waitUntil {!isNull player && time > 0};
        sleep 5; // Aggiungiamo un ritardo per assicurarci che ACE sia inizializzato

        if (isNil "ace_interact_menu_fnc_createAction") then {
            diag_log "[WCS_CP] ERRORE: ACE Interaction non trovato. Impossibile inizializzare il controllo meteo.";
            hint "Weather Control System (Cellphone): ACE Interaction non trovato!";
            exitWith {};
        };
        
        // Controlliamo se le icone esistono e usiamo un'icona predefinita se non ci sono
        private _iconPath = "weather\ico\";
        private _defaultIcon = "";
        
        // Definizione opzioni del tempo
        private _timeOptions = [
            ["Sunrise", [05, 30], _iconPath + "sunrise.paa"],
            ["Morning", [09, 00], _iconPath + "morning.paa"],
            ["Noon", [12, 00], _iconPath + "afternoon.paa"],
            ["Afternoon", [15, 00], _iconPath + "afternoon.paa"],
            ["Sunset", [18, 30], _iconPath + "sunset.paa"],
            ["Evening", [21, 00], _iconPath + "evening.paa"],
            ["Night", [00, 00], _iconPath + "night.paa"]
        ];
        
        // Definizione opzioni del meteo
        private _weatherOptions = [
            ["Sunny", "Sunny", _iconPath + "sun.paa"],
            ["Few Clouds", "Few Clouds", _iconPath + "fclouds.paa"],
            ["Cloudy", "Cloudy", _iconPath + "clouds.paa"],
            ["Rain", "Rain", _iconPath + "rain.paa"],
            ["Storm", "Storm", _iconPath + "rain2.paa"],
            ["Strong Storm", "Strong Storm", _iconPath + "storm.paa"]
        ];
        
        // ===== MENU SELF-INTERACTION (OGGETTO IN INVENTARIO) =====
        
        // Aggiungi menu principale del tempo
        private _timeAction = ["WCS_CP_TimeMenu", "Set Time", _iconPath + "clock.paa", {}, {call WCS_CP_fnc_hasWeatherDevice}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions"], _timeAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi menu principale del meteo
        private _weatherAction = ["WCS_CP_WeatherMenu", "Set Weather", _iconPath + "weather.paa", {}, {call WCS_CP_fnc_hasWeatherDevice}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions"], _weatherAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi opzioni del tempo
        {
            _x params ["_name", "_time", "_icon"];
            private _action = [
                format ["WCS_CP_Time_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_params"];
                    _params params ["_hour", "_minute"];
                    [_hour, _minute] call WCS_CP_fnc_setTime;
                },
                {call WCS_CP_fnc_hasWeatherDevice},
                {},
                _time
            ] call ace_interact_menu_fnc_createAction;
            
            [player, 1, ["ACE_SelfActions", "WCS_CP_TimeMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _timeOptions;
        
        // Aggiungi opzioni del meteo
        {
            _x params ["_name", "_type", "_icon"];
            private _action = [
                format ["WCS_CP_Weather_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_weatherType"];
                    [_weatherType] call WCS_CP_fnc_setWeather;
                },
                {call WCS_CP_fnc_hasWeatherDevice},
                {},
                _type
            ] call ace_interact_menu_fnc_createAction;
            
            [player, 1, ["ACE_SelfActions", "WCS_CP_WeatherMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _weatherOptions;
        
        // Aggiungi un messaggio di guida per l'uso del cellulare
        [
            "WCS_CP_Help",
            "Weather Control Help",
            "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\help_ca.paa",
            {
                hint "Weather Control System\n\nUsa il tuo cellulare ACE per controllare il meteo e l'ora.\n\nPer accedere al menu, premi il tasto Self-Interaction (di default CTRL+Windows) e seleziona 'Set Time' o 'Set Weather'.";
            },
            {call WCS_CP_fnc_hasWeatherDevice}
        ] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungere azione per il primo utilizzo
        ["ace_interactMenuOpened", {
            params ["_interactionType"];
            
            if (_interactionType == 1 && {call WCS_CP_fnc_hasWeatherDevice} && {!isNil "WCS_CP_firstUse"}) then {
                WCS_CP_firstUse = false;
                hint "Weather Control System attivo! Usa il tuo cellulare ACE per controllare il meteo e l'ora.";
            };
        }] call CBA_fnc_addEventHandler;
        
        WCS_CP_firstUse = true;
        diag_log "[WCS_CP] Weather control menu (player inventory) initialized successfully";
    };
};

diag_log "[WCS_CP] weather_control_cellphone.sqf caricato correttamente.";