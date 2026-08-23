/*
Initializes a depot's persistent stock array on the server.
This is deliberately lazy so Eden attributes have already been applied
before their values are converted into runtime mission state.
*/

params [
    ["_depot", objNull, [objNull]]
];

//Depot runtime state is authoritative and must only be initialized on the server.
if (!isServer) exitWith { false };

//Stops if no valid depot object was supplied.
if (isNull _depot) exitWith { false };

//Rejects objects that are not configured as BuildAndRessources depots.
if ((getNumber (configOf _depot >> "BuildAndRessources_isRessourceDepot")) <= 0) exitWith {false};

//Checks whether the depot already has a complete stored runtime stock array.
private _storedStocks = _depot getVariable ["BuildAndRessources_depotStocks", []];

//If all four resource values already exist, initialization has already been completed.
if ((count _storedStocks) isEqualTo 4) exitWith {true};

//Builds the initial stock array from the depot's Eden attributes and current capacities.
private _initialStocks = [_depot] call BuildAndRessources_fnc_getDepotStock;

//Stores and globally synchronizes the initialized runtime stock on this depot.
_depot setVariable ["BuildAndRessources_depotStocks", _initialStocks, true];

//Signals that initialization completed successfully.
true
