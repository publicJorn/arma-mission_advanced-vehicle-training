/**
 * Arma 3 debug function
 * Requires DEBUG global. Set it in Init.sqf.
 * @param {array}
 */
dLogger = {
    // todo: _args = + _this;
    _this set [0, "> " + (_this select 0)];

    if (DEBUG) then {
        diag_log format _this;
    };
};
