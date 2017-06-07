/*
    ***THIS FUNCTION IS CALLED BY fnc_headless_get_local_units_wrapper***

    DESCRIPTION:
        Determines which units are local to a given node and publishes
        the result to either all clients or just the server.

    PARAMS:
        1. [object] headless client object
        2.   [bool] publish variables to all clients or just server

    RETURNS:
        sends info in the form of a publicVariable to everyone or just the server
        ($HC_NAME)_localUnits = [21]: this variable contains a scalar representing how many total local units
        ($HC_NAME)_localGroups = [['A 1-1', 8], ['A 1-2', 12]]: this variable contains an array of arrays.
                                                                found inside the subarrays are a string (group name)
                                                                and a scalar representing how many units in that group

    EX:
        [[HC_1, false], {_this call fnc_headless_get_local_units}] remoteExec ['call', HC_1];
        [HC_2, true] call fnc_headless_get_local_units_wrapper;
*/

    _localUnits          = 0;
    _localGroups         = [];
    _headless_info_array = (missionNamespace getVariable "HCs");
    _UnitsVarName        = "";
    _GroupsVarName       = "";

    {
        _node  = 0;
        _group = _x;
        _hcId  = (groupOwner _group);

        {
            _hc_info = _x;
            if (_hcId == (_hc_info select 1)) then {
                _node = (_hc_info select 0);
            };
        } forEach _headlessClient_array;

        if ((groupOwner _x) == 2) then {
            _node = "server";
        };

        if ((not ([_node,0] call BIS_fnc_areEqual)) and (not ([_node,"server"] call BIS_fnc_areEqual))) then {
            _UnitsVarName  = (format ["%1_localUnits", _node]);
            _GroupsVarName = (format ["%1_localGroups", _node]);
            _localUnits  = (missionNamespace getVariable _UnitsVarName);
            _localGroups = (missionNamespace getVariable _GroupsVarName);

            _grpSize    = (count (units _group));
            _localUnits = (_localUnits + _grpSize);
            _localGroups set [(count (_localGroups)), [_group, _grpSize]];

            missionNamespace setVariable [_UnitsVarName, _localUnits];
            missionNamespace setVariable [_GroupsVarName, _localGroups];
        };
    } forEach allGroups;