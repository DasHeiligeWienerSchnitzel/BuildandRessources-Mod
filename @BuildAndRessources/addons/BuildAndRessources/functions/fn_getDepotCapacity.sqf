/*
Returns the globally configured finite capacity for a given resource type
inside a Ressource Depot.
*/

params [
    ["_depot", objNull, [objNull]],
    ["_ressourceType", "", [""]]
];

//Stops the function if no valid depot was supplied.
if (isNull _depot) exitWith { 0 };

//Reads the depot's config-defined fallback capacity.
private _fallback = getNumber (configOf _depot >> "BuildAndRessources_depotCapacityFallback");

//Maps the requested resource type to the corresponding global CBA setting.
private _settingName = switch (_ressourceType) do {
    case "Concrete": { "BuildAndRessources_maxConcreteDepotAmount" };
    case "Wood":     { "BuildAndRessources_maxWoodDepotAmount" };
    case "Sand":     { "BuildAndRessources_maxSandDepotAmount" };
    case "Metal":    { "BuildAndRessources_maxMetalDepotAmount" };
    default           { "" };
};

//Falls back to the depot config value if an unknown resource type was requested.
if (_settingName isEqualTo "") exitWith {
    diag_log format [
        "BuildAndRessources: Unknown depot resource type '%1'.",
        _ressourceType
    ];

    _fallback max 0
};

//Reads the globally configured depot capacity, using the config fallback if needed.
private _capacity = missionNamespace getVariable [_settingName,_fallback];

//Converts non-numeric setting values into a number for safety.
if !(_capacity isEqualType 0) then {
    _capacity = parseNumber str _capacity;
};

//Returns a rounded capacity and prevents negative values.
(round _capacity) max 0
