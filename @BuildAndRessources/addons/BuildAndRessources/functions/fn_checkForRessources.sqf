/*
Checks available ressources depending on the supplied state.
Can display the contents of a single crate, sum nearby ressources,
or check whether enough ressources are available for a building cost.
*/

//Gets the supplied crate list and the current check state.
params ["_crates","_state"];

//Helper function used to display the amount of each ressource type to the player.
BuildAndRessources_fnc_hintRessourceAmount = {
	params ["_ressources","_names","_name"];

	//Formats all configured ressource amounts into a readable hint.
	hint format 
	[
		"Ressources " + _name + ":\n"+(_names select 0)+": %1\n"+(_names select 1)+": %2\n"+(_names select 2)+": %3\n"+(_names select 3)+": %4",
		_ressources select 0,
		_ressources select 1,
		_ressources select 2,
		_ressources select 3,
		_name
	]
};

//Gets the configured names of all ressource types.
_names = BuildAndRessources_names;

//If exactly one crate is supplied and _state is true, display the ressources inside that crate.
if (count _crates == 1 and _state == true) then {
	_ressources = (_crates select 0) getVariable ["BuildAndRessources_ressources",[0,0,0,0]];
	_name = "inside";
	[_ressources,_names,_name] call BuildAndRessources_fnc_hintRessourceAmount;
}else{

	//If _state is false, calculate and display the total amount of ressources nearby.
	if (_state == false) then {

		//Starts with an empty ressource array.
		_ressources = [0,0,0,0];

		//Adds the ressources from every nearby crate to the total amount.
		{
			_ressourcesToAdd = _x getVariable ["BuildAndRessources_ressources", [0,0,0,0]];

			//Adds every individual ressource type to its matching position in the total array.
			for "_i" from 0 to ((count _ressources) - 1) do {
				_ressources set [_i, (_ressources select _i) + (_ressourcesToAdd select _i)];
			};
		}forEach _cratesNearby;
		
		//Tells the player how many ressources are nearby.
		_name = "nearby";
		[_ressources,_names,_name] call BuildAndRessources_fnc_hintRessourceAmount
	}else{

		//Sorts nearby crates by their distance to the player, closest first.
		private _sortedCrates = [_cratesNearby, [player], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;

		//Stores how many ressource crates are currently nearby.
		private _numberOfCratesNearby = count _cratesNearby;

		//Assumes enough ressources are available until one ressource type fails the cost check.
		private _enoughRessources = true;
		
		//Compares every available ressource amount against the corresponding building cost.
		for "_i" from 0 to ((count _ressources) - 1) do {
			if ((_ressources select _i) < (_cost select _i)) then {
				_enoughRessources = false;
			};
		};
		
		//If at least one ressource type is missing, inform the player and mark the check as failed.
		if (_enoughRessources == false) then {
	
			//If no ressource crates are nearby then there are no ressources nearby.
			if (_numberOfCratesNearby == 0) then {
				_ressources = [0,0,0,0];
			};
				
			//Tells the player how many ressources are available and how many are required for the building cost.
			hint format 
			[
				"Not enough ressources!\nRessources needed:\n"+(_names select 0)+": (%1/%2)\n"+(_names select 1)+": (%3/%4)\n"+(_names select 2)+": (%5/%6)\n"+(_names select 3)+": (%7/%8)",
				_ressources select 0,_cost select 0,
				_ressources select 1,_cost select 1,
				_ressources select 2,_cost select 2,
				_ressources select 3,_cost select 3
			];
			
			//Stores the failed ressource check on the player and broadcasts it globally.
			player setVariable ["BuildAndRessources_enoughRessources",false,true];
		}else{

			//Stores the successful ressource check on the player and broadcasts it globally.
			player setVariable ["BuildAndRessources_enoughRessources",true,true];
		};
	};
};
