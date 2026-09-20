if (!isServer) exitWith {};

addMissionEventHandler ["BuildingChanged", {
    params ["_from", "_to", "_isRuin"];

    if !(_from getVariable ["BAR_isBuiltStructure", false]) exitWith {};
    if (!_isRuin) exitWith {};

    private _class = typeOf _from;

    private _entryIndex = BuildAndRessources_classnameList findIf {
        (_x select 0) == _class
    };

    if (_entryIndex == -1) exitWith {};

    private _entry = BuildAndRessources_classnameList select _entryIndex;
    private _time = _entry select 4;

    _to setVariable ["BAR_isBuiltRuin", true, true];

    [_to, _time, "Ruine", false, [], []] remoteExecCall ["BuildAndRessources_fnc_deleteObject",0,_to];
}];