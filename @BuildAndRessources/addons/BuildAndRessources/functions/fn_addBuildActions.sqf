/*
	This script adds the new ace interaction points that enables the player to build pre determined structures 
	through the Classnames List. Found in the ER32_Classnames.sqf file.
*/

params ["_unit"];

//Failsafe if the unit doesnt exist.
if (isNull _unit) exitWith {};

//Only adds the ace interaction points if it wasnt already done.
if (_unit getVariable ["BuildAndRessources_buildActionsAdded", false]) exitWith {};
_unit setVariable ["BuildAndRessources_buildActionsAdded", true];

//Initialization of some variables.
private _classname_list = BuildAndRessources_classnameList; //This contains all the buildables.
private _maxHeight = BuildAndRessources_maxHeight;
private _minHeight = BuildAndRessources_minHeight;

/*
Creates the first interaction point in the main ace self interaction menu.
Will only be shown if the player has a ace-fortify item in his/her inventory.
*/
_BuildAndRessources_mainCategory = [
	"BuildAndRessources_buildCategory",
	"Build",
	"",
	{true},
	{
		("ACE_Fortify" in (items player)) and (player == vehicle player)
	}
] call ace_interact_menu_fnc_createAction;
[_unit, 1, ["ACE_SelfActions"], _BuildAndRessources_mainCategory] call ace_interact_menu_fnc_addActionToObject;

//Gets all the categories written in the "ER32_Classnames.sqf".
_categoryList = [];
{
	_categoryList pushBack (_x select 3);
}forEach _classname_list;

//Deletes all duplicate categories.
_categoryList = _categoryList arrayIntersect _categoryList;

//Creates the ACE Self Interaction Points based on the categories.
{
	_categories = ["BuildAndRessources_categories" + _x, _x, "", {true}, {true}] call ace_interact_menu_fnc_createAction;
	[_unit, 1, ["ACE_SelfActions","BuildAndRessources_buildCategory"], _categories] call ace_interact_menu_fnc_addActionToObject;
}forEach _categoryList;

//Fills the created categories with the corresponding elements.
{
	_class = _x select 0;
	_ressources = _x select 1;
	_name = (_x select 2) + " " + str(_ressources);
	_category = _x select 3;
	_time = _x select 4;
	
	_newCategory = [
		_name,
		_name,
		"",
		{
			params ["_target","_player","_params"];
			_params params ["_class","_ressources","_name","_time","_maxHeight","_minHeight"];
			[_class,_ressources,_name,_time,_player,_maxHeight,_minHeight] remoteExec ["BuildAndRessources_fnc_placeObject",_player];
		},
		{true},
		{},
		[_class,_ressources,_name,_time,_maxHeight,_minHeight]
	] call ace_interact_menu_fnc_createAction;
		
	[
		_unit,
		1,
		["ACE_SelfActions","BuildAndRessources_buildCategory","BuildAndRessources_categories" + _category],
		_newCategory
	] call ace_interact_menu_fnc_addActionToObject;
} forEach _classname_list;

//Adds ACE Self Interaction to check nearby crates on ressource count.
_BuildAndRessources_ressources = [
	"BuildAndRessources_ressources",
	"Check for ressources",
	"",
	{
		
		params ["_target","_player","_params"];
		_crates = BuildAndRessources_crates;
		_names = BuildAndRessources_names;
		
		//Gets all the valid crates in a 50 meter radius around the player.
		
		_cratesNearby = _player nearEntities [_crates,50];
		
		_ressources = [0,0,0,0];
		{
			_ressourcesToAdd = _x getVariable ["BuildAndRessources_ressources", [0,0,0,0]];
			for "_i" from 0 to ((count _ressources) - 1) do {
				_ressources set [_i, (_ressources select _i) + (_ressourcesToAdd select _i)];
			};
		}forEach _cratesNearby;
		
		hint format 
		[
			"Ressources nearby:\n"+(_names select 0)+": %1\n"+(_names select 1)+": %2\n"+(_names select 2)+": %3\n"+(_names select 3)+": %4",
			_ressources select 0,
			_ressources select 1,
			_ressources select 2,
			_ressources select 3
		]
	},
	{true},
	{}
	] call ace_interact_menu_fnc_createAction;
[_unit, 1, ["ACE_SelfActions","BuildAndRessources_buildCategory"], _BuildAndRessources_ressources] call ace_interact_menu_fnc_addActionToObject;
