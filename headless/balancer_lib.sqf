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