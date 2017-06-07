/*
	o5-framework lib
*/
    fnc_get_vehicles_by_faction =
    {
        private["_type","_faction","_vehicle_array","_vehicle_temp_array","_condition"];
        _type    = (_this param [0]);
        _faction = (_this param [1]);

        _vehicle_array = [];
        _condition = (format ["((configName _x) isKindOf '%1') and (getText (configfile >> 'CfgVehicles' >> (configName _x) >> 'faction') == '%2')",_type,_faction]);
        _vehicle_temp_array = (_condition configClasses (configFile >> "CfgVehicles"));

        {   _vehicle_array set [(count _vehicle_array), (str _x) select [27]];
        } forEach _vehicle_temp_array;

        (_vehicle_array)
    };


    fnc_coordinates_gen =
    {
        private["_condition","_coords_array","_iter","_point"];
        _start_coords = (_this param [0]);
        _range        = (_this param [1]);
        _method       = (_this param [2, "random", [""]]);
        _isSurface    = (_this param [3, false, [false]]);
        _coords_array = [];
        _iter         = 3;
        _point        = 0;

        for "_i" from 1 to 3 do {
            if (_method == "random") then {_point = (floor (random (_range)));};
            if (_method == "static") then {_point = _range;};
            _condition = (floor (random 2));
            if (_condition == 0) then {
                _point = (_point - (_point * 2));
            };
            _coords_array set [(count _coords_array), _point]
        };

        if (_isSurface) then {
            _coords_array set [2, (_start_coords select 2)];
        };

        (_start_coords vectorAdd _coords_array)
    };



    fnc_array_shuffle =
    {
        private["_cnt"];
        _cnt = (count _this);

        for "_i" from 1 to _cnt do {
            _this pushBack (_this deleteAt (floor (random _cnt)));
        };

        (_this)
    };



    fnc_array_shuffle2 =
    {
        private["_cnt"];
        _return = (_this param [0, [], [[]]]);
        _iter   = (_this param [1,  1, [1]]);
        _cnt    = (count _return);

        while {_iter > 0} do {
            for "_i" from 1 to _cnt do {
                _return = [(_return deleteAt (floor (random _cnt))),_return] call fnc_array_to_front;
            };
            _iter = (_iter - 1);
        };

        (_return)
    };



    fnc_array_to_front =
    {
        private["_item","_array","_temp_array"];
        _item       = (_this param [0]);
        _array      = (_this param [1, [], [[]]]);

        ([_item] + _array)
    };



    fnc_light_source =
    {
        private["_target","_light","_brightness","_ambiance","_color"];
        _target     = (_this param [0]);
        _brightness = (_this param [1]);
        _ambiance   = (_this param [2]);
        _color      = (_this param [3]);

        _light = "#lightpoint" createVehicle [0,0,0];
        _light setLightBrightness _brightness;
        _light setLightAmbient _ambiance;
        _light setLightColor _color;
        _light lightAttachObject [_target, [0,-0.1,0]];
    };



    fnc_multi_instring =
    {
        private["_test","_control"];
        _test    = (_this param [0, [], [[]]]);
        _control = (_this param [1, "", [""]]);
        _case_s  = (_this param [2, false, [false]]);
        _return  = false;

        {
            if ([_x, _control, _case_s] call BIS_fnc_inString) exitWith {_return = true;};
        } forEach _test;

        (_return)
    };
    
    

    fnc_vector_to_az =
    {
        private["_posA","_posB","_Cx","_Cy","_Kx","_Ky","_dx","_dy","_Azimuth"];
        _posA = (_this param [0, [], [[]]]);
        _posB = (_this param [1, [], [[]]]);
        _Cx = (_posA select 0);
        _Cy = (_posA select 1);
        _Kx = (_posB select 0);
        _Ky = (_posB select 1);
        _dx = -(_Cx - _Kx);
        _dy = -(_Cy - _Ky);

        _Azimuth = (round (_dx atan2 _dy));

        if (_Azimuth < 0) then {
            _Azimuth = (360 + _Azimuth);
        };

        (_Azimuth)
    };


	fnc_info_xfer =
	{
		_rx_client = (_this param [0]);
		_tx_client = (_this param [1]);
		_variable  = (_this param [2]);
		

		[[_rx_client,_variable], {
			[[_variable, _rx_client], {_this call fnc_info_xfer2}] remoteExec ['call',_tx_client];
		}] remoteExec ['call', _tx_client];
	};
	
	
	fnc_info_xfer2 =
	{
		_rx_client = (_this param [0]);
		_variable  = (_this param [1]);
		
		_info = (missionNamespace getVariable _variable);

		[[_rx_client,_variable], {
			[missionNamespace,[_variable, _info]] remoteExec ['setVariable',_rx_client];
			//[[_variable, _info], {call compile format ["%1 = %2",(_this select 0),(_this select 1)]}] remoteExec ['call',_rx_client];
		}] remoteExec ['call', _tx_client];
	};