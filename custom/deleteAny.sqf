_Zen_stack_Trace = ["deleteAny", _this] call Zen_StackAdd;
if !([_this, ["OBJECT", "GROUP"], ["BOOL"], [], 1] call Zen_CheckArguments) exitWith {
    ["ERROR: deleteAny - Not all required arguments are given or of proper type"] call dLogger;
    call Zen_StackRemove;
    (-1)
};

params ["_subject", ["_deleteVehicle", true, ["BOOL"]]];
private ["_vehicle"];

// Delete the unit. If vehicle is a separate entity, save it
if (typeName _subject == "OBJECT") then {
    _veh = vehicle _subject;
    if (_veh != _subject) then { _vehicle = _veh; };

    deleteVehicle _subject;
};

// Delete the group. If vehicle is a separate entity, save it
if (typeName _subject == "GROUP") then {
    _leader = leader _subject;
    _veh = vehicle _leader;
    if (_veh != _leader) then { _vehicle = _veh; };

    { deleteVehicle _x; } forEach units _subject;
    deleteGroup _subject;
};

// Delete the vehicle entity. If any cargo is left, delete it.
if (_deleteVehicle && typeName _vehicle == "OBJECT") then {
    { deleteVehicle _x } forEach crew _vehicle;
    deleteVehicle _vehicle;
};
