/*
Refills one valid BuildAndRessources crate to its configured capacity.
Return value: [actuallyAdded, newAmount, capacity]
*/

params [["_crate", objNull, [objNull]]];

//Crate resource state is authoritative and may only be changed on the server.
if (!isServer) exitWith {
    diag_log "BuildAndRessources: refillCrate must run on the server.";
    [0, 0, 0]
};

//Stops if no valid crate was supplied.
if (isNull _crate) exitWith {[0, 0, 0]};

//Reads the resource type configured for this crate.
private _crateConfig = configOf _crate;
private _ressourceType = getText (_crateConfig >> "BuildAndRessources_ressourceType");

//Finds the resource type's index in the global resource order.
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

//Rejects crates that do not use a recognized BuildAndRessources resource type.
if (_ressourceIndex < 0) exitWith {
    diag_log format ["BuildAndRessources: Tried to refill invalid crate %1.", typeOf _crate];
    [0, 0, 0]
};

//Reads the crate's current amount and configured maximum capacity.
private _ressources = [_crate] call BuildAndRessources_fnc_getRessources;
private _currentAmount = _ressources select _ressourceIndex;
private _capacity = [_crate] call BuildAndRessources_fnc_getCrateCapacity;

//Calculates how much resource is missing from a completely full crate.
private _missingAmount = (_capacity - _currentAmount) max 0;

//Adds exactly the missing amount and returns the result from the shared crate-update function.
[_crate, _missingAmount] call BuildAndRessources_fnc_addRessourcesToCrate
