/*
	General BuildAndRessources setup.
	
	CBA settings are registered separately in fn_initSettings.sqf via the
	xtended_PreInit_EventHandlers entry in config.cpp.
*/

/*
Gets the defaultBuildables from the same named file. 
This variable-list can be easily overwritten in every mission file by just calling the same line below with a different buildables.sqf.
The mod just needs some defaultBuildables so this is a very barebone list ment to show whats possible. It is encourage to change the list and
use your own buildables.
*/
BuildAndRessources_classnameList = call compile preprocessFileLineNumbers "\BuildAndRessources\functions\config\defaultBuildables.sqf";

//These are the four ressource types. 
BuildAndRessources_names = ["Concrete", "Wood", "Sand", "Metal"];

//And these are the four Ressource Crates four the ressourcy types.
BuildAndRessources_crates = [
    "RessourceCrate_Concrete",
    "RessourceCrate_Wood",
    "RessourceCrate_Sand",
    "RessourceCrate_Metal"
];

// Compatibility fallback only. Capacity-dependent code reads the CBA setting
// via BuildAndRessources_fnc_getCrateCapacity.
BuildAndRessources_startResources = [1000, 1000, 1000, 1000];

BuildAndRessources_loadDistance = 15;
BuildAndRessources_maxHeight = 10;
BuildAndRessources_minHeight = -10;
