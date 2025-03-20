// weather_control.sqf - Sistema di controllo del meteo per multiplayer
// Versione: 1.0
// Autore: Assistente AI

// Variabili di configurazione
BTC_weatherControlItem = "ACE_Cellphone"; // Oggetto necessario per controllare il meteo
BTC_weatherControlObject = "time_sector"; // Nome variabile dell'oggetto fisico

// ===== FUNZIONI GLOBALI =====

// Funzione per impostare l'ora - versione multiplayer
BTC_fnc_setTime = {
    params ["_hour", "_minute"];
    
    if (!isServer) exitWith {
        // Invia la richiesta al server
        [_hour, _minute] remoteExec ["BTC_fnc_setTime", 2];
    };
    
    private _date = date;
    _date set [3, _hour]; 
    _date set [4, _minute]; 
    setDate _date;
    
    // Notifica tutti i giocatori
    [format ["Ora impostata a: %1:%2", _hour, _minute]] remoteExec ["hint", 0];
    diag_log format ["DEBUG - Ora modificata: %1", _date];
};

// Funzione per impostare il meteo - versione multiplayer
BTC_fnc_setWeather = {
    params ["_weatherType"];
    
    if (!isServer) exitWith {
        // Invia la richiesta al server
        [_weatherType] remoteExec ["BTC_fnc_setWeather", 2];
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
    diag_log format ["DEBUG - Meteo modificato: %1", _weatherType];
};

// Funzione per verificare se il giocatore ha l'oggetto
BTC_fnc_hasWeatherDevice = {
    BTC_weatherControlItem in (items player)
};

// ===== INIZIALIZZAZIONE LATO CLIENT =====
if (hasInterface) then {
    [] spawn {
        waitUntil {!isNull player && time > 0};
        
        // Definizione opzioni del tempo
        private _timeOptions = [
            ["Sunrise", [05, 30], "weather\ico\sunrise.paa"],
            ["Morning", [09, 00], "weather\ico\morning.paa"],
            ["Noon", [12, 00], "weather\ico\afternoon.paa"],
            ["Afternoon", [15, 00], "weather\ico\afternoon.paa"],
            ["Sunset", [18, 30], "weather\ico\sunset.paa"],
            ["Evening", [21, 00], "weather\ico\evening.paa"],
            ["Night", [00, 00], "weather\ico\night.paa"]
        ];
        
        // Definizione opzioni del meteo
        private _weatherOptions = [
            ["Sunny", "Sunny", "weather\ico\sun.paa"],
            ["Few Clouds", "Few Clouds", "weather\ico\fclouds.paa"],
            ["Cloudy", "Cloudy", "weather\ico\clouds.paa"],
            ["Rain", "Rain", "weather\ico\rain.paa"],
            ["Storm", "Storm", "weather\ico\rain2.paa"],
            ["Strong Storm", "Strong Storm", "weather\ico\storm.paa"]
        ];
        
        // ===== MENU SELF-INTERACTION (OGGETTO IN INVENTARIO) =====
        
        // Aggiungi menu principale del tempo
        private _timeAction = ["BTC_TimeMenu", "Set Time", "weather\ico\clock.paa", {}, {call BTC_fnc_hasWeatherDevice}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions"], _timeAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi menu principale del meteo
        private _weatherAction = ["BTC_WeatherMenu", "Set Weather", "weather\ico\weather.paa", {}, {call BTC_fnc_hasWeatherDevice}] call ace_interact_menu_fnc_createAction;
        [player, 1, ["ACE_SelfActions"], _weatherAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi opzioni del tempo
        {
            _x params ["_name", "_time", "_icon"];
            private _action = [
                format ["BTC_Time_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_params"];
                    _params params ["_hour", "_minute"];
                    [_hour, _minute] call BTC_fnc_setTime;
                },
                {call BTC_fnc_hasWeatherDevice},
                {},
                _time
            ] call ace_interact_menu_fnc_createAction;
            
            [player, 1, ["ACE_SelfActions", "BTC_TimeMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _timeOptions;
        
        // Aggiungi opzioni del meteo
        {
            _x params ["_name", "_type", "_icon"];
            private _action = [
                format ["BTC_Weather_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_weatherType"];
                    [_weatherType] call BTC_fnc_setWeather;
                },
                {call BTC_fnc_hasWeatherDevice},
                {},
                _type
            ] call ace_interact_menu_fnc_createAction;
            
            [player, 1, ["ACE_SelfActions", "BTC_WeatherMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _weatherOptions;
        
        diag_log "Weather control menu (player inventory) initialized successfully";
    };
};

// ===== INIZIALIZZAZIONE LATO SERVER =====
if (isServer) then {
    [] spawn {
        diag_log "Weather control system starting on server";
        
        // Attendi che tutti gli oggetti siano inizializzati
        waitUntil {time > 0};
        
        // Imposta la sincronizzazione del meteo per i client che si connettono
        // Questo assicura che tutti i client vedano lo stesso meteo
        [0, {forceWeatherChange}] remoteExec ["spawn", 0, true];
        
        diag_log "Weather control system initialized on server";
    };
};

// ===== INIZIALIZZAZIONE OGGETTO FISICO =====
if (hasInterface) then {
    [] spawn {
        waitUntil {time > 0};
        
        // Attendi che l'oggetto di controllo sia disponibile
        waitUntil {!isNil {missionNamespace getVariable BTC_weatherControlObject}};
        
        // Definizione opzioni del tempo
        private _timeOptions = [
            ["Sunrise", [05, 30], "weather\ico\sunrise.paa"],
            ["Morning", [09, 00], "weather\ico\morning.paa"],
            ["Noon", [12, 00], "weather\ico\afternoon.paa"],
            ["Afternoon", [15, 00], "weather\ico\afternoon.paa"],
            ["Sunset", [18, 30], "weather\ico\sunset.paa"],
            ["Evening", [21, 00], "weather\ico\evening.paa"],
            ["Night", [00, 00], "weather\ico\night.paa"]
        ];
        
        // Definizione opzioni del meteo
        private _weatherOptions = [
            ["Sunny", "Sunny", "weather\ico\sun.paa"],
            ["Few Clouds", "Few Clouds", "weather\ico\fclouds.paa"],
            ["Cloudy", "Cloudy", "weather\ico\clouds.paa"],
            ["Rain", "Rain", "weather\ico\rain.paa"],
            ["Storm", "Storm", "weather\ico\rain2.paa"],
            ["Strong Storm", "Strong Storm", "weather\ico\storm.paa"]
        ];
        
        // Ottieni l'oggetto di controllo
        private _controlObject = missionNamespace getVariable BTC_weatherControlObject;
        
        // Aggiungi menu principale del tempo
        private _timeAction = ["BTC_TimeMenu", "Set Time", "weather\ico\clock.paa", {}, {true}] call ace_interact_menu_fnc_createAction;
        [_controlObject, 0, ["ACE_MainActions"], _timeAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi menu principale del meteo
        private _weatherAction = ["BTC_WeatherMenu", "Set Weather", "weather\ico\weather.paa", {}, {true}] call ace_interact_menu_fnc_createAction;
        [_controlObject, 0, ["ACE_MainActions"], _weatherAction] call ace_interact_menu_fnc_addActionToObject;
        
        // Aggiungi opzioni del tempo
        {
            _x params ["_name", "_time", "_icon"];
            private _action = [
                format ["BTC_Time_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_params"];
                    _params params ["_hour", "_minute"];
                    [_hour, _minute] call BTC_fnc_setTime;
                },
                {true},
                {},
                _time
            ] call ace_interact_menu_fnc_createAction;
            
            [_controlObject, 0, ["ACE_MainActions", "BTC_TimeMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _timeOptions;
        
        // Aggiungi opzioni del meteo
        {
            _x params ["_name", "_type", "_icon"];
            private _action = [
                format ["BTC_Weather_%1", _name],
                _name,
                _icon,
                {
                    params ["_target", "_player", "_weatherType"];
                    [_weatherType] call BTC_fnc_setWeather;
                },
                {true},
                {},
                _type
            ] call ace_interact_menu_fnc_createAction;
            
            [_controlObject, 0, ["ACE_MainActions", "BTC_WeatherMenu"], _action] call ace_interact_menu_fnc_addActionToObject;
        } forEach _weatherOptions;
        
        diag_log format ["Weather control physical object '%1' initialized", BTC_weatherControlObject];
    };
};

diag_log "weather_control.sqf caricato correttamente.";