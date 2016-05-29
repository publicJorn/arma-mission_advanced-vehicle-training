_Zen_stack_Trace = ["createRoutePositions", _this] call Zen_StackAdd;

private ["_sideStr", "_startPos", "_betweenPos", "_endPos", "_betweenArea",
    "_idStart", "_idBetween", "_idEnd"];

if !([_this, [["STRING"]], [], 1] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    (-1)
};

_sideStr = _this select 0;

_startPos   = [_sideStr + "SpawnArea", 0, [_sideStr + "SpawnBlacklist01"], 1, [0,0], [0,360], [1,0,10], [0,0,0], [0,0], [0,0,-1],
        [1,[0,0,-1],5] // Exclude trees and rocks in 5m radius
    ] call Zen_FindGroundPosition;
_betweenPos = [];
_endPos     = ["AreaTarget", 0, ["AreaNoLanding"], 1, [0,0], [0,360], [1,0,10], [0,0,0], [0,0], [0,0,-1],
        [1,[0,-1,-1],5] // Exclude trees in 5m radius
    ] call Zen_FindGroundPosition;

// For some randomness, determine between pos. First is direct fligt to endPos
_betweenArea = selectRandom ["", _sideStr + "AltAirRoute01", _sideStr + "AltAirRoute02"];
if (_betweenArea != "") then {
    _betweenPos = [_betweenArea, 0, [], 0] call Zen_FindGroundPosition;
    _betweenPos set [2, random [15,55,100]];
};

([_startPos, _betweenPos, _endPos])
