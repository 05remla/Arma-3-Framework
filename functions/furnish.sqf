/*
    DESCRIPTION:
        dynamically furniishes buildings

	PARAMS:        
		1. [object] building
		2. [string] type of building
		3. [scalar] amount of furniture
        4. [string] ?
        5. [string] debug (optional)
        
    RETURNS:
        nothing
        
    EX:
		[_x,"house",6,"random","debug"] call fnc_furniture_furnish;

	METHOD:
		1. check if area empty with wall angles
		2. check if in house
		3. check if wall behind object empty
		4. if so slide back to wall
		5. if not use coords gen to move around

	TODO:
		add check for furniture near doorways and remove
		cleanup private function variables
		slide furniture over so its centered on sampled position for final position
*/

fnc_furniture_line =
{
    [(_this select 0), (_this select 1)] spawn {
        _pos = (_this select 0);
        _pos1 = (_pos select 0);
        _pos2 = (_pos select 1);
        waitUntil {
            drawLine3d [_pos1, _pos2, (_this select 1)];
        };
    };
};


fnc_furniture_tensor_build =
{
    private [
        "_ct",
        "_cr",
        "_cp",
        "_st",
        "_sr",
        "_sp",
        "_rotation"
    ];

    _ct = cos(_this select 0);
    _cr = cos(_this select 1);
    _cp = cos(_this select 2);
    _st = sin(_this select 0);
    _sr = sin(_this select 1);
    _sp = sin(_this select 2);

    _rotation = [
        [_cp*_cr, -1*_sp*_ct + _cp*_sr*_st, _sp*_st + _cp*_sr*_ct],
        [_sp*_cr, _cp*_ct + _sp*_sr*_st, -1*_cp*_st + _sp*_sr*_ct],
        [-1*_sr, _cr*_st, _cr*_ct]
    ];

    (_rotation)
};


fnc_furniture_tensor_apply =
{
    private[
        "_v",
        "_r",
        "_r0",
        "_r1",
        "_r2",
        "_newVector"
    ];

    _v = _this select 0;
    _r = _this select 1;

    _r0 = _r select 0;
    _r1 = _r select 1;
    _r2 = _r select 2;

    _newVector = [
        (_v select 0)*(_r0 select 0) + (_v select 1)*(_r1 select 0) + (_v select 2)*(_r2 select 0),
        (_v select 0)*(_r0 select 1) + (_v select 1)*(_r1 select 1) + (_v select 2)*(_r2 select 1),
        (_v select 0)*(_r0 select 2) + (_v select 1)*(_r1 select 2) + (_v select 2)*(_r2 select 2)
    ];

    (_newVector)
};


fnc_furniture_furnish = 
{
    _building          = (_this param [0, [], [objNull]]);
    _type              = (_this param [1, "house", [""]]);
    _amount            = (_this param [2, 6, [1]]);
	//_save_objects      = (_this param [3, true, [true]]);
    _wall_furniture    = [];
    _small_furniture   = [];
    _debug             = false;
	_furniture         = 0;

	
    if ((count _this) > 4) then {
        {
            if ([_x,"debug"] call BIS_fnc_areEqual) then {_debug = true;};
        } forEach _this;
    };
    
    // config_name, side, wall_offset, ground_offset, rotate
    if (_type == "house") then {
        _wall_furniture  = [["Fridge_01_closed_F",2,.08,.06,0],["OfficeTable_01_new_F",2,.08,.01,0],
                           ["Land_OfficeChair_01_F",2,.08,.01,0],["Land_Metal_rack_Tall_F",2,.16,.09,0],["Land_Rack_F",2,-0.3,.01,270],["Land_OfficeCabinet_01_F",2,.08,.02,0]];
                           
        _anyw_furniture  = [["Land_ChairWood_F",2]];
                                
        _small_furniture = ["Land_FlatTV_01_F","Land_Microwave_01_F","Land_GamingSet_01_console_F",
                            "Land_Laptop_unfolded_F","Land_PCSet_01_keyboard_F",["Land_PCSet_01_case_F",2]];
    };

	
	//if (_save_objects == true) then {
		_furniture = (missionNamespace getVariable ["furniture", []]);
    //};
	
	_indx = 1;
    while {_indx <= _amount} do
    {
        _obj_name = (_wall_furniture select (floor (random (count _wall_furniture))));
        _object   = ((_obj_name param [0]) createVehicle [0,0,100]);
		_furniture set [(count _furniture), _object];
        [_building, [_object,(_obj_name param [1]),(_obj_name param [2]),(_obj_name param [3]),(_obj_name param [4])], _debug] call fnc_furniture_placement;
        _indx = (_indx + 1);
    };
	
	sleep 1.5;
	{
		if (((vectorUp _x) param [2]) > .95) then {
			_x enableDynamicSimulation true;
		} else {
			deleteVehicle _x;
		};
	} forEach _furniture;
	
	//if (_save_objects == true) then {
		missionNamespace setVariable ["furniture", _furniture];
    //};
/*	
	_anim = 0; 
	_dn=-1; 
	{  
		for [{_i=1},{_i<=20},{_i=_i+1}] do   {
			_dn=_dn+1;
			_x animate ["dvere" + str _i,_anim];  
			_x animate ["door_0" + str _i,_anim];  
			_x animate ["vrataL" + str _i,_anim];  
			_x animate ["vrataR" + str _i,_anim]; 
						  
			if (_x animationPhase "dvere"  + str _i > 0) then {_mdoor = createMarker [str _dn, position _x];_mdoor setMarkerType "Dot"; _mdoor setMarkerPos getPos _x }; 
			if (_x animationPhase "dvere1" + str _i > 0) then {_mdoor = createMarker [str _dn, position _x];_mdoor setMarkerType "Dot"; _mdoor setMarkerPos getPos _x };
			if (_x animationPhase "door_0" + str _i > 0) then {_mdoor = createMarker [str _dn, position _x];_mdoor setMarkerType "Dot"; _mdoor setMarkerPos getPos _x };
			if (_x animationPhase "vrataL" + str _i > 0) then {_mdoor = createMarker [str _dn, position _x];_mdoor setMarkerType "Dot"; _mdoor setMarkerPos getPos _x };
			if (_x animationPhase "vrataR" + str _i > 0) then {_mdoor = createMarker [str _dn, position _x];_mdoor setMarkerType "Dot"; _mdoor setMarkerPos getPos _x };
		};   
	}foreach [_building];
*/
};
        

fnc_furniture_wall_check =
{        
      //////////////////////////////////////////
     // CHECK IF WALL BEHIND OBJECT IS EMPTY //
    //////////////////////////////////////////
    private["_potential_position","_rot_vect","_bottom","_top","_debug",
            "_area_intersect","_place_pass","_new_vect1","_new_vect2",
            "_pos1ASL","_pos1ATL","_pos2ASL","_pos2ATL","_spawn_height",
            "_final_position","_object","_object_array","_rotate",
            "_vector_addition","_vectorToWall","_lis_ret_0","_lis_ret",
            "_ret_type","_wall_offset","_ground_offset","_wall_pass",
            "_place_pass","_inhouse_pass","_indx","_corner""_pos3ASL",
            "_pos3ATL","_wall_ret","_building","_buildingPositions",
            "_building_position","_bldg_dir","_bldg_dir_array",
            "_bcntr_bld","_bcntr_obj","_bbr","_bbr1","_bbr2","_x1","_x2",
            "_y1","_y2","_z1","_z2","_break"];
            
    //systemChat str _this;        
    _object_array       = (_this param [0]);
    _potential_position = (_this param [1]);
    _rotate             = (_this param [2]);
    _rot_vect           = (_this param [3]);
    _bottom             = (_this param [4]);
    _top                = (_this param [5]);
    _debug              = (_this param [6]);
    _object             = (_object_array param [0]);   
    _object_back        = (_object_array param [1]);   
    _object_woffset     = (_object_array param [2]);
    _object_goffset     = (_object_array param [3]);
    _object_rotate      = (_object_array param [4]);
    //hint str [_object,_object_back,_object_woffset,_object_goffset, _object_rotate];
    
    _wall_pass          = false;
    _final_position     = 0;
    
    {
        _new_vect1 = ([_x,_rot_vect] call fnc_furniture_tensor_apply);
        //_new_vect1 = ([(_x select 0),_rot_vect] call fnc_furniture_tensor_apply);
        _pos1ATL = (_potential_position vectorAdd _new_vect1);
        _pos1ASL = (ATLtoASL _pos1ATL);

        _object setDir (_rotate + _object_rotate);
        _vector_addition = ((vectorDir _object) vectorMultiply 4);
        _vectorToWall  = (_pos1ASL vectorAdd _vector_addition);
                    
        _lis_ret = (lineIntersectsSurfaces [
                        _pos1ASL,
                        _vectorToWall,
                        objNull, objNull, true, 1, "GEOM", "NONE"]);
        
        // CHECK IF DISTANCE BETWEEN BOTH LIS_CHECKS ARE THE SIZE OF THE OBJECT         
        _lis_ret_0 = (_lis_ret select 0);
        if (not (isNil "_lis_ret_0")) then {
            _ret_type = (_lis_ret_0 select 3);
            if (_debug) then {[[_pos1ATL,(ASLtoATL _vectorToWall)],[1,0,0,1]] call fnc_furniture_line;};
            if (not (_ret_type isKindOf "House")) then {
                _wall_pass = false;
            } else {
                _wall_pass = true;
                //_lefttoright_offset = ((((_top select 0) select 0) distance ((_top select 0) select 1)) / 2);
                _wall_offset = (((((_top select 1) select 0) distance ((_top select 1) select 1)) / 2) + _object_woffset);
                _ground_offset = (((((_top select 0) select 0) distance ((_bottom select 0) select 0)) / 2));
                _direction = ((vectorDir _object) vectorMultiply _wall_offset);

                // MOVE OBJECT OVER HALF ITS WIDTH LEFT OR RIGHT
                _final_position = ((_lis_ret_0 select 0) vectorDiff _direction);
                //_final_position = (_final_position vectorDiff _lefttoright_offset);
                _final_position = (ASLtoATL _final_position);
				_final_position set [2, ((nearestBuilding _potential_position buildingPos 2) param [2])];
            };
        };
    } forEach (_top select _object_back);
    
    ([_wall_pass, _final_position])
};



fnc_furniture_area_check =
{
      //////////////////////////////////////////////////////////////////////////
     // CHECK IF INITIAL PLACEMENT SPACE IS EMPTY BASED ON OBJECT DEMENSIONS //
    //////////////////////////////////////////////////////////////////////////
    private["_potential_position","_rot_vect","_bottom","_top","_debug",
            "_area_intersect","_place_pass","_new_vect1","_new_vect2",
            "_pos1ASL","_pos1ATL","_pos2ASL","_pos2ATL","_spawn_height",
            "_final_position","_object","_object_array","_rotate",
            "_vector_addition","_vectorToWall","_lis_ret_0","_lis_ret",
            "_ret_type","_wall_offset","_ground_offset","_wall_pass",
            "_place_pass","_inhouse_pass","_indx","_corner""_pos3ASL",
            "_pos3ATL","_wall_ret","_building","_buildingPositions",
            "_building_position","_bldg_dir","_bldg_dir_array",
            "_bcntr_bld","_bcntr_obj","_bbr","_bbr1","_bbr2","_x1","_x2",
            "_y1","_y2","_z1","_z2","_break"];
            
    _object_array       = (_this param [0]);
    _potential_position = (_this param [1]);
    _rotate             = (_this param [2]);
    _rot_vect           = (_this param [3]);
    _bottom             = (_this param [4]);
    _top                = (_this param [5]);
    _debug              = (_this param [6]);
    _object             = (_object_array param [0]);   
    _object_back        = (_object_array param [1]);   
    _object_woffset     = (_object_array param [2]);
    _object_goffset     = (_object_array param [3]);
    _object_rotate      = (_object_array param [4]);
    _place_pass         = true;
    _area_intersect     = 0;
    
    {
        _new_vect1 = ([(_x param [0]),_rot_vect] call fnc_furniture_tensor_apply);
        _new_vect2 = ([(_x param [1]),_rot_vect] call fnc_furniture_tensor_apply);
        _pos1ATL = (_potential_position vectorAdd _new_vect1);
        _pos2ATL = (_potential_position vectorAdd _new_vect2);
        _pos1ASL = (ATLtoASL _pos1ATL);
        _pos2ASL = (ATLtoASL _pos2ATL);

        lineIntersectsSurfaces [
            _pos1ASL, 
            _pos2ASL,
            objNull, objNull, true, 1, "GEOM", "NONE"
        ] select 0 params ["","","","_area_intersect"];
        
        if (_debug) then {[[_pos1ATL,_pos2ATL],[1,1,1,1]] call fnc_furniture_line;};
        if (not ([_area_intersect,0] call BIS_fnc_areEqual)) then {
            _place_pass = false;
        };            
    } forEach _top;
    
    (_place_pass)
};


        
fnc_furniture_roof_check =
{
      ////////////////////////////////////////////////////////////////////
     // CHECK IF OBJECT IS IN HOUSE BY CHECKING IF ITS UNDER THE ROOF  //
    ////////////////////////////////////////////////////////////////////
    private["_potential_position","_rot_vect","_bottom","_top","_debug",
            "_area_intersect","_place_pass","_new_vect1","_new_vect2",
            "_pos1ASL","_pos1ATL","_pos2ASL","_pos2ATL","_spawn_height",
            "_final_position","_object","_object_array","_rotate",
            "_vector_addition","_vectorToWall","_lis_ret_0","_lis_ret",
            "_ret_type","_wall_offset","_ground_offset","_wall_pass",
            "_place_pass","_inhouse_pass","_indx","_corner""_pos3ASL",
            "_pos3ATL","_wall_ret","_building","_buildingPositions",
            "_building_position","_bldg_dir","_bldg_dir_array",
            "_bcntr_bld","_bcntr_obj","_bbr","_bbr1","_bbr2","_x1","_x2",
            "_y1","_y2","_z1","_z2","_break"];
            
    //systemChat str _this;        
    _object_array       = (_this param [0]);
    _potential_position = (_this param [1]);
    _rotate             = (_this param [2]);
    _rot_vect           = (_this param [3]);
    _bottom             = (_this param [4]);
    _top                = (_this param [5]);
    _debug              = (_this param [6]);
    _object             = (_object_array param [0]);   
    _object_back        = (_object_array param [1]);   
    _object_woffset     = (_object_array param [2]);
    _object_goffset     = (_object_array param [3]);
    _object_rotate      = (_object_array param [4]);
    _inhouse_pass       = true;
    
    {
        _corner  = (_x select 0);
        _pos3ATL = (_potential_position vectorAdd _corner);
        _pos3ASL = (ATLtoASL _pos3ATL);
        _lis_ret = (lineIntersectsSurfaces [
                    _pos3ASL, 
                    (_pos3ASL vectorAdd [0, 0, 50]),
                    objNull, objNull, true, 1, "GEOM", "NONE"]);
                
        _lis_ret_0 = (_lis_ret select 0);
        if (not (isNil "_lis_ret_0")) then {
            _ret_type = (_lis_ret_0 select 3);
            if (not (_ret_type isKindOf "House")) then {
                _inhouse_pass = false;
            };
        } else {
            _inhouse_pass = false;
        };
    } forEach _top;
    
    (_inhouse_pass)
};



fnc_furniture_placement =
{        
    private["_potential_position","_rot_vect","_bottom","_top","_debug",
            "_area_intersect","_place_pass","_new_vect1","_new_vect2",
            "_pos1ASL","_pos1ATL","_pos2ASL","_pos2ATL","_spawn_height",
            "_final_position","_object","_object_array","_rotate",
            "_vector_addition","_vectorToWall","_lis_ret_0","_lis_ret",
            "_ret_type","_wall_offset","_ground_offset","_wall_pass",
            "_place_pass","_inhouse_pass","_indx","_corner""_pos3ASL",
            "_pos3ATL","_wall_ret","_building","_buildingPositions",
            "_building_position","_bldg_dir","_bldg_dir_array",
            "_bcntr_bld","_bcntr_obj","_bbr","_bbr1","_bbr2","_x1","_x2",
            "_y1","_y2","_z1","_z2","_break"];
            
    _building          = (_this param [0, [], [objNull]]);
    _object_array      = (_this param [1, [], [[]]]);
    _debug             = (_this param [2, false, [false]]);

    _buildingPositions = ([_building] call BIS_fnc_buildingPositions);
    _numberOfPositions = (count _buildingPositions);
    _building_position = (_building buildingPos (floor (random (_numberOfPositions))));
    _rotate            = 0;
    _object = (_object_array select 0);
    
    _bldg_dir       = (getDir _building);
    _bldg_dir_array = [];
    
    {
        _bldg_dir = (_bldg_dir + _x);
        if (_bldg_dir > 359) then {
            _bldg_dir = (_bldg_dir - 359);
        };
        
        _bldg_dir_array set [(count _bldg_dir_array), _bldg_dir];
    } forEach [90,90,90,90];

    _bcntr_bld = (boundingCenter _building);
    _bcntr_obj = (boundingCenter _object);
    _bbr       = (boundingBoxReal _object);
    _bbr1      = (_bbr param [0]);
    _bbr2      = (_bbr param [1]);
    _x1        = (_bbr1 param [0]);
    _y1        = (_bbr1 param [1]);
    _z1        = (_bbr1 param [2]);
    _x2        = (_bbr2 param [0]);
    _y2        = (_bbr2 param [1]);
    _z2        = (_bbr2 param [2]);

    _top    = [[[_x1,_y1,_z2],[_x2,_y1,_z2]],[[_x2,_y1,_z2],[_x2,_y2,_z2]],[[_x2,_y2,_z2],[_x1,_y2,_z2]],[[_x1,_y2,_z2],[_x1,_y1,_z2]]];
    _bottom = [[[_x1,_y1,_z1],[_x2,_y1,_z1]],[[_x2,_y1,_z1],[_x2,_y2,_z1]],[[_x2,_y2,_z1],[_x1,_y2,_z1]],[[_x1,_y2,_z1],[_x1,_y1,_z1]]];

    _potential_position = 0;
    _final_position     = 0;
    _break              = false;        
    _wall_pass          = false;
    _inhouse_pass       = 0;
	_iter               = 0;
    
    while {(not _break) or (_iter == 20)} do
    {
        _place_pass          = true;
        _inhouse_pass        = true;
        _area_intersect      = 0;
        _potential_position  = ([_building_position, 3, "random", true] call fnc_coordinates_gen);
        _rotate              = (_bldg_dir_array select (floor (random (count _bldg_dir_array))));
        _rot_vect            = ([0,0,_rotate] call fnc_furniture_tensor_build);

        _place_pass     = ([_object_array, _potential_position, _rotate, _rot_vect, _bottom, _top, _debug] call fnc_furniture_area_check);
        _inhouse_pass   = ([_object_array, _potential_position, _rotate, _rot_vect, _bottom, _top, _debug] call fnc_furniture_roof_check);
        _wall_ret       = ([_object_array, _potential_position, _rotate, _rot_vect, _bottom, _top, _debug] call fnc_furniture_wall_check);
        _wall_pass      = (_wall_ret select 0);
        _final_position = (_wall_ret select 1);
        
        // IF ALL CHECKS PASS BREAK AND PLACE OBJECT    
        //systemChat str [_place_pass, _wall_pass, _inhouse_pass];
        if ((_place_pass) and (_wall_pass) and (_inhouse_pass)) exitWith {
            _break = true;
        };
		_iter = (_iter + 1);
    };

    _object setDir _rotate;
    //_object enableSimulation false;
    _object setPos _final_position;    
};