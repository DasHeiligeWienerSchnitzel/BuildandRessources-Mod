/*
Toggles the selected object's flatbed state:
- unloaded object: load it onto the nearest compatible flatbed
- loaded object: unload this exact object from its saved flatbed
*/

params [
    ["_object", objNull, [objNull]]
];

//Stops the function immediately if no valid object was supplied.
if (isNull _object) exitWith {};



/*
Keeps all flatbed-related state in one place.
A slot of -1 is used for objects such as the tractor, which occupies
the complete flatbed rather than a crate slot.
*/
private _setFlatbedState = {
    params [
        ["_target", objNull, [objNull]],
        ["_isLoaded", false, [false]],
        ["_flatbed", objNull, [objNull]],
        ["_slot", -1, [0]]
    ];

    //Stores whether the object is currently loaded onto a flatbed.
    _target setVariable ["BuildAndRessources_loadedOnFlatbed", _isLoaded, true];

    //Stores the flatbed this object currently belongs to.
    _target setVariable ["BuildAndRessources_flatbed", _flatbed, true];

    //Stores which crate slot on the flatbed is occupied by this object.
    _target setVariable ["BuildAndRessources_flatbedSlot", _slot, true];
};



/*
    Finds the first unoccupied crate slot. It also assigns slots to crates
    that may have been loaded before the slot variable was introduced.
*/
private _findFirstFreeSlot = {
    params [
        ["_cratePositions", [], [[]]],
        ["_loadedObjects", [], [[]]]
    ];

    //Collects all slot indexes that are already occupied.
    private _occupiedSlots = [];

    //Number of available crate positions on this flatbed type.
    private _slotCount = count _cratePositions;

    {
        //Reads the slot previously assigned to this loaded object.
        private _slot = _x getVariable ["BuildAndRessources_flatbedSlot", -1];

        // Compatibility for already-loaded crates without a saved slot.
        if (_slot < 0 || {_slot >= _slotCount}) then {

            //Looks for the first slot that has not already been claimed.
            for "_candidateSlot" from 0 to (_slotCount - 1) do {
                if !(_candidateSlot in _occupiedSlots) exitWith {
                    _slot = _candidateSlot;
                };
            };

            //Saves the reconstructed slot so future checks can use it directly.
            if (_slot >= 0 && {_slot < _slotCount}) then {
                _x setVariable ["BuildAndRessources_flatbedSlot", _slot, true];
            };
        };

        //Adds the valid slot to the occupied-slot list.
        if (_slot >= 0 && {_slot < _slotCount}) then {
            _occupiedSlots pushBackUnique _slot;
        };
    } forEach _loadedObjects;

    //Defaults to -1, meaning no free slot was found.
    private _freeSlot = -1;

    //Finds the first slot index that is not occupied yet.
    for "_candidateSlot" from 0 to (_slotCount - 1) do {
        if !(_candidateSlot in _occupiedSlots) exitWith {
            _freeSlot = _candidateSlot;
        };
    };

    //Returns the free slot index, or -1 if the flatbed is full.
    _freeSlot
};

//Checks whether the selected object is currently marked as loaded.
private _isLoaded = _object getVariable ["BuildAndRessources_loadedOnFlatbed", false];



/*
    UNLOAD
*/
if (_isLoaded) exitWith {

    //Gets the flatbed the object was loaded onto.
    private _flatbed = _object getVariable ["BuildAndRessources_flatbed", objNull];

    //Stops if the saved flatbed reference is missing or invalid.
    if (isNull _flatbed) exitWith {
        hint "Could not find the flatbed this object belongs to.";
    };

    //Reads the flatbed's loaded-object list and removes references to deleted objects.
    private _objectsLoaded = (_flatbed getVariable ["BuildAndRessources_objectsLoaded", []]) select {
        !isNull _x
    };

    //Finds this exact object inside the flatbed's loaded-object list.
    private _objectIndex = _objectsLoaded find _object;

    //Stops if the object claims to be loaded but is not registered on the flatbed.
    if (_objectIndex isEqualTo -1) exitWith {
        hint "This object is not registered on its flatbed.";
    };

    //Calculates a position eight metres behind the flatbed for unloading.
    private _unloadPosition = [
        position _flatbed,
        8,
        (getDir _flatbed) - 180
    ] call BIS_fnc_relPos;

    /*
        Does not place a resource crate on top of another resource crate (SPACE PROGRAMM! WHUIII!).
    */

    //Searches the unload area for other resource crates that would block unloading.
    private _blockingCrates = (_unloadPosition nearObjects 3.5) select {
        _x != _object
        && {
            getText (
                configFile
                >> "CfgVehicles"
                >> typeOf _x
                >> "BuildAndRessources_ressourceType"
            ) != ""
        }
    };

    //Refuses to unload if another resource crate already occupies the unload position.
    if !(_blockingCrates isEqualTo []) exitWith {
        hint "Unloading obstructed. Move the crate behind the flatbed first.";
    };

    //Temporarily disables simulation so the object can be detached and repositioned safely.
    _object enableSimulationGlobal false;

    //Removes the object from the flatbed attachment.
    detach _object;

    //Places the object slightly above the calculated unload position.
    //Gravity will settle it onto the ground once simulation is enabled again.
    _object setPos [
        _unloadPosition # 0,
        _unloadPosition # 1,
        (_unloadPosition # 2) + 3
    ];

    //Removes the object from the flatbed's registered loaded-object list.
    _objectsLoaded deleteAt _objectIndex;
    _flatbed setVariable ["BuildAndRessources_objectsLoaded", _objectsLoaded, true];

    //Clears all saved flatbed state on the unloaded object.
    [_object, false] call _setFlatbedState;

    //Re-enables physics and simulation after the object has been placed.
    _object enableSimulationGlobal true;

    // Persistency integration, when the optional Persistency mod is present.
    if (!isNil "Persistency_fnc_saveObject") then {
        [[_object]] remoteExecCall ["Persistency_fnc_saveObject", 2];
    };

    hint "Object unloaded from flatbed.";
};



/*
    LOAD
*/

//Reads the configured maximum distance in which a flatbed can be used.
private _loadDistance = missionNamespace getVariable ["BuildAndRessources_loadDistance", 15];

/*
Format:
[
    vehicle classname,
    [
        attachment position for first crate,
        attachment position for second crate
    ]
]
*/
private _flatbedDefinitions = [
    // Vanilla HEMTT flatbeds
    [
        "B_T_Truck_01_flatbed_F",
        [
            [0, -0.2, 0.54],
            [0, -3.4, 0.54]
        ]
    ],
    [
        "B_Truck_01_flatbed_F",
        [
            [0, -0.2, 0.54],
            [0, -3.4, 0.54]
        ]
    ],

    // Optional UK3CB HX58 flatbeds
    [
        "UK3CB_BAF_MAN_HX58_Cargo_Green_A",
        [
            [0, 3.8, 0.15],
            [0, 0.6, 0.15]
        ]
    ],
    [
        "UK3CB_BAF_MAN_HX58_Cargo_Sand_A",
        [
            [0, 3.8, 0.15],
            [0, 0.6, 0.15]
        ]
    ]
] select {
    // Keeps UK3CB optional instead of requiring it in requiredAddons[].
    isClass (configFile >> "CfgVehicles" >> (_x # 0))
};

//Stops if none of the supported flatbed classes exist in the current mod setup.
if (_flatbedDefinitions isEqualTo []) exitWith {
    hint "No supported flatbed classes are available.";
};

//Extracts only the vehicle classnames from the flatbed definitions.
private _flatbedClasses = _flatbedDefinitions apply { _x # 0 };

//Finds all supported flatbeds close enough to the selected object.
private _nearbyFlatbeds = nearestObjects [_object, _flatbedClasses, _loadDistance];

//Uses the nearest supported flatbed found.
private _nearestFlatbed = _nearbyFlatbeds param [0, objNull];

//Stops if no compatible flatbed is within loading distance.
if (isNull _nearestFlatbed) exitWith {
    hint format ["No supported flatbed found within %1 metres.", _loadDistance];
};

//Finds the matching flatbed definition containing the attachment positions for this vehicle type.
private _flatbedDefinition = (_flatbedDefinitions select {
    (_x # 0) isEqualTo typeOf _nearestFlatbed
}) param [0, []];

//Stops if no position definition could be found for the detected flatbed.
if (_flatbedDefinition isEqualTo []) exitWith {
    hint "Could not find loading-position data for this flatbed.";
};

//Reads the available crate attachment positions for this specific flatbed.
private _cratePositions = _flatbedDefinition # 1;

//Reads the objects currently registered as loaded and removes deleted references.
private _objectsLoaded = (_nearestFlatbed getVariable ["BuildAndRessources_objectsLoaded", []]) select {
    !isNull _x
};

// Remove references to deleted objects from the truck's state array.
_nearestFlatbed setVariable ["BuildAndRessources_objectsLoaded", _objectsLoaded, true];

/*
    A tractor occupies the complete flatbed and cannot share it with crates.
*/

//Checks whether the object currently being loaded is a tractor.
private _isTractor = _object isKindOf "C_Tractor_01_F";

//Checks whether a tractor is already loaded on this flatbed.
private _tractorLoaded = _objectsLoaded findIf {
    _x isKindOf "C_Tractor_01_F"
};

//Handles tractor loading separately because it occupies the entire flatbed.
if (_isTractor) exitWith {

    //A tractor can only be loaded when the flatbed is completely empty.
    if !(_objectsLoaded isEqualTo []) exitWith {
        hint "Tractor cannot be loaded. No space on flatbed.";
    };

    //Registers the tractor as loaded on the flatbed.
    _objectsLoaded pushBack _object;
    _nearestFlatbed setVariable ["BuildAndRessources_objectsLoaded", _objectsLoaded, true];

    //Attaches the tractor to its dedicated flatbed position and orientation.
    _object attachTo [_nearestFlatbed, [0, 1, 0.6]];
    _object setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];

    //Stores the flatbed state. No crate slot is used, so the default slot remains -1.
    [_object, true, _nearestFlatbed] call _setFlatbedState;

    hint "Tractor loaded onto flatbed.";
};

//Prevents crates or other objects from being loaded while a tractor occupies the flatbed.
if (_tractorLoaded >= 0) exitWith {
    hint "Flatbed is occupied by a tractor.";
};

//Finds the first available crate slot on the selected flatbed.
private _slotIndex = [_cratePositions, _objectsLoaded] call _findFirstFreeSlot;

//Stops if all available crate slots are already occupied.
if (_slotIndex isEqualTo -1) exitWith {
    hint "Flatbed already full.";
};

//Gets the attachment position belonging to the selected free slot.
private _attachPosition = _cratePositions # _slotIndex;

//Registers the object in the flatbed's loaded-object list.
_objectsLoaded pushBack _object;
_nearestFlatbed setVariable ["BuildAndRessources_objectsLoaded", _objectsLoaded, true];

//Attaches the object to the selected position on the flatbed.
_object attachTo [_nearestFlatbed, _attachPosition];

//Rotates the attached object so it is aligned correctly with the flatbed.
_object setDir ((_nearestFlatbed getRelDir _object) - 90);

//Saves the loaded state, flatbed reference and occupied slot on the object.
[_object, true, _nearestFlatbed, _slotIndex] call _setFlatbedState;

hint "Object loaded onto flatbed.";
