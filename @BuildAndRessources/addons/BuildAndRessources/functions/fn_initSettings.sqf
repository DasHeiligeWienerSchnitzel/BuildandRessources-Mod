/*
	This file initialises the CBA Settings
	
	!!ALL THESE SETTINGS CAN BE CHANGED IN THE CBA SETTINGS INGAME. NO NEED TO CHANGE IT HERE!!
*/

private _crateCategory = ["Build and Ressources", "Crate capacities"];

/*
This setting controls the maximum amount a concrete crate can hold.
*/
[
    "BuildAndRessources_maxConcreteCrateAmount",
    "SLIDER",
    ["Concrete crate capacity", "Maximum resources a Concrete crate can hold."],
    _crateCategory,
    [0, 10000, 1000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;

/*
And this how much a wooden crate can hold.
*/
[
    "BuildAndRessources_maxWoodCrateAmount",
    "SLIDER",
    ["Wood crate capacity", "Maximum resources a Wood crate can hold."],
    _crateCategory,
    [0, 10000, 1000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;

/*
And so on...
*/
[
    "BuildAndRessources_maxSandCrateAmount",
    "SLIDER",
    ["Sand crate capacity", "Maximum resources a Sand crate can hold."],
    _crateCategory,
    [0, 10000, 1000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;

[
    "BuildAndRessources_maxMetalCrateAmount",
    "SLIDER",
    ["Metal crate capacity", "Maximum resources a Metal crate can hold."],
    _crateCategory,
    [0, 10000, 1000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;

private _gameplayCategory = ["Build and Ressources", "Gameplay"];

[
    "BuildAndRessources_disableBuildCosts",
    "CHECKBOX",
    [
        "Disable building costs",
        "When enabled, structures can be built without nearby resources. Building consumes no crate resources, and deconstruction returns no resources."
    ],
    _gameplayCategory,
    false,
    2,
    {},
    true
] call CBA_fnc_addSetting;

private _depotCategory = ["Build and Ressources", "Depot capacities"];

[
    "BuildAndRessources_maxConcreteDepotAmount",
    "SLIDER",
    ["Concrete depot capacity", "Maximum finite Concrete stock one Ressource Depot can store. -1 in the Eden initial-stock field creates an infinite stock instead."],
    _depotCategory,
    [0, 100000, 5000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;

[
    "BuildAndRessources_maxWoodDepotAmount",
    "SLIDER",
    ["Wood depot capacity", "Maximum finite Wood stock one Ressource Depot can store. -1 in the Eden initial-stock field creates an infinite stock instead."],
    _depotCategory,
    [0, 100000, 5000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;

[
    "BuildAndRessources_maxSandDepotAmount",
    "SLIDER",
    ["Sand depot capacity", "Maximum finite Sand stock one Ressource Depot can store. -1 in the Eden initial-stock field creates an infinite stock instead."],
    _depotCategory,
    [0, 100000, 5000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;

[
    "BuildAndRessources_maxMetalDepotAmount",
    "SLIDER",
    ["Metal depot capacity", "Maximum finite Metal stock one Ressource Depot can store. -1 in the Eden initial-stock field creates an infinite stock instead."],
    _depotCategory,
    [0, 100000, 5000, 0],
    2,
    {},
    true
] call CBA_fnc_addSetting;
