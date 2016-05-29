#include "lib\inc_debugging.sqf";

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

//format ["%1 is (re)spawning\n%2", _newUnit, name _newUnit] remoteExec ["hint"];

if (_newUnit == player) then {
    _pos = getPos _newUnit;
    _newUnit setPos [_pos select 0, _pos select 1, 1.5];
};
