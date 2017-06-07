/*
    USAGE:
        ***its critical that the script is called from init.sqf***
        [] execVM "framework\hcBalancer.sqf";

	PARAMS:
		1.  [array] headlessclients
		2. [scalar] cycle interval
		3. [scalar] xfer wait buffer
		4. [scalar] initial wait time

    RETURNS:
        NOTHING

    EX:
        [(entities "HeadlessClient_F"), 90, 3, 60] execVM "framework\hcBalancer.sqf";
*/
    fnc_headless_locality =
    {
        private["_indx","_array","_target"];
        _target = (_this param [0]);
        _array = [];
        {
            _group = _x;
            {
                _hc_info = _x;
                if ((groupOwner _group) == (_hc_info select 1)) then {
                    _array set [(count _array),(format ["%1 on %2",_group,(_hc_info select 0)])];
                };                
            } forEach (missionNamespace getVariable "HCs");

            if ((groupOwner _group) == 2) then {
                _array set [(count _array),(format ["%1 on server",_group])];
            };                
        } forEach allGroups;
        [_array,{hint (str _this)}] remoteExec ['call',_target];
    };
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////                           BALANCER DEBUG MENU                  /////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    #include "\a3\editor_f\Data\Scripts\dikCodes.h"
    ["HC debug menu","HC debug menu","Open HC debug menu", {showCommandingMenu "#USER:hc_debug_menu";}, {}, [DIK_F12, [false, true, false]]] spawn CBA_fnc_addKeybind;	//ctrl + F12
    hc_debug_menu =
    [
        ["hc_debug_menu",false],
        ["current loads", [2], "", -5, [["expression", "[player, 'locals_count'] call fnc_headless_server_send_info_wrapper"]], "1", "1"],
        ["balancer stats", [3], "", -5, [["expression", "[player, 'balancer_stats'] call fnc_headless_server_send_info_wrapper"]], "1", "1"],
        ["locality report", [4], "", -5, [["expression", " [[player],{_this call fnc_headless_locality}] remoteExec ['call',2] "]], "1", "1"]
    ];



      ////////////////////////////////
     // NO CLIENTS PAST THIS POINT //
    ////////////////////////////////
    if ((not isServer) and (not isDedicated)) exitWith {};
    missionNamespace setVariable ["balancer_stats",[]];
    _unitsBuffer          = (_this param [0,  6, [1]]);
    _cycleTime            = (_this param [1, 90, [1]]);
    _xferBuffer           = (_this param [2,  3, [1]]);
    _waitTime             = (_this param [3, 60, [1]]);
    _clear_server         = (_this param [4, false, [false]]);
    _sever_offload_con    = (_this param [5, 3, [1]]);
    _iter                 = 1;

    
    waitUntil {time > 0};    
    sleep _waitTime;
    _headlessClient_array = (missionNamespace getVariable "HCs");
    ["[headless balancer] initializing...", {systemChat _this }] remoteExec ['call',0];

    
      ///////////////////
     // BALANCER LOOP //
    ///////////////////
    while {true} do {
          ////////////////////////////
         // OUTTER SCOPE VARIABLES //
        ////////////////////////////
        _xfered       = false;
        _minHC        = "";
        _maxHC        = "";
        _minNodeCount = 100000;
        _maxNodeCount = 0;
        _node         = 0;

          //////////////////
         // RESET COUNTS //
        //////////////////
        {
            _node = (_x select 0);
            _UnitsVarName  = (format ["%1_localUnits", _node]);
            _GroupsVarName = (format ["%1_localGroups", _node]);
            missionNamespace setVariable [_UnitsVarName, 0];
            missionNamespace setVariable [_GroupsVarName, []];
        } forEach _headlessClient_array;

        if (_clear_server) then {
            missionNamespace setVariable ["server_localUnits", 0];
            missionNamespace setVariable ["server_localGroups", []];
        };


          ////////////////////////////////////////////////       
         // MOVE UNITS FROM SERVER TO HEADLESS CLIENTS //
        ////////////////////////////////////////////////       
        if (_clear_server) then {
            if (_iter % _sever_offload_con == 0) then {
                _group_array = [];
                
                {
                    _node  = 0;
                    _group = _x;
                    _hcId  = (groupOwner _group);
                    _player_groups = [];
                    
                    {
                        _player_group = _x;
                        _player_groups set [(count _player_groups), (group _player_group)];
                    } forEach playableUnits;
                    
                    if (_hcId == 2) then {
                        if (not (_group in _player_groups)) then {
                            _group_array set [(count _group_array), _group];
                        };
                    };
                    
                } forEach allGroups;
                
                _groups_amount = (count _group_array);
                _index         = 0;
                
                if (_groups_amount > 0) then {
                    while {_index < _groups_amount} do {
                        {   
                            ((_group_array select _index) setGroupOwner (_x select 1));
                            _index = (_index + 1);
                        } forEach _headlessClient_array;
                        sleep _xferBuffer;
                    };

                    _stats = (missionNamespace getVariable "balancer_stats");
                    _entry = (format ["offloaded %1 groups from server @ %2", _groups_amount, time]);
                    missionNamespace setVariable ["balancer_stats", ([_entry, _stats] call fnc_array_to_front)];
                };
            };
        };


          //////////////////////////////////////////////
         // IDENTIFY LOCALITY AND SIZE OF ALL GROUPS //
        //////////////////////////////////////////////
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



        
          //////////////////////////////////////
         // FIND MIN LOAD HC AND MAX LOAD HC //
        //////////////////////////////////////
        {
            _varName        = (format ["%1_localUnits", (_x select 0)]);
            _currentHCunits = (missionNamespace getVariable _varName);

            // least
            if (_currentHCunits < _minNodeCount) then {
                _minNodeCount = _currentHCunits;
                _minHC = _x;
            };

            // most
            if (_currentHCunits > _maxNodeCount) then {
                _maxNodeCount = _currentHCunits;
                _maxHC = _x;
            };
        } forEach _headlessClient_array;

        
        // if varience criteria met start xfers
        _xferedNum  = 0;
        _differance = (floor ((_maxNodeCount - _minNodeCount)/2));
        if (_differance >= _unitsBuffer) then {
            _varName      = (format ["%1_localGroups", (_maxHC select 0)]);
            _maxHCGroups  = (missionNamespace getVariable _varName);
            _xfered       = true;

            while {_differance > 2} do {
                _noGroupFits = true;

                {
                    if ((_x select 1) <= _differance) then {
                        _leader = (leader (_x select 0));
                        if ((!isNull (_x select 0)) && (!isPlayer _leader) && (alive _leader)) then {
                            (_x select 0) setGroupOwner (_minHC select 1);
                            sleep _xferBuffer;
                            _xferedNum   = _xferedNum + (_x select 1);
                            _differance  = _differance - (_x select 1);
                            _noGroupFits = false;
                        };
                    };
                } forEach _maxHCGroups;

                if (_noGroupFits) then {
                    _differance = _differance - 1;
                };

            };

        };


        // if xfer took place log update stats, update count
        if (_xfered) then {
            _stats = (missionNamespace getVariable "balancer_stats");
            if ((count _stats) > 10) then {
                _stats resize 5;
            };

            _entry = (format ["cycle %1 complete @ %2 | Xfered %3 to %4", _iter, time, _xferedNum, (_minHC select 0)]);

            _varName_min_hc = (format ["%1_localUnits", (_minHC select 0)]);
            _updated_count_min_hc = ((missionNamespace getVariable _varName_min_hc) + _xferedNum);
            missionNamespace setVariable [_varName_min_hc, _updated_count_min_hc];

            _varName_max_hc = (format ["%1_localUnits", (_maxHC select 0)]);
            _updated_count_max_hc = ((missionNamespace getVariable _varName_max_hc) - _xferedNum);
            missionNamespace setVariable [_varName_max_hc, _updated_count_max_hc];

            missionNamespace setVariable ["balancer_stats", ([_entry, _stats] call fnc_array_to_front)];
        };

        _iter = (_iter + 1);
        sleep _cycleTime;
    };