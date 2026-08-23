/*
Checks the amount of ressources inside a crate and hints the amount.
*/

params ["_crate", "_player"];

//Checks if the crate and player still exist, otherwise end script here.
if (isNull _crate || {isNull _player}) exitWith {};

//Get config of the crate.
private _config = configOf _crate;

//Get ressource type.
private _ressourceType = getText (_config >> "BuildAndRessources_ressourceType");
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

if (_ressourceIndex < 0) exitWith {
    hint "Unknown resource crate type.";
};

//Get ressources inside the crate
private _ressources = [_crate] call BuildAndRessources_fnc_getRessources;

//Checks the current amount inside the crate.
private _currentAmount = _ressources select _ressourceIndex;
//And the Capacity.
private _capacity = [_crate] call BuildAndRessources_fnc_getCrateCapacity;

//And hints it.
hint format ["%1 available: %2 / %3",_ressourceType,_currentAmount,_capacity];
