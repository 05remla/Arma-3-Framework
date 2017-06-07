/*
    DESCRIPTION:
        Trasfers units or groups from one owner to another while keeping unit/group
        attributes.

    PARAMS:
        1.  [group] group that will be moving
        2. [object] node that will be new owner of group

    RETURNS:
        Nothing

    EX:
        [_group, "HC_2"] call fnc_headless_xfer_group;
*/

    fnc_headless_sync_attributes =
    {
        _syncGroup = (_this param [0]);
        _trigSyncs = (_this param [1]);
        _waySyncs  = (_this param [2]);
        _objSyncs  = (_this param [3]);

        {   _objs = _objSyncs select _forEachIndex;
            _x synchronizeObjectsAdd _objs;
        } forEach units _syncGroup;

        {
            _wayPoint = _x;
            {   _x synchronizeTrigger [_wayPoint];
            } forEach (_trigSyncs select _forEachIndex);

            {   _x synchronizeWaypoint [_wayPoint];
            } forEach (_waySyncs select _forEachIndex);
        
        } forEach waypoints _syncGroup;
    };    
      

      
    fnc_headless_xfer_group2 =
    {
        _groupMoving   = (_this param [0]);
        _hcRxing       = (_this param [1]);
        _rxingClientID = (owner _hcRxing);
        _groupMoving setGroupOwner _rxingClientID;
    };
    
    
        
    fnc_headless_xfer_group =
    {
        _groupMoving   = (_this param [0]);
        _hcRxing       = (_this param [1]);
        _rxingClientID = (owner _hcRxing);
        systemChat (str _this);

        //add dummy waypoint
        _lead = (leader _groupMoving);
        _dummyWaypoint = _groupMoving addWaypoint [position _lead, 0.1, currentWaypoint _groupMoving, "DummyWaypoint"];
        _dummyWaypoint setWaypointTimeout [6,6,6];
        _dummyWaypoint setWaypointCompletionRadius 100;

        //Remember syncs from waypoints to other waypoints and triggers
        _syncTrigArray = [];
        _syncWayArray = [];

        {   _wayNum = _forEachIndex;
            _syncedTrigs = synchronizedTriggers _x;
            _syncTrigArray set [_wayNum,_syncedTrigs];
            _syncedWays = synchronizedWaypoints _x;
            _syncWayArray set [_wayNum,_syncedWays];
        }forEach waypoints _groupMoving;

        //remember syncs to objects
        _syncObjectsArray = [];

        {   _syncObjects = synchronizedObjects _x;
            _syncObjectsArray = _syncObjectsArray + [_syncObjects];
        }forEach units _groupMoving;

        //relocate group
        _moveToHC = (_groupMoving setGroupOwner _rxingClientID);

        //reattach triggers and waypoints
        [[_groupMoving,_syncTrigArray,_syncWayArray,_syncObjectsArray], {_this call fnc_headless_sync_attributes}] remoteExec ['call', _hcRxing];

        //_firstWaypoint = (waypoints _groupMoving) select 1;
        {   if (waypointName _x == "DummyWaypoint") then {
                deleteWaypoint _x;
            };
        }forEach waypoints _groupMoving;
    };