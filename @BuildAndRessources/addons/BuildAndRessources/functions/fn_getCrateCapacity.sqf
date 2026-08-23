/*
Returns the current globally configured capacity for this crate type.
The config value is only a fallback in case the CBA setting is unavailable.
*/

params [
    ["_crate", objNull, [objNull]]
];

//Stops the function if no valid crate was supplied.
if (isNull _crate) exitWith { 0 };

//Reads the resource type configured for this crate.
private _crateConfig = configOf _crate;
private _ressourceType = getText (
    _crateConfig >> "BuildAndRessources_ressourceType"
);

//Reads the crate's config-defined resource amount as a fallback capacity.
private _fallback = getNumber (
    _crateConfig >> "BuildAndRessources_ressourceAmount"
);

//Maps the crate's resource type to the corresponding global CBA setting.
private _settingName = switch (_ressourceType) do {
    case "Concrete": { "BuildAndRessources_maxConcreteCrateAmount" };
    case "Wood":     { "BuildAndRessources_maxWoodCrateAmount" };
    case "Sand":     { "BuildAndRessources_maxSandCrateAmount" };
    case "Metal":    { "BuildAndRessources_maxMetalCrateAmount" };
    default           { "" };
};

//Falls back to the config value if the crate uses an unknown resource type.
if (_settingName isEqualTo "") exitWith {
    diag_log format [
        "BuildAndRessources: Unknown resource type '%1' on crate %2.",
        _ressourceType,
        typeOf _crate
    ];

    _fallback max 0
};

//Reads the current globally configured capacity, falling back to the config value if necessary.
private _capacity = missionNamespace getVariable [_settingName,_fallback];

//Converts non-numeric setting values into a number for safety.
if !(_capacity isEqualType 0) then {
    _capacity = parseNumber str _capacity;
};

//Returns a rounded capacity and prevents negative values.
(round _capacity) max 0
