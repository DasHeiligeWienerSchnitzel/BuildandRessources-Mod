params ["_object","_time","_name","_sortedCrates","_cost"];

//Creates the ACE interaction used to deconstruct the placed object.
_BuildAndRessources_objectDelete = [
	"BuildAndRessources_objectDelete",
	"Remove",
	"",
	{
		//On activation

		params ["_target","_player","_params"];
		_params params ["_time","_name","_sortedCrates","_cost"];

		//Starts the deconstruction animation on the player.
		_player playMove "Acts_carFixingWheel";

		//Starts the ACE progress bar for the deconstruction process.
		[
			_time/2, //Time needed
			[_target,_player,_sortedCrates,_cost],
			{
				//On completion

				params ["_params"];
				_params params ["_target","_player","_sortedCrates","_cost"];

				//Deletes the object and resets the player's animation.
				deleteVehicle _target;
				hint "Deconstruction completed.";
				_player switchMove "Stand";

				//Refunds the configured amount of ressources back into nearby crates.
				_addOrRemove = "add";
				[_sortedCrates,_cost,_addOrRemove] remoteExecCall ["BuildAndRessources_fnc_updateRessources",2];

				//Removes the object from an optional external persistency system if it is available.
				if (!isNil "Persistency_fnc_removeObject") then {
					[_target] remoteExecCall ["Persistency_fnc_removeObject",2];
				};
			},
			{
				//On failure

				params ["_params"];

				//Stops the animation and informs the player that deconstruction was cancelled.
				_player = _params select 1;
				hint "Deconstruction cancelled.";
				_player switchMove "Stand";
			},
			_name + " is being destructed."
		] call ace_common_fnc_progressBar;
	},
	{true},
	{},
	[_time,_name,_sortedCrates,_cost]	//Arguments
] call ace_interact_menu_fnc_createAction;

//Adds the deconstruction interaction to the object's ACE main interaction menu.
[_object, 0, ["ACE_MainActions"], _BuildAndRessources_objectDelete] call ace_interact_menu_fnc_addActionToObject;
