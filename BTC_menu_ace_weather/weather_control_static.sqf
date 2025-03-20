// weather_control_static.sqf - Sistema di controllo del meteo per oggetto statico
// Versione: 1.0
// Autore: Assistente AI

// Variabili di configurazione
WCS_weatherControlObject = "time_sector"; // Nome variabile dell'oggetto fisico

// ===== FUNZIONI GLOBALI =====

// Funzione per impostare l'ora - versione multiplayer
WCS_fnc_setTime = {
    params ["_hour", "_minute"];
    
    if (!isServer) exitWith {
        // Invia la richiesta al server
        [_hour, _minute] remoteExec ["WCS_fnc_setTime", 2];
    };
    
    private _date = date;
    _date set [3, _hour]; 
    _date set [4, _minute]; 
    setDate _date;
    
    // Notifica tutti i giocatori
    [format ["Ora impostata a: %1:%2", _hour, _minute]] remoteExec ["hint", 0];
    diag_log format ["[WCS_STATIC] - Ora modificata: %1", _date];
};

// Funzione per impostare il meteo - versione multiplayer
WCS_fnc_setWeather = {
    params ["_weatherType"];
    
    if (!isServer) exitWith {
        // Invia la richiesta al server
        [_weatherType] remoteExec ["WCS_fnc_setWeather", 2];
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
    diag_log format ["[WCS_STATIC] - Meteo modificato: %1", _weatherType];
};

// Pubblica le funzioni nello spazio dei nomi pubblico
publicVariable "WCS_fnc_setTime";
publicVariable "WCS_fnc_setWeather";
publicVariable "WCS_weatherControlObject";

// ===== INIZIALIZZAZIONE LATO SERVER =====
if (isServer) then {
    [] spawn {
        diag_log "[WCS_STATIC] Weather control system starting on server";
        
        // Attendi che tutti gli oggetti siano inizializzati
        waitUntil {time > 0};
        sleep 5; // Aggiungiamo un ritardo per assicurarci che tutto sia pronto
        
        // Imposta la sincronizzazione del meteo per i client che si connettono
        // Questo assicura che tutti i client vedano lo stesso meteo
        [0, {forceWeatherChange}] remoteExec ["spawn", 0, true];
        
        diag_log "[WCS_STATIC] Weather control system initialized on server";
    };
};

// ===== INIZIALIZZAZIONE OGGETTO FISICO =====
if (hasInterface) then {
    [] spawn {
        waitUntil {!isNull player && time > 0};
        sleep 10; // Aggiungiamo un ritardo per assicurarci che tutto sia pronto
        
        // Controlliamo se l'oggetto è disponibile
        private _controlObject = missionNamespace getVariable [WCS_weatherControlObject, objNull];
        
        if (isNull _controlObject) then {
            diag_log format ["[WCS_STATIC] AVVISO: Oggetto fisico '%1' non trovato. Creazione di un oggetto temporaneo.", WCS_weatherControlObject];
            
            // Creiamo un oggetto temporaneo
            if (isServer) then {
                _controlObject = "Land_Laptop_unfolded_F" createVehicle (getPos player);
                _controlObject setPos (getPos player vectorAdd [0, 2, 0]);
                missionNamespace setVariable [WCS_weatherControlObject, _controlObject, true];
                diag_log "[WCS_STATIC] Creato oggetto temporaneo per il controllo meteo";
            } else {
                // Se non siamo il server, aspettiamo che l'oggetto sia creato
                waitUntil {!isNull (missionNamespace getVariable [WCS_weatherControlObject, objNull])};
                _controlObject = missionNamespace getVariable WCS_weatherControlObject;
            };
        };
        
        // Controlliamo se ACE è disponibile
        if (isNil "ace_interact_menu_fnc_createAction") exitWith {
            diag_log "[WCS_STATIC] ERRORE: ACE Interaction non trovato per l'oggetto fisico.";
            hint "Weather Control System (Static): ACE Interaction non trovato!";
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
        
        // Aggiungi menu principale del tempo
        private _timeAction = ["WCS_TimeMenu", "Set Time", _iconPath + "clock.paa", {}, {true}] call ace_interact_menu_fnc_createAction;
        [_controlObject, 0, ["ACE_MainActions"], _timeAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi menu principale del meteo
        private _weatherAction = ["WCS_WeatherMenu", "Set Weather", _iconPath + "weather.paa", {}, {true}] call ace_interact_menu_fnc_createAction;
        [_controlObject, 0, ["ACE_MainActions"], _weatherAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi opzioni del tempo
        {
            _x params ["_name", "_time", "_icon"];
            private _action = [
                format ["WCS_Time_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_params"];
                    _params params ["_hour", "_minute"];
                    [_hour, _minute] call WCS_fnc_setTime;
                },
                {true},
                {},
                _time
            ] call ace_interact_menu_fnc_createAction;
            
            [_controlObject, 0, ["ACE_MainActions", "WCS_TimeMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _timeOptions;
        
        // Aggiungi opzioni del meteo
        {
            _x params ["_name", "_type", "_icon"];
            private _action = [
                format ["WCS_Weather_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_weatherType"];
                    [_weatherType] call WCS_fnc_setWeather;
                },
                {true},
                {},
                _type
            ] call ace_interact_menu_fnc_createAction;
            
            [_controlObject, 0, ["ACE_MainActions", "WCS_WeatherMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _weatherOptions;
        
        diag_log format ["[WCS_STATIC] Weather control physical object '%1' initialized", WCS_weatherControlObject];
    };
};

diag_log "[WCS_STATIC] weather_control_static.sqf caricato correttamente.";