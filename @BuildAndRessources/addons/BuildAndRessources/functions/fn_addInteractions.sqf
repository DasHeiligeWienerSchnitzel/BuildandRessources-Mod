/*
Creates an ace interaction point to check for ressources inside the crate.
*/

params ["_crate"];

if (isNull _crate) exitWith {};

_BuildAndRessources_ressources = [
	"ER32_buildAndRessources_ressources",
	"Check for Ressource inside",
	"",
	{
		params ["_target","_player","_params"];
		_params params ["_crate"];
		[[_crate],true] call BuildAndRessources_fnc_checkForRessources;
	},
	{true},
	{},
	[_crate]
	] call ace_interact_menu_fnc_createAction;
[_crate, 0, ["ACE_MainActions"], _BuildAndRessources_ressources] call ace_interact_menu_fnc_addActionToObject;
