/*
Returns the current depot-stock array in the normal resource order:
[Concrete, Wood, Sand, Metal].

-1 means an enabled infinite resource stock.
0 or higher is a finite stock amount.

Before a depot is first used, this function derives the initial array from
its Eden attributes without writing mission state. The server writes that
same array when fn_initializeDepot is called.
*/

params [["_depot", objNull, [objNull]]];

//Returns an empty stock array if no valid depot was supplied.
if (isNull _depot) exitWith { [0, 0, 0, 0] };

//Rejects objects that are not configured as BuildAndRessources depots.
if ((getNumber (configOf _depot >> "BuildAndRessources_isRessourceDepot")) <= 0) exitWith {[0, 0, 0, 0]};

//Checks whether this depot already has a stored runtime stock array.
private _storedStocks = _depot getVariable ["BuildAndRessources_depotStocks",[]];

//Returns the stored stock immediately if it already contains all four resource values.
if ((count _storedStocks) isEqualTo 4) exitWith {_storedStocks};

//Creates a new stock array from the depot's Eden/config settings.
private _stocks = [];

{
    private _ressourceType = _x;

    //Checks whether this resource type is enabled for the depot.
    private _enabled = _depot getVariable [format ["BuildAndRessources_depot%1Enabled", _ressourceType],true];

    //Converts non-boolean Eden values into a boolean for safety.
    if !(_enabled isEqualType true) then {
        _enabled = _enabled in [1, "1", "true", "TRUE"];
    };

    //Disabled resource types always start with zero stock.
    if (!_enabled) then {
        _stocks pushBack 0;
        continue;
    };

    //Reads the configured initial amount for this resource type.
    private _initialAmount = _depot getVariable [format ["BuildAndRessources_depot%1Initial", _ressourceType], -2];

    //Converts non-numeric Eden values into a number for safety.
    if !(_initialAmount isEqualType 0) then {
        _initialAmount = parseNumber str _initialAmount;
    };

    //Gets the currently configured maximum capacity for this resource type.
    private _capacity = [_depot, _ressourceType] call BuildAndRessources_fnc_getDepotCapacity;

    //Converts the Eden initial-value mode into an actual stock amount.
    private _stock = switch (round _initialAmount) do{
        case -1: { -1 };          // Infinite stock.
        case -2: { _capacity };   // Start full at CBA capacity.
        default { ((round _initialAmount) max 0) min _capacity };
    };

    //Adds the calculated stock value in the normal global resource order.
    _stocks pushBack _stock;
} forEach BuildAndRessources_names;

//Returns the complete depot stock array.
_stocks
