/*
	Adds resources to one valid BuildAndRessources crate.

	This function is deliberately limited to positive values. It returns the
	same result format as fn_changeCrateRessourceAmount:

	[actuallyAdded, newAmount, capacity]
*/

params [
    ["_crate", objNull, [objNull]],
    ["_amount", 0, [0]]
];

if (_amount <= 0) exitWith {
    [0, 0, 0]
};

[_crate, _amount] call BuildAndRessources_fnc_changeCrateRessourceAmount
