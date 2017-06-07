/*
    DESCRIPTION:
        adds light to structures

	PARAMS:        
		1. [array|object] structure object or array of structure objects
        
    RETURNS:
        Nothing
        
    EX:
        [["building1","building2"]] call fnc_illuminate_structure;
*/
_buildings = _this;
_amount    = .20;
//_buildings = (_this param [0]);
//_amount    = (_this param [1, .25, [1]]);



//if ((typeName _buildings) == "ARRAY") then {
    
    {
        _currentStruct = _x;
        _buildingsPosObjects = [_currentStruct] call BIS_fnc_buildingPositions;
        _iter = (ceil ((count _buildingsPosObjects) * _amount));
        while {_iter > 0} do
        {
            _light_helper = ("Fuel_can" createVehicle [0,0,0]);
            _randNumFromPos = (floor (random (count _buildingsPosObjects)));
            _light_helper setPosATL (_currentStruct buildingPos _randNumFromPos);
            _pos = (getPos _light_helper);
            _light_helper setPos [(_pos select 0), (_pos select 1), ((_pos select 2) + 2)];
            _light_helper enableSimulation false;
            [_light_helper, {_this hideObject true}] remoteExec ['call',0];
            [[_light_helper, .175, [1.75, 1.75, 1.2], [.7, .7, .5]], {_this call fnc_light_source}] remoteExec ['call',0];
            _iter = (_iter - 1);
        };
    } forEach _buildings;
//};