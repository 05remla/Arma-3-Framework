/*
    DESCRIPTION:
        Polls server for headless balancing info then the server
        sends that info back to requester.

	PARAMS:
		1. [object] requesting/rxing node
		2. [string] type of info requested. includes: "balancer_stats", "locals_count"

    RETURNS:
        Nothing but sends information back across network

    EX:
        [[player, "balancer_stats"], {_this call fnc_headless_server_send_info}] remoteExec ['call', 2];
*/

    _rxNode = (_this param [0]);
    _type   = (_this param [1]);

    if (_type == "balancer_stats") exitWith {
        _stats = (missionNamespace getVariable "balancer_stats");
        [_stats, {hint (str _this)}] remoteExec ['call', _rxNode];
    };

    if (_type == "locals_count") exitWith {
        _countReturnArray = [];
        {   _varNameString = (format ["%1_localUnits", (_x select 0)]);
            _countReturnString = (format ["%1 units: %2",(_x select 0),(missionNamespace getVariable _varNameString)]);
            _countReturnArray set [(count _countReturnArray), _countReturnString];
        } forEach (missionNamespace getVariable "HCs");

        if (not (isNil {missionNamespace getVariable 'server_localUnits'})) then {
            _countReturnString = (format ["server units: %1", (missionNamespace getVariable 'server_localUnits')]);
            _countReturnArray set [(count _countReturnArray), _countReturnString];
        };

        [_countReturnArray, {hint (str _this)}] remoteExec ['call', _rxNode];
    };