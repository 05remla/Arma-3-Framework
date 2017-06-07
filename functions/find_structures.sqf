/*
    DESCRIPTION:
        searches for various size building (size depends on args) and returns array of structures

	PARAMS:        
		1.  [array] coordinates to start search
		2. [scalar] search range
		3. [scalar] return limit
        4. [scalar] minimum size of assets to return
        5.   [bool] shuffle return for randomization
        
    RETURNS:
        structures found using given parameters
        
    EX:
        VAR = [(getPos player), 500, 2, 30, true] call fnc_find_structures;
        VAR = [[100,250,0], 100, 20, 18, false] call fnc_find_structures;
*/
    _coordinates       = (_this param [0, [0,0,0], [[]]]);
    _objectSearchRange = (_this param [1, 50, [1]]);
    _returnLimit       = (_this param [2, 20, [1]]);
    _size              = (_this param [3, 5, [1]]);
    _shuffle           = (_this param [4, true, [true]]);

    _usableBuildings   = [];
    _foundObjects = (_coordinates nearObjects ["house", _objectSearchRange]);
    {   _buildingPositions = ([_x] call BIS_fnc_buildingPositions);
        if ((count _buildingPositions) >= _size) then {
            _usableBuildings set [(count _usableBuildings), _x];
        };
    } forEach _foundObjects;

    _usableBuildingsCount = (count _usableBuildings);
    if (_usableBuildingsCount < 1) exitWith {(0)};
    
    if (_shuffle) then {
        _usableBuildings = ([_usableBuildings, 2] call fnc_array_shuffle2);
    };
    
    if (_usableBuildingsCount > _returnLimit) then {
        _usableBuildings resize _returnLimit;
    };

    
    (_usableBuildings)