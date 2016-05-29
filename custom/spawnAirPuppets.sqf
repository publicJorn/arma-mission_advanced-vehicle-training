#include "..\Zen_FrameworkFunctions\Zen_StandardLibrary.sqf"

_Zen_stack_Trace = ["createRoutePositions", _this] call Zen_StackAdd;

private ["_side", "_spawnId", "_sideStr", "_viewDirection", "_airCav",
    "_positions", "_transport", "_transportCrew", "_seatsAvailable", "_grunts",
    "_wpStart", "_wpDeploy", "_landReference", "_wpEnd", "_gruntsTarget", "_puppetsWp"];

if !([_this, [["SIDE"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    (-1)
};

params ["_side"];

_sideStr = [_side] call BIS_fnc_sideName;
_spawnId = str time;

_viewDirection = switch (_side) do {
    case blufor: {180};
    case independent: {45};
    case opfor: {300};
};

_airCav = [
    "B_Heli_Light_01_F",
    "B_Heli_Transport_01_camo_F",
    "B_Heli_Transport_03_black_F",
    "O_Heli_Light_02_F",
    "O_Heli_Light_02_unarmed_F",
    "O_Heli_Transport_04_bench_F",
    "O_Heli_Transport_04_covered_F",
    "I_Heli_Transport_02_F",
    "I_Heli_light_03_unarmed_F"
];

// Spawn transport
_positions = [_sideStr] call createRoutePositions;
["(%3) Spawning air transport for team: %1, at location: %2", _sideStr, _positions select 0, _spawnId] call dLogger;
_transport = [_positions select 0, selectRandom _airCav, 0, _viewDirection] call Zen_SpawnVehicle;
_transportCrew = [_transport, _side, ["Gunner"]] call Zen_SpawnVehicleCrew;
_transportCrew setVariable ["spawnId", _spawnId, true];
_transportCrew allowFleeing 0;
_transport engineOn true;

// Cleanup - only executed at server
_driver = assignedDriver _transport;
_driver addEventHandler ["Killed", {
    params ["_killed", "_killer"];
    ["TRANSPORT %1 was killed by %2 (%3)", _killed, _killer, name _killer] call dLogger;
    
    _sId = (group _killed) getVariable "spawnId";
    ["Trying to remove units of spawnId: %1", _sId] call dLogger;
    [_sId] spawn deleteAirPuppetBySpawnId;
}];
["Transport crew spawned: %1", _transportCrew] call dLogger;

// Spawn grunts for cargo
_seatsAvailable = ([_transport] call getVehicleSeatInfo) select 2;
if (_seatsAvailable > 0 && alive _transport && alive leader _transportCrew) then {
    _grunts = [SAFE_LAND_SPAWN_POS, _side, "Infantry", [1, _seatsAvailable]] call Zen_SpawnInfantry;
    [_grunts, _transport] call Zen_MoveInVehicle;
    ["Grunts in transport: %1", count units _grunts] call dLogger;
};

// Create waypoints
_wpStart = _transportCrew addWaypoint [_positions select 0, 0];
// Give random height from start
_wpStart setWaypointStatements ["true", "this flyInHeight (floor random [35, 100, 150])"];

if (count (_positions select 1) > 0) then {
    _wpBetween = _transportCrew addWaypoint [_positions select 1, 0];
    _wpBetween setWaypointStatements ["true", "this flyInHeight (floor random [25, 40, 100])"];
};

_wpDeploy = [_transportCrew, _positions select 2, "TR UNLOAD"] call createLandingWaypoint;
_wpEnd    = [_transportCrew, _positions select 0, "UNLOAD", "this land 'LAND'; [group this] call deleteAirPuppetByGroup"]
    call createLandingWaypoint;

// Move meatPuppets to AO
_gruntsTarget = ["AreaNoLanding", _positions select 2] call Zen_FindAveragePosition;
_puppetsWp = _grunts addWaypoint [_gruntsTarget, 0];
_puppetsWp setWaypointCompletionRadius 10;
_puppetsWp setWaypointTimeout [10, 40, 60];
_puppetsWp setWaypointStatements ["true", "{deleteVehicle _x} forEach thisList"];

[_spawnId, _side, _transportCrew] call registerAirPuppet;


if (DEBUG) then {
    _idStart   = [_positions select 0, "", "Color" + _sideStr, [1,1], "hd_start"] call Zen_SpawnMarker;
    _idBetween = "";
    _idEnd     = [_positions select 2, "", "Color" + _sideStr, [1,1], "hd_end"] call Zen_SpawnMarker;
    _idGrunts  = [_gruntsTarget, "", "Color" + _sideStr, [1,1], "hd_objective"] call Zen_SpawnMarker;

    if (count (_positions select 1) > 0) then {
        _idBetween = [_positions select 1, "", "Color" + _sideStr, [1,1], "hd_dot"] call Zen_SpawnMarker;
    };

    /*_dist = [_positions select 2, _gruntsTarget] call Zen_Find2dDistance;
    _pos  = [_positions select 2, _gruntsTarget] call Zen_FindAveragePosition;
    _dir  = [_positions select 2, _gruntsTarget] call Zen_FindDirection;
    _idEnd2Grunts = [_pos, "", "Color" + _sideStr, [5, _dist], "rectangle", _dir, .5] call Zen_SpawnMarker;*/

    [_spawnId, [_idStart, _idBetween, _idEnd, _idGrunts]] call registerAirPuppetMarkers;
};
