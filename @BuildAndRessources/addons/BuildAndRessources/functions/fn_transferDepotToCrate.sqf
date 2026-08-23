/*
Transfers as much of the crate's resource type as possible from a depot
into a nearby compatible resource crate.

This function is server-side only and may be safely requested by a client
through remoteExecCall. The server rechecks compatibility, distance and the
remote caller's position before changing any stock.

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

    _remoteRequestValid = !isNull _caller && { (_caller distance _depot) <= 10 || {(_caller distance _crate) <= 10} };
};

//Rejects invalid or suspicious remote transfer requests.
if (!_remoteRequestValid) exitWith { [0, 0, 0, 0, 0] };

//Rechecks on the server whether this depot is actually a valid withdraw target for the crate.
private _validatedDepot = [_crate, "withdraw"] call BuildAndRessources_fnc_findNearbyDepot;

if !(_validatedDepot isEqualTo _depot) exitWith { [0, 0, 0, 0, 0] };

//Reads the crate's resource type and its index in the global resource array.
private _ressourceType = getText (configOf _crate >> "BuildAndRessources_ressourceType");
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

//Stops if the crate uses an unknown resource type.
if (_ressourceIndex < 0) exitWith { [0, 0, 0, 0, 0] };

//Makes sure the depot has its persistent runtime stock initialized before changing it.
[_depot] call BuildAndRessources_fnc_initializeDepot;

//Reads the crate's current amount, capacity and how much is still missing.
private _crateRessources = [_crate] call BuildAndRessources_fnc_getRessources;
private _crateAmount = _crateRessources select _ressourceIndex;
private _crateCapacity = [_crate] call BuildAndRessources_fnc_getCrateCapacity;
private _missingAmount = (_crateCapacity - _crateAmount) max 0;

//Stops immediately if the crate is already full.
if (_missingAmount <= 0) exitWith { [0, _crateAmount, _crateCapacity, 0, 0] };

//Reads the depot's current stock and configured finite capacity.
private _depotStocks = [_depot] call BuildAndRessources_fnc_getDepotStock;
private _depotAmount = _depotStocks select _ressourceIndex;
private _depotCapacity = [_depot, _ressourceType] call BuildAndRessources_fnc_getDepotCapacity;

//Infinite depot stocks do not need to be reduced, so the crate can simply be filled directly.
if (_depotAmount isEqualTo -1) exitWith {
    private _crateResult = [_crate,_missingAmount] call BuildAndRessources_fnc_addRessourcesToCrate;

    [
        _crateResult select 0,
        _crateResult select 1,
        _crateResult select 2,
        -1,
        -1
    ]
};

//Limits the requested transfer to whichever is smaller: the crate's missing amount or depot stock.
private _requestedTransfer = _missingAmount min _depotAmount;

//Stops if the depot cannot provide any resource.
if (_requestedTransfer <= 0) exitWith {[0, _crateAmount, _crateCapacity, _depotAmount, _depotCapacity]};

//Removes the requested amount from the depot first.
private _depotResult = [ _depot, _ressourceType, -_requestedTransfer] call BuildAndRessources_fnc_changeDepotRessourceAmount;

//Converts the depot-side negative change into a positive withdrawn amount.
private _actuallyWithdrawn = -(_depotResult select 0);

//Adds the withdrawn amount to the crate.
private _crateResult = [ _crate, _actuallyWithdrawn] call BuildAndRessources_fnc_addRessourcesToCrate;

//Reads how much the crate actually accepted.
private _actuallyTransferred = _crateResult select 0;

// This should only ever restore stock if a capacity changed unexpectedly.
if (_actuallyTransferred < _actuallyWithdrawn) then {
    [ _depot, _ressourceType, _actuallyWithdrawn - _actuallyTransferred] call BuildAndRessources_fnc_changeDepotRessourceAmount;
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
