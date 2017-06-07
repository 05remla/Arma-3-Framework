/*
	DESCRIPTION:
		finds and retreives information pertaining to near-by profiles
		
	PARAMS:
		1.  [array] initial coordinates
		2. [scalar] search range
		3. [string] side
        4. [scalar] numerical representation of desired info 

	RETURNS:
		requeted info of profile
		
	EX:
		[getPos player, 250, "WEST", 3] execVM "fnc_profile_info.sqf";

    AVAILABLE INFO:
        0. "debug"                      17. "waypointsCompleted"
        1. "active"                 	18. "positions"
        2. "position"               	19. "damages"
        3. "side"                   	20. "ranks"
        4. "profileID"              	21. "units"
        5. "type"                   	22. "speedPerSecond"
        6. "objectType"             	23. "despawnPosition"
        7. "vehicleAssignments"     	24. "hasSimulated"
        8. "vehiclesInCommandOf"    	25. "isCycling"
        9. "vehiclesInCargoOf"          26. "activeCommands"
        10. "leader"                    27. "inactiveCommands"
        11. "unitClasses"               28. "spawnType"
        12. "unitCount"                 29. "faction"
        13. "group"                     30. "isPlayer"
        14. "companyID"                 31. "_rev"
        15. "groupID"                   32. "_id"
        16. "waypoints"                 33. "busy"	
*/
_position          = (_this param [0]);
_area              = (_this param [1]);
_side              = (_this param [2]);
_info              = (_this param [3]);
_Array = [_position, _area, [_side,"entity"]] call ALIVE_fnc_getNearProfiles;
_fnc_profile_infoReturn = [];

{
	_ret_data = ((_x select 2) select _info);
	_fnc_profile_infoReturn set [count _fnc_profile_infoReturn, _ret_data];
} forEach _Array select 0;


(_fnc_profile_infoReturn)