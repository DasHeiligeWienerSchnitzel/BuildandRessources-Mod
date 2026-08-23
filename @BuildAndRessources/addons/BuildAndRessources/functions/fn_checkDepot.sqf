/*
    Displays the currently configured depot stocks for the interacting player.
*/

//Gets the depot and the player interacting with it.
params [
    ["_depot", objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

//Stops the function if either the depot or the player is invalid.
if (isNull _depot || {isNull _player}) exitWith {};

//Makes sure the selected object is actually configured as a ressource depot.
if ((getNumber (configOf _depot >> "BuildAndRessources_isRessourceDepot")) <= 0) exitWith {hint "Unknown resource depot.";};

//Gets the current stock values of all configured ressource types.
private _stocks = [_depot] call BuildAndRessources_fnc_getDepotStock;

//Creates the text array that will later be shown to the player.
private _lines = ["Ressource Depot"];

//Checks every configured ressource type and adds its current state to the display text.
{
    private _ressourceType = _x;
    private _index = _forEachIndex;

    //Checks whether this ressource type is enabled for the depot.
    private _enabled = _depot getVariable [format ["BuildAndRessources_depot%1Enabled",_ressourceType],true];

    //Converts older/non-boolean values into a proper boolean if necessary.
    if !(_enabled isEqualType true) then {
        _enabled = _enabled in [1, "1", "true", "TRUE"];
    };

    //Shows disabled ressources without checking their stock or capacity.
    if (!_enabled) then {
        _lines pushBack format ["%1: disabled", _ressourceType];
        continue;
    };

    //Gets the stored amount for the current ressource type.
    private _stock = _stocks select _index;

    //A stock value of -1 represents an infinite amount of this ressource.
    if (_stock isEqualTo -1) then {
        _lines pushBack format ["%1: infinite", _ressourceType];
    }else{
        //Gets the depot capacity and displays the current amount together with its maximum.
        private _capacity = [_depot, _ressourceType] call BuildAndRessources_fnc_getDepotCapacity;
        _lines pushBack format ["%1: %2 / %3", _ressourceType, _stock, _capacity];
    };
} forEach BuildAndRessources_names;

//Combines all lines and shows the finished depot overview to the player.
hint (_lines joinString "\n");
