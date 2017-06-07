/*
	DESCRIPTION:
		spawn units based on amount, location, type of unit or all random units, and skill
		
	PARAMS:
		1.  [array] coordinates for placement
		2.   [side] group side
		3. [string] faction
        4. [string] config name of unit or "random"
		5. [scalar] number of units to spawn
		6. [scalar] random distance from coords
		7.  [array] args to pass to "fnc_set_skills"
        8.  [array] patterns or names of soldiers not to spawn
		9. [string] exclusion method [fast|any]
                    fast: 1 for 1 match exclusion
                    any: pattern matching exclusion
        
	RETURNS:
		group spawned
		
	EX:
		_grp = [(getPos player), WEST, "BLU_F", "random", 1, 5, [.6,.7,.8]] call fnc_spawn_units;
*/
_coordinates  = (_this param [0, [0,0,0], [[]]]);
_side         = (_this param [1, EAST, [EAST]]);
_faction      = (_this param [2, "IND_C_F", [""]]);
_unit_name    = (_this param [3, "random", [""]]);
_spawn_amount = (_this param [4, 1, [1]]);
_distance     = (_this param [5, 5, [1]]);
_skillArgs    = (_this param [6, .5, [[],1]]);
_ex_method    = (_this param [7, "ext", [""]]);
_ex_list      = (_this param [8, ["virtual", "pilot", "unarmed", "VR", "Survivor"], [[]]]);

    
    _units_array = (['man', _faction] call fnc_get_vehicles_by_faction);
	_grp = createGroup _side;
	while {_spawn_amount > 0} do
	{
		_randomPlacement = ([_coordinates, _distance] call fnc_coordinates_gen);
		if (_unit_name == "random") then {
            _units_array = _units_array call fnc_array_shuffle;
            _soldierName = (_units_array select floor random count _units_array);
            if (_ex_method == "fast") then {
                if (not (_soldierName in _ex_list)) then {
                    _soldierName createUnit [_randomPlacement, _grp];
                };
                
            } else {
                _clear = 0;
                if (not ([_ex_list, _soldierName] call fnc_multi_inString)) then {
                    _soldierName createUnit [_randomPlacement, _grp];
                };
            };
		};
		
		//if (_unit_name in _units_array) then {
		//	_unit_name createUnit [_randomPlacement, _grp];
		//};
        
		_spawn_amount = _spawn_amount - 1;
	};


    
    {
        _skillArgsTemp = _skillArgs;
        _skillArgsTemp = [_x] + [_skillArgsTemp];        
        _skillArgsTemp call fnc_set_skills;
    } forEach units _grp;


    
	(_grp)