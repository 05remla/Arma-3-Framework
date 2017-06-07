call (compile (preprocessFileLineNumbers "framework\lib.sqf"));
call (compile (preprocessFileLineNumbers "framework\headless_lib.sqf"));
call (compile (preProcessFileLineNumbers "framework\functions\furnish.sqf"));

fnc_set_skills             = (compileFinal (preprocessFileLineNumbers "frameWork\functions\set_skills.sqf"));
fnc_urban_areas            = (compileFinal (preprocessFileLineNumbers "frameWork\functions\urban_areas.sqf"));
fnc_spawn_units            = (compileFinal (preprocessFileLineNumbers "frameWork\functions\spawn_units.sqf"));
fnc_find_structures        = (compileFinal (preprocessFileLineNumbers "frameWork\functions\find_structures.sqf"));
fnc_alive_profile_info     = (compileFinal (preprocessFileLineNumbers "frameWork\functions\alive_profile_info.sqf"));
fnc_illuminate_structure   = (compileFinal (preprocessFileLineNumbers "frameWork\functions\illuminate_structure.sqf"));
fnc_spawn_occupy_structure = (compileFinal (preprocessFileLineNumbers "frameWork\functions\spawn_occupy_structure.sqf"));