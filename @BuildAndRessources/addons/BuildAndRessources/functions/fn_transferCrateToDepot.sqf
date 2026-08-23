/*
Transfers as much of a crate's stored resource as possible into a nearby
compatible finite depot stock.

Depositing into an infinite depot is intentionally prohibited so resources
cannot disappear into an already unlimited pool.

Return value:
[transferred, crateAmount, crateCapacity, depotAmount, depotCapacity]
*/

params [
    ["_depot", objNull, [objNull]],
    ["_crate", objNull, [objNull]]
];

//This function is authoritative and must only modify resource state on the server.
if (!isServer) exitWith { [0, 0, 0, 0, 0] };

//Stops if either the depot or crate reference is invalid.
if (isNull _depot || {isNull _crate}) exitWith { [0, 0, 0, 0, 0] };

//Assumes locally called requests are valid unless they came through remote execution.
private _remoteRequestValid = true;

//For remote calls, verifies that the requesting player is physically close to the depot or crate.
if (isRemoteExecuted) then {
    private _callerOwner = remoteExecutedOwner;
    private _caller = (allPlayers select { owner _x isEqualTo _callerOwner }) param [0, objNull];

    _remoteRequestValid = !isNull _caller && {(_caller distance _depot) <= 10 || {(_caller distance _crate) <= 10}};
};

//Rejects invalid or suspicious remote transfer requests.
if (!_remoteRequestValid) exitWith { [0, 0, 0, 0, 0] };

//Rechecks on the server whether this depot is actually a valid deposit target for the crate.
private _validatedDepot = [_crate, "deposit"] call BuildAndRessources_fnc_findNearbyDepot;

if !(_validatedDepot isEqualTo _depot) exitWith { [0, 0, 0, 0, 0] };

//Reads the crate's resource type and its index in the global resource array.
private _ressourceType = getText (configOf _crate >> "BuildAndRessources_ressourceType");
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

//Stops if the crate uses an unknown resource type.
if (_ressourceIndex < 0) exitWith { [0, 0, 0, 0, 0] };

//Makes sure the depot has its persistent runtime stock initialized before changing it.
[_depot] call BuildAndRessources_fnc_initializeDepot;

//Reads the crate's current resource amount and capacity.
private _crateRessources = [_crate] call BuildAndRessources_fnc_getRessources;
private _crateAmount = _crateRessources select _ressourceIndex;
private _crateCapacity = [_crate] call BuildAndRessources_fnc_getCrateCapacity;

//Reads the depot's current stock and finite capacity for this resource type.
private _depotStocks = [_depot] call BuildAndRessources_fnc_getDepotStock;
private _depotAmount = _depotStocks select _ressourceIndex;
private _depotCapacity = [_depot, _ressourceType] call BuildAndRessources_fnc_getDepotCapacity;

//Nothing can be deposited if the crate is empty or the depot has infinite stock.
if (_crateAmount <= 0 || {_depotAmount < 0}) exitWith {[0, _crateAmount, _crateCapacity, _depotAmount, _depotCapacity]};

//Calculates how much free room remains in the depot and limits the transfer to that amount.
private _freeSpace = (_depotCapacity - _depotAmount) max 0;
private _requestedTransfer = _crateAmount min _freeSpace;

//Stops if there is no room for any resource transfer.
if (_requestedTransfer <= 0) exitWith {[0, _crateAmount, _crateCapacity, _depotAmount, _depotCapacity]};

//Adds the requested amount to the depot first.
private _depotResult = [ _depot, _ressourceType, _requestedTransfer] call BuildAndRessources_fnc_changeDepotRessourceAmount;

//Reads how much the depot actually accepted after all capacity checks.
private _actuallyStored = _depotResult select 0;

//Removes exactly that accepted amount from the crate.
private _crateResult = [ _crate, -_actuallyStored] call BuildAndRessources_fnc_changeCrateRessourceAmount;

//Converts the crate-side negative change into a positive transferred amount.
private _actuallyTransferred = -(_crateResult select 0);

// Restore depot stock if an unexpected crate-side limit prevented removal.
if (_actuallyTransferred < _actuallyStored) then {
    [ _depot, _ressourceType, -(_actuallyStored - _actuallyTransferred)] call BuildAndRessources_fnc_changeDepotRessourceAmount;
};

//Reads the final depot state after the transfer has completed.
private _finalStocks = [_depot] call BuildAndRessources_fnc_getDepotStock;

//Returns the actual transfer amount together with the final crate and depot values.
[
    _actuallyTransferred,
    _crateResult select 1,
    _crateResult select 2,
    _finalStocks select _ressourceIndex,
    _depotCapacity
]
