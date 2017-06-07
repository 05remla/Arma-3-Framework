/*
	all variables associated with headless balancing are stored on server
	IAW headless_balancer
	
*/
fnc_headless_distribute_groups = (compileFinal (preprocessFileLineNumbers "framework\headless\distribute_groups.sqf"));
fnc_headless_server_send_info  = (compileFinal (preprocessFileLineNumbers "framework\headless\server_send_info.sqf"));
fnc_headless_get_local_units   = (compileFinal (preprocessFileLineNumbers "framework\headless\get_local_units.sqf"));
fnc_headless_balancer          = (compileFinal (preprocessFileLineNumbers "framework\headless\headless_balancer.sqf"));


    //Ex. [HC_1, false] call fnc_headless_get_local_units_wrapper;
    fnc_headless_get_local_units_wrapper =
    {
        private["_node","_forEveryone","_fnc_headless_get_local_units"];
        _node        = (_this param [0]);
        _forEveryone = (_this param [1, false, [false]]);

        [[_node, _forEveryone], {_this call fnc_headless_get_local_units}] remoteExec ['call', _node];
    };


    //Ex. [player, "locals_count"] call fnc_headless_server_send_info_wrapper;
    fnc_headless_server_send_info_wrapper =
    {
        private["_rxNode","_type"];
        _rxNode = (_this param [0]);
        _type   = (_this param [1]);

        [[_rxNode, _type], {_this call fnc_headless_server_send_info}] remoteExec ['call', 2];
    };


    fnc_get_min_load_hc =
    {
        private["_hc_numbers_array","_min","_min_hc","_node","_UnitsVarName","_count"];
        _hc_numbers_array = [];
        _min    = 10000;
        _min_hc = 0;

        {
            _node = (_x select 1);
            _UnitsVarName  = (format ["%1_localUnits", _node]);
            _count = (missionNamespace getVariable [_UnitsVarName, 0]);
            _hc_numbers_array set [(count _hc_numbers_array), [_node,_count]];
        } forEach (missionNamespace getVariable "HCs");

        {
            _node = (_x select 0);
            _count = (_x select 1);
            if (_count <= _min) then {
                _min_hc = _node;
            };
        } forEach _hc_numbers_array;

		missionNamespace setVariable ["min_HC", _min_hc];
        (_min_hc)
    };


    fnc_headless_offload =
    {
        private["_script","_target","_args"];
        _script = (_this param [0]);
        _args   = (_this param [1, [], [[]]]);
		[[],{_this call fnc_get_min_load_hc}] remoteExec ['call', 2];
		sleep 1;
        _target = (missionNamespace getVariable ["min_HC"]);

        if ([".fsm",_script] call BIS_fnc_inString) then {
            [_args, {_this execFSM _script}] remoteExec ['call', _target];
        };

        if ([".sqf",_script] call BIS_fnc_inString) then {
            [_args, {_this execVM _script}] remoteExec ['call', _target];
        };
    };