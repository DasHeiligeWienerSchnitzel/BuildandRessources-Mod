/*
	Changes the currently stored amount in one valid BuildAndRessources crate.

	This is the central, server-side write function for crate ressources.
	A positive delta adds resources; a negative delta removes ressources.
	The resulting amount is always clamped between 0 and the crate capacity.

	Return value:
	[actualChange, newAmount, capacity]

	actualChange can be lower than the requested delta when the crate is
	already nearly full or nearly empty.
*/

params [
    ["_crate", objNull, [objNull]],
    ["_delta", 0, [0]]
];

if (!isServer) exitWith {
    diag_log "BuildAndRessources: changeCrateRessourceAmount must run on the server.";
    [0, 0, 0]
};

if (isNull _crate) exitWith {[0, 0, 0]};

//Gets the ressource type out of the crates config.
private _crateConfig = configOf _crate;
private _ressourceType = getText (_crateConfig >> "BuildAndRessources_ressourceType");
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

if (_ressourceIndex < 0) exitWith {
    diag_log format [
        "BuildAndRessources: Tried to change resources on invalid crate %1.",
        typeOf _crate
    ];

    [0, 0, 0]
};

//Gets the ressources of the current crate
private _ressources = [_crate] call BuildAndRessources_fnc_getRessources;
//And its maximum capacity.
private _capacity = [_crate] call BuildAndRessources_fnc_getCrateCapacity;

//Does the calculation
private _currentAmount = _ressources select _ressourceIndex;
private _newAmount = ((_currentAmount + _delta) max 0) min _capacity;
private _actualChange = _newAmount - _currentAmount;

//Updates the new variable.
if (_actualChange != 0) then {
    _ressources set [_ressourceIndex, _newAmount];

    _crate setVariable ["BuildAndRessources_ressources",_ressources,true];
};

[_actualChange, _newAmount, _capacity]
