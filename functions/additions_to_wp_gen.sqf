
_args = [];
{
    if (typeName _x == "STRING") then {
        _args set [(count _args), _x];
    };
} forEach _this;

_indx = ((count _args) - 1);
while {_indx > 0} do 
{
    {
        _type  = (_x select 0);
        _array = (_x select 1);
        if 
    } forEach _element_arrays;