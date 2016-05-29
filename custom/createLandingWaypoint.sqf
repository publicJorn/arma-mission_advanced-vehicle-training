_Zen_stack_Trace = ["createLandingWaypoint", _this] call Zen_StackAdd;

private ["_group", "_pos", "_type", "_wp", "_additionalStatements", "_ref", "_refString"];

if !([_this, [["GROUP"], ["ARRAY"], ["STRING"]], [], 3] call Zen_CheckArguments) exitWith {
    call Zen_StackRemove;
    (-1)
};

_group = _this select 0;
_pos   = _this select 1;
_type  = _this select 2;
_additionalStatements = _this select 3;

_wp = _group addWaypoint [_pos, 0];
_wp setWaypointType _type;

// Make sure chopper lands on the spot
_ref = "Land_HelipadCivil_F" createvehicle (_pos);

// Save reference to Helipad on group leader
_refString = "land_" + ([4, "Numeric"] call Zen_StringGenerateRandom);
(leader _group) setVariable [_refString, _ref, true];

// Use reference on group leader to clean up Helipad after landing
_wp setWaypointStatements ["true", "deleteVehicle (this getVariable '"+ _refString +"'); "+ _additionalStatements];

(_wp)
