#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Attack Chopper Training by usbStuck
// Version = 0.0.1
// Tested with ArmA 3 build 1.56.134787
#include "compileCustomFunctions.sqf";

DEBUG = true;
SAFE_LAND_SPAWN_POS = [8494, 25148]; // Little island north of Altis

#include "custom\inc_setupPlayers.sqf";

// This will fade in from black, to hide jarring actions at mission start, this is optional and you can change the value
//TODO: titleText ["Get them baddies...", "BLACK FADED", 0.5];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};
// Execution stops until the mission begins (past briefing), do not delete this line
sleep 1;

// START SERVER CODE ---
spawnSides = [independent];
maxAirTransports = 4;
maxGroundPuppets = 10;
maxGruntGroups = 40; // TODO: configurable
spawnedAirPuppets = [];
spawnedGroundPuppets = [];
spawnedGruntGroups = [];

// Funcion includes
#include "lib\inc_debugging.sqf";
#include "custom\inc_airPuppetFunctions.sqf";

#include "custom\inc_playerBaseInit.sqf";

/*
EH_EntityKilled = addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer"];
    ["Killed: %1 (%3) - by: %2", _killed, _killer, assignedVehicleRole _killed] call dLogger;

    if (assignedVehicleRole _killed select 0 == "Driver") then {
        _spawnId = (group _killed) getVariable "spawnId";
        ["Trying to remove units of spawnId: %1", _spawnId] call dLogger;
        [_spawnId] spawn deleteAirPuppetBySpawnId;
    };
}];
*/

/**
 * Main mission loop that spawns the AI meat puppets
 * TODO: check status > delete broken vehicles
 */
runSpawnLoop = true;
[] spawn {
    while {runSpawnLoop} do {
        _nrAir = count spawnedAirPuppets;
        ["AirPuppets vs max = %1:%2", _nrAir, maxAirTransports] call dLogger;

        if (_nrAir >= maxAirTransports) then {
            waitUntil {count spawnedAirPuppets < maxAirTransports};
            // Even after a kill, don't immediately spawn something new
        } else {
            _side = selectRandom spawnSides;
            _s = [_side] spawn spawnAirPuppets;
            waitUntil { scriptDone _s };
            ["spawnedAirPuppets array: %1", spawnedAirPuppets] call dLogger;
        };

        // At mission start, quickly spawn some stuff!
        ["In the loop (again)"] call dLogger;
        if (time < 30) then {
            uiSleep 1;
        } else {
            _r = ceil random [5, 20, 40];
            ["Spawn now random: %1", _r] call dLogger;
            uiSleep _r; // TODO: Test what feels right
        };
    };
};
