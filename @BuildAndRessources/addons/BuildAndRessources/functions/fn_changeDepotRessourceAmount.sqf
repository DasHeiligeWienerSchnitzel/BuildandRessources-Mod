/*
	Central server-side write function for Ressource Depot stock.

	Positive delta: store resources in the depot.
	Negative delta: remove resources from the depot.

	Return value:
	[actualChange, newAmount, capacity]

	Infinite stock is represented by -1. Removing from it returns the requested
	negative change while leaving the stock at -1. Depositing into it returns 0
	because depositing into infinity would silently destroy resources.
*/

params [
    ["_depot", objNull, [objNull]],
    ["_ressourceType", "", [""]],
    ["_delta", 0, [0]]
];

//This function is only allowed to change depot ressources on the server.
if (!isServer) exitWith {
    diag_log "BuildAndRessources: changeDepotRessourceAmount must run on the server.";
    [0, 0, 0]
};

//Stops if no valid depot object was provided.
if (isNull _depot) exitWith { [0, 0, 0] };

//Checks whether the given object is actually configured as a Ressource Depot.
if ((getNumber (configOf _depot >> "BuildAndRessources_isRessourceDepot")) <= 0) exitWith {[0, 0, 0]};

//Finds the index of the requested ressource type in the global ressource list.
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

//Stops if an unknown ressource type was passed to the function.
if (_ressourceIndex < 0) exitWith {
    diag_log format ["BuildAndRessources: Tried to change unknown depot resource type '%1'.",_ressourceType];
    [0, 0, 0]
};

//Checks whether this ressource type is enabled for the depot.
private _enabled = _depot getVariable [format ["BuildAndRessources_depot%1Enabled", _ressourceType],true];

//Converts older/non-boolean values into a proper boolean value if necessary.
if !(_enabled isEqualType true) then {
    _enabled = _enabled in [1, "1", "true", "TRUE"];
};

//Disabled ressource types cannot be changed.
if (!_enabled) exitWith { [0, 0, 0] };

//Makes sure the depot stock variables exist before trying to access them.
[_depot] call BuildAndRessources_fnc_initializeDepot;

//Gets the current stock array of the depot.
private _stocks = _depot getVariable ["BuildAndRessources_depotStocks",[0, 0, 0, 0]];

//Gets the current amount and maximum capacity of the selected ressource type.
private _currentAmount = _stocks select _ressourceIndex;
private _capacity = [_depot, _ressourceType] call BuildAndRessources_fnc_getDepotCapacity;

//Only whole ressources can be added or removed.
_delta = round _delta;

//A stock value of -1 means that this ressource type has infinite stock.
if (_currentAmount isEqualTo -1) exitWith {
    if (_delta < 0) then
    {
        //Removing from infinite stock succeeds without changing the stored value.
        [_delta, -1, -1]
    }
    else
    {
        //Depositing into infinite stock is rejected so ressources are not destroyed.
        [0, -1, -1]
    }
};

//Calculates the new amount and clamps it between empty and the depot capacity.
private _newAmount = ((_currentAmount + _delta) max 0) min _capacity;
private _actualChange = _newAmount - _currentAmount;

//Updates and broadcasts the stock variable if something actually changed.
if (_actualChange != 0) then {
    _stocks set [_ressourceIndex, _newAmount];

    _depot setVariable [
        "BuildAndRessources_depotStocks",
        _stocks,
        true
    ];
};

//Returns how much actually changed, the new amount and the maximum capacity.
[_actualChange, _newAmount, _capacity]
