/*
	DESCRIPTION:
		spawn various units in various positions within structures provided
		
	PARAMS:
		1.       [scalar] max number of units to spawn
		2.         [side] the units will belong to
		3.       [string] faction of units
        4.       [string] of specific unit in config or "random" for random unit
        5.        [array] structure objects
        6. [array|scalar] unit skills
		8.        [array] (this select 0): is bool to use or not to use headless client ai dispersion
                          (this select 1): is array containing headless client objects

	RETURNS:
		array of spawned groups
		
	EX:
		[2, EAST, "OPF_F", "random", [#buildingObject, #buildingObject], [skills]] call fnc_spawn_occupy_structure;
		[2, EAST, "OPF_F", "random", [#buildingObject, #buildingObject], [skills], ["unarmmed"], "ext"] call fnc_spawn_occupy_structure;
*/
_amount      = (_this param [0, 1, [1,[]]]);
_side        = (_this param [1, EAST, [EAST]]);
_faction     = (_this param [2, "IND_C_F", [""]]);
_unit_name   = (_this param [3, "random", [""]]);
_structures  = (_this param [4, [], [[]]]);
_skillArgs   = (_this param [5, .5, [[],1]]);
_returnArray = [];
_built_args  = [];

    if (count _structures == 0) exitWith {};

    {        
        _currentStruct     = _x;
        _buildingPositions = [_currentStruct] call BIS_fnc_buildingPositions;

        if (not isNil "_skillArgs") then {
            _built_args = ([(getPos (_structures select 1)), _side, _faction, _unit_name, _amount, 30, _skillArgs]);
        } else {
            _built_args = ([(getPos (_structures select 1)), _side, _faction, _unit_name, _amount, 30]);
        };
        
        // IF UNIT EXCLUSSION ARGS PRESENT PASS TO fnc_spawn_units
        if ((count _this) > 6) then {
            _ind = ((count _this) - 6);
            while {_ind > 0} do {
                _built_args set [(count _built_args), (_this select (5 + _ind))];
                _ind = (_ind - 1);
            };
        };
        
        _grp = (_built_args call fnc_spawn_units);        
        _returnArray set [count _returnArray, _grp];

        {
            _randNumFromPos = (floor (random (count _buildingPositions)));
            _x setPosATL (_currentStruct buildingPos _randNumFromPos);
            if ((ceil (random 3)) == 1) then {
                doStop _x;
            };
        } forEach (units _grp);

    } forEach _structures;

	
	(_returnArray)