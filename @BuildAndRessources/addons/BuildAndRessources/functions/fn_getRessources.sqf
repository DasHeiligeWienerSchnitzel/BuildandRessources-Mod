params ["_crate"];

//Returns an empty resource array if no valid crate was supplied.
if (isNull _crate) exitWith
{
    [0, 0, 0, 0]
};

//Checks whether this crate already has a stored runtime resource array.
private _ressources = _crate getVariable [
    "BuildAndRessources_ressources",
    []
];

//Returns the stored resources immediately if the crate has already been initialized.
if !(_ressources isEqualTo []) exitWith
{
    _ressources
};

//Reads the resource type configured for this crate.
private _crateConfig = configOf _crate;

private _ressourceType = getText (
    _crateConfig >> "BuildAndRessources_ressourceType"
);

//Finds the resource type's index in the global resource order.
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

//Stops if the crate uses an unknown resource type.
if (_ressourceIndex < 0) exitWith
{
    diag_log format [
        "BuildAndRessources: Unknown resource type '%1' on crate %2.",
        _ressourceType,
        typeOf _crate
    ];

    [0, 0, 0, 0]
};

//Gets the current globally configured capacity for this crate type.
private _capacity = [_crate] call BuildAndRessources_fnc_getCrateCapacity;



// -1 is the Eden default: start completely full.
// Any value of 0 or higher is a per-crate initial amount override.
private _editorInitialAmount = _crate getVariable [
    "BuildAndRessources_CrateAmount",
    -1
];

//Converts non-numeric Eden values into a number for safety.
if !(_editorInitialAmount isEqualType 0) then
{
    _editorInitialAmount = parseNumber str _editorInitialAmount;
};

//Uses a full crate as the default initial amount.
private _initialAmount = _capacity;

//If Eden specifies an explicit amount, clamps it between zero and the crate capacity.
if (_editorInitialAmount >= 0) then
{
    _initialAmount = round ((_editorInitialAmount max 0) min _capacity);
};



//Turns the crate's resource type and initial amount into the shared resource-array format.
_ressources = [0, 0, 0, 0];
_ressources set [_ressourceIndex, _initialAmount];



//Stores the initialized resource array as changing mission state on this placed crate.
_crate setVariable [
    "BuildAndRessources_ressources",
    _ressources,
    true
];

//Returns the crate's current resource array.
_ressources
