/*
	DESCRIPTION:
		sets unit's ability coeficient
		
	PARAMS:
		1.       [object] coordinates for placement
		2. [scalar|array] if scalar: ability coeficient will be a static value of param
                          if array: ability coeficient will be a random value of param

	RETURNS:
		nothing
		
	EX:
		[p1, [.6,.7,.8]] call fnc_set_skills;
		[p1, .8] call fnc_set_skills;
*/
_unit       = (_this param [0]);
_skillLevel = (_this param [1, .5, [[], 1]]);
_value      = 0;
_skills     = ["aimingAccuracy","aimingShake","aimingSpeed","endurance","spotDistance",
               "spotTime","courage","reloadSpeed","commanding","general"];

{
    if ((typeName _skillLevel) == "ARRAY") then {
        _value = random _skillLevel;
    } else {
        _value = _skillLevel;
    };
    
    _unit setSkill [_x, _value];
} forEach _skills;