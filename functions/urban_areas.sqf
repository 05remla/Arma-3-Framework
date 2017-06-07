/*
	DESCRIPTION:
		
	PARAMS:
        
	RETURNS:
        Array:
            0. cityName;
            1. cityPos;
            2. cityRadA;
            3. cityRadB;
            4. cityType;
            5. cityAngle;
		
	EX:
*/

private ["_locations","_cityTypes","_locale_indx","_z","_i","_cities"];

_cities    = [];
_locations = configfile >> "CfgWorlds" >> worldName >> "Names";
_cityTypes = ["NameVillage","NameCity","NameCityCapital"];

for "_z" from 0 to (count _locations - 1) do {
	_locale_indx = _locations select _z;

	private["_cityName","_cityPos","_cityRadA","_cityRadB","_cityType","_cityAngle"];
	_cityName  = (getText(_locale_indx >> "name"));
	_cityPos   = (getArray(_locale_indx >> "position"));
	_cityRadA  = (getNumber(_locale_indx >> "radiusA"));
	_cityRadB  = (getNumber(_locale_indx >> "radiusB"));
	_cityType  = (getText(_locale_indx >> "type"));
	_cityAngle = (getNumber(_locale_indx >> "angle"));
    
	if (_cityType in _cityTypes) then {
		_cities set [(count _cities),[_cityName, _cityPos, _cityRadA, _cityRadB, _cityType, _cityAngle]];
	};
};


(_cities)