/**
 * @param {SCALAR} spawnId
 * @param {SIDE}   side
 * @param {GROUP}  crew
 */
registerAirPuppet = {
    _Zen_stack_Trace = ["registerAirPuppet", _this] call Zen_StackAdd;
    if !([_this, [["STRING"], ["SIDE"], ["GROUP"]], [], 3] call Zen_CheckArguments) exitWith {
        ["ERROR: registerAirPuppet - Not all required arguments are given or of proper type"] call dLogger;
        call Zen_StackRemove;
        (-1)
    };

    params ["_spawnId", "_side", "_transportCrew"];
    // Last array is placeholder for marker id
    spawnedAirPuppets set [count spawnedAirPuppets, [_spawnId, _side, _transportCrew, []]];
};


/**
 * @param {SCALAR} spawnId
 * @param {ARRAY}  markerId's
 */
registerAirPuppetMarkers = {
    _Zen_stack_Trace = ["registerAirPuppetMarkers", _this] call Zen_StackAdd;
    if !([_this, [["STRING"], ["ARRAY"]], [[], ["STRING"]], 2] call Zen_CheckArguments) exitWith {
        ["ERROR: registerAirPuppetMarkers - Not all required arguments are given or of proper type"] call dLogger;
        call Zen_StackRemove;
        (-1)
    };

    params ["_spawnId", "_markerIds"];
    // _registrar is the array that's set by `registerAirPuppet`
    _registrar = [spawnedAirPuppets, _spawnId, 0] call Zen_ArrayGetNestedValue;
    // The third entry is an empty array, put the markers in here
    _registrar set [3, (_markerIds)];
};


/**
 * @param {Group} group
 */
deleteAirPuppetByGroup = {
    _Zen_stack_Trace = ["deleteAirPuppetByGroup", _this] call Zen_StackAdd;
    if !([_this, [["GROUP"]], [], 1] call Zen_CheckArguments) exitWith {
        ["ERROR: deleteAirPuppetByGroup - Not all required arguments are given or of proper type"] call dLogger;
        call Zen_StackRemove;
        (-1)
    };

    params ["_group"];
    _matches = [spawnedAirPuppets, _group, 2] call Zen_ArrayGetNestedIndex;
    _id = _matches select 0; // Should be only 1
    [_group] call deleteAny;

    if (DEBUG) then {
        _markerIds = spawnedAirPuppets select 3; // Array of strings
        {
            ZEN_STD_Parse_ToString(_x);
            if (_x != "") then { deleteMarker _x; };
        } forEach _markerIds;
    };

    [spawnedAirPuppets, _id] call Zen_ArrayRemoveIndex;
};

/**
 * This function is usually called when unit is dead
 * @usage spawn
 * @type {Object}
 */
deleteAirPuppetBySpawnId = {
    _Zen_stack_Trace = ["deleteAirPuppetBySpawnId", _this] call Zen_StackAdd;
    /*if !([_this, [["SCALAR"]], [], 1] call Zen_CheckArguments) exitWith {
        ["ERROR: deleteAirPuppetBySpawnId - Not all required arguments are given or of proper type"] call dLogger;
        call Zen_StackRemove;
        (-1)
    };*/

    if (! params [["_spawnId", -1, ["STRING"]]] ) exitWith {
        ["deleteAirPuppetBySpawnId - Given property was no STRING: %1", _spawnId] call dLogger;
        call Zen_StackRemove;
        (-1)
    };

    // _registrar is the array that's set by `registerAirPuppet`
    _registrarId = ([spawnedAirPuppets, _spawnId, 0] call Zen_ArrayGetNestedIndex) select 0;
    if (typeName _registrarId != "SCALAR") exitWith {
        ["deleteAirPuppetBySpawnId - Air puppet not found with spawnId: %1", _spawnId] call dLogger;
        (-1)
    };

    _registrar = spawnedAirPuppets select _registrarId;
    _group = _registrar select 2;
    /*_freeSlotTimeout = ceil random [30, 45, 60];*/
    _respawnTimeout = ceil random [5, 5, 5];

    // Give time to crash
    if ({alive _x} count units _group > 0) then {
        if (!isNull _group) then {
            // Wreck removal done by engine
            ["Deleting group %1, but keep vehicle alive for wreck"] call dLogger;
            [_group, false] call deleteAny;
        };
    };

    ["Respawn timeout: %1", _respawnTimeout] call dLogger;
    sleep _respawnTimeout;
    [spawnedAirPuppets, _registrarId] call Zen_ArrayRemoveIndex;
};


killDriver = {
    params ["_spawnId"];

    _registrar = [spawnedAirPuppets, _spawnId, 0] call Zen_ArrayGetNestedValue;
    if (count _registrar > 0) then {
        _group = _registrar select 2;
        ["!! kill driver group %1", _group] call dLogger;
        hint format ["!! kill driver group %1", _group];
        driver vehicle leader _group setDamage 1;
    } else {
        hint format ["No units found for spawnId: %1", _spawnId];
    };
};
