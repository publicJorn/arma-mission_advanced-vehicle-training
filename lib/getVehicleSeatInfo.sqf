/**
 * Thanks to ravenleg
 * https://forums.bistudio.com/topic/189522-how-to-find-vehicle-cargopassengerffv-seat-capacity/
 */
private ["_arg", "_veh", "_totalSeats", "_crewSeats", "_cargoSeats", "_nonFFVcargoSeats", "_ffvCargoSeats"];

_arg = [_this, 0, "", [objNull, ""]] call BIS_fnc_param;
_veh = "";

if (typeName _arg == "STRING") then {
    _veh = _arg;
};

if (typeName _arg == "OBJECT") then {
    _veh = typeOf _arg;
};

if (_veh == "") exitWith {
    diag_log "ERROR: getVehicleSeatInfo - called with wrong argument";
    ([0,0,0,0,0])
};

if (!isClass (configFile >> "CfgVehicles" >> _veh)) exitWith {
    diag_log "ERROR: getVehicleSeatInfo - no valid vehicle class given";
    ([0,0,0,0,0])
};

_totalSeats = [_veh, true] call BIS_fnc_crewCount; // Number of total seats: crew + non-FFV cargo/passengers + FFV cargo/passengers
_crewSeats = [_veh, false] call BIS_fnc_crewCount; // Number of crew seats only
_cargoSeats = _totalSeats - _crewSeats; // Number of total cargo/passenger seats: non-FFV + FFV
_nonFFVcargoSeats = getNumber (configFile >> "CfgVehicles" >> _veh >> "transportSoldier"); // Number of non-FFV cargo seats only
_ffvCargoSeats = _cargoSeats - _nonFFVcargoSeats; // Number of FFV cargo seats only

([_totalSeats, _crewSeats, _cargoSeats, _nonFFVcargoSeats, _ffvCargoSeats])
