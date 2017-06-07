/*
    DESCRIPTION:
        takes array of headless clients and array of groups and moves groups to
        headless clients based on number of groups

    PARAMS:
        1.  [array] coordinates to start search
        2.  [array] search range

    RETURNS:
        Nothing

    EX:
        [[hc1,hc2], [group1,group2]] call fnc_headless_distribute_groups;
        [[hc1,hc2], [group1,group2], 'smart'] call fnc_headless_distribute_groups;
*/
_hc_nodes = (_this param [0, [], [[]]]);
_groups   = (_this param [1, [], [[]]]);

_nodes_constant  = (count _hc_nodes);
_groups_index    = (count _groups);
_nodes_index     = _nodes_constant;

while {_groups_index > 0} do {
    if (_nodes_index == 0) then {
        _nodes_index = _nodes_constant;
        sleep 3;
    };

    _nodes_index  = (_nodes_index - 1);
    _groups_index = (_groups_index - 1);
    [(_groups select _groups_index), (_hc_nodes select _nodes_index)] call fnc_headless_xfer_group;
};