params ["_class","_cost","_name","_time","_caller","_maxHeight","_minHeight"];

//Reads whether building costs are globally disabled through the addon settings.
private _buildCostsDisabled = missionNamespace getVariable [
    "BuildAndRessources_disableBuildCosts",
    false
];

////////////////////
// RESOURCE CHECK //
////////////////////

//Gets all configured resource-crate classnames and finds matching crates near the player.
private _crates = BuildAndRessources_crates;
private _cratesNearby = _caller nearEntities [_crates,50];

//Sorts nearby crates by distance so the closest ones are used first when resources are removed.
private _sortedCrates = [_cratesNearby, [_caller], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;

//Collects the resources stored inside all nearby crates.
private _enoughRessources = true;
private _ressources = [0,0,0,0];

{
    //Reads this crate's current resource array.
    private _ressourcesToAdd = [_x] call BuildAndRessources_fnc_getRessources;

    //Adds each resource type into the combined nearby-resource total.
    for "_i" from 0 to ((count _ressources) - 1) do
    {
        _ressources set [
            _i,
            (_ressources select _i) + (_ressourcesToAdd select _i)
        ];
    };
} forEach _cratesNearby;

//Only checks the actual construction costs when free building is disabled.
if (!_buildCostsDisabled) then {

    //Compares the available amount of every resource type against the object's cost.
    for "_i" from 0 to ((count _ressources) - 1) do {
        if ((_ressources select _i) < (_cost select _i)) then {
            _enoughRessources = false;
        };
    };
};

//Stops placement and shows the missing-resource overview if the player cannot afford the object.
if (!_buildCostsDisabled && {!_enoughRessources}) exitWith {
    private _names = BuildAndRessources_names;

    hint format 
    [
        "Not enough ressources!\nRessources needed:\n"+(_names select 0)+": (%1/%2)\n"+(_names select 1)+": (%3/%4)\n"+(_names select 2)+": (%5/%6)\n"+(_names select 3)+": (%7/%8)",
        _ressources select 0,_cost select 0,
        _ressources select 1,_cost select 1,
        _ressources select 2,_cost select 2,
        _ressources select 3,_cost select 3
    ];
};

/////////////////////
//	PREVIEW MODE   //
/////////////////////

//Creates the selected object far below the map before moving it into preview position.
private _previewObject = createVehicle [_class, [0,0,-1000], [], 0, "CAN_COLLIDE"];

//Uses the object's configured size to determine a sensible default placement distance.
private _sizeOfObject = sizeOf _class;

private _minDistance = 3;
private _maxDistance = 20;

//Clamps the default placement distance between the configured minimum and maximum.
private _distance = (_sizeOfObject - 5) max _minDistance;
_distance = _distance min _maxDistance;

//Calculates the initial world position directly in front of the player.
private _relPosToCaller = [position _caller, _distance, getDir _caller] call BIS_fnc_relPos;

//Moves, rotates and attaches the preview object to the player.
_previewObject setPos _relPosToCaller;
_previewObject setDir (getDir _caller);
_previewObject attachTo [_caller, [0, _distance, 0]];

//Stores the current placement distance on the preview object for the event handlers.
_previewObject setVariable ["BuildAndRessources_distance", _distance];

//Prevents the player from starting ladder animations while placement mode is active.
_eventHandler = _caller addEventHandler ["AnimChanged", {
    params ["_unit", "_anim"];

    if (_anim find "ladder" > -1) then {
        _unit switchMove ""; // instantly cancel climbing
    };
}];

/////////////////////
//	EVENTHANDLERS  //
/////////////////////

//Tracks whether CTRL or SHIFT are currently held down.
_keyDownHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    //CTRL enables rotation with the mouse wheel.
    if (_key == 29) then
    {
        _display setVariable ["BuildAndRessources_ctrlDown", true];
    };

    //Either SHIFT key enables distance adjustment with the mouse wheel.
    if (_key in [42, 54]) then
    {
        _display setVariable ["BuildAndRessources_shiftDown", true];
    };
}];

//Clears the stored modifier-key states when the corresponding key is released.
_keyUpHandler = (findDisplay 46) displayAddEventHandler ["KeyUp", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];

    if (_key == 29) then
    {
        _display setVariable ["BuildAndRessources_ctrlDown", false];
    };

    if (_key in [42, 54]) then
    {
        _display setVariable ["BuildAndRessources_shiftDown", false];
    };
}];

//Uses the mouse wheel to rotate, change distance or adjust height depending on modifier keys.
_mouseWheelChangeHandler = (findDisplay 46) displayAddEventHandler ["MouseZChanged", {
    params ["_display", "_scroll"];

    //Reads the current modifier-key states and preview object from the display namespace.
    private _ctrl = _display getVariable ["BuildAndRessources_ctrlDown", false];
    private _shift = _display getVariable ["BuildAndRessources_shiftDown", false];
    private _previewObject = _display getVariable ["BuildAndRessources_previewObject", objNull];

    //Stops if placement mode no longer has a valid preview object.
    if (isNull _previewObject) exitWith {};

    //Reads the current placement adjustments stored on the preview object.
    private _dirAdd = _previewObject getVariable ["BuildAndRessources_dirAdd",0];
    private _posAdd = _previewObject getVariable ["BuildAndRessources_posAdd",0];
    private _distance = _previewObject getVariable ["BuildAndRessources_distance",5];

    //Reads the allowed height and distance limits stored on the display.
    private _minHeight = _display getVariable ["BuildAndRessources_minHeight", 0];
    private _maxHeight = _display getVariable ["BuildAndRessources_maxHeight",0];
    private _minDistance = _display getVariable ["BuildAndRessources_minDistance",3];
    private _maxDistance = _display getVariable ["BuildAndRessources_maxDistance", 20];

    if (_ctrl) then
    {
        // CTRL + scroll = rotate the preview object.
        if (_scroll > 0) then { _dirAdd = _dirAdd + 1; };
        if (_scroll < 0) then { _dirAdd = _dirAdd - 1; };
    }
    else
    {
        if (_shift) then
        {
            // SHIFT + scroll = move the preview object closer or farther away.
            if (_scroll > 0) then
            {
                _distance = _distance + 0.5;
                _distance = _distance min _maxDistance;
            };

            if (_scroll < 0) then
            {
                _distance = _distance - 0.5;
                _distance = _distance max _minDistance;
            };
        }
        else
        {
            // Scroll only = raise or lower the preview object.
            if (_scroll > 0) then
            {
                _posAdd = _posAdd + 0.05;
                _posAdd = _posAdd min _maxHeight;
            };

            if (_scroll < 0) then
            {
                _posAdd = _posAdd - 0.05;
                _posAdd = _posAdd max _minHeight;
            };
        };
    };

    //Stores the updated placement values back on the preview object.
    _previewObject setVariable ["BuildAndRessources_dirAdd", _dirAdd];
    _previewObject setVariable ["BuildAndRessources_posAdd", _posAdd];
    _previewObject setVariable ["BuildAndRessources_distance", _distance];
}];

//Uses the middle mouse button to update the surface normal used for object alignment.
_mouseButtonDownHandler = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
    params ["_displayOrControl", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];

    private _previewObject = _displayOrControl getVariable ["BuildAndRessources_previewObject", objNull];

    if (_button == 2) then {

        //Reads the current preview position and terrain information below it.
        _posObject = getPos _previewObject;
        _groundZ = getTerrainHeightASL [_posObject select 0, _posObject select 1];

        //Reads and stores the terrain surface normal for slope alignment.
        _surfaceNormal = (surfaceNormal getPosASL _previewObject);
        _previewObject setVariable ["BuildAndRessources_surfaceNormal", _surfaceNormal];
    };
}];

//Stores important placement variables on display 46 so the input event handlers can access them.
(findDisplay 46) setVariable ["BuildAndRessources_previewObject", _previewObject];
(findDisplay 46) setVariable ["BuildAndRessources_minHeight", _minHeight];
(findDisplay 46) setVariable ["BuildAndRessources_maxHeight", _maxHeight];
(findDisplay 46) setVariable ["BuildAndRessources_minDistance", _minDistance];
(findDisplay 46) setVariable ["BuildAndRessources_maxDistance", _maxDistance];

//////////////////////
//	PREVIEW HANDLER	//
//////////////////////

//Runs every frame while the player is positioning the preview object.
_previewHandler = [
    {
        params ["_args", "_pfhId"];

        _args params [["_caller", objNull], ["_previewObject", objNull]];

        //Reads the latest placement adjustments from the preview object.
        private _position = _previewObject getVariable ["BuildAndRessources_posAdd", 0];
        private _surfaceNormal = _previewObject getVariable ["BuildAndRessources_surfaceNormal", [0,0,1]];
        private _dirAdd = _previewObject getVariable ["BuildAndRessources_dirAdd", 0];
        private _distance = _previewObject getVariable ["BuildAndRessources_distance",5];

        //Converts the stored rotation offset into a direction vector.
        _direction = [sin _dirAdd, cos _dirAdd, 0];

        //Continuously updates preview position, distance, height, rotation and slope alignment.
        _previewObject attachTo [_caller, [0, _distance, _position]];
        _previewObject setVectorDirAndUp [_direction,_surfaceNormal];

        //Left mouse button confirms the selected placement.
        if (inputMouse 0 == 1) then {

            //Marks placement as complete and detaches the preview at its current position.
            _previewObject setVariable ["BuildAndRessources_buildDone", true];
            detach _previewObject;

            //Stops the per-frame preview handler.
            _pfhId call CBA_fnc_removePerFrameHandler;
        }else{

            //Right mouse button cancels placement.
            if (inputMouse 1 == 1) then {

                //Marks the placement as cancelled and removes the preview object.
                _previewObject setVariable ["BuildAndRessources_buildCanceled", true];
                deleteVehicle _previewObject;

                //Stops the per-frame preview handler.
                _pfhId call CBA_fnc_removePerFrameHandler;
            };
        };

    },
    0,
    [_caller, _previewObject]
] call CBA_fnc_addPerFrameHandler;

//Waits until the player either confirms or cancels the preview placement.
waitUntil {_previewObject getVariable ["BuildAndRessources_buildDone", false] or _previewObject getVariable ["BuildAndRessources_buildCanceled", false]};

//Removes all temporary input handlers after preview mode ends.
findDisplay 46 displayRemoveEventHandler ["keyDown",_keyDownHandler];
findDisplay 46 displayRemoveEventHandler ["keyUp",_keyUpHandler];
findDisplay 46 displayRemoveEventHandler ["MouseZChanged",_mouseWheelChangeHandler];
findDisplay 46 displayRemoveEventHandler ["MouseButtonDown",_mouseButtonDownHandler];

/////////////////
//	PLACEMENT  //
/////////////////

//Stops here if the player cancelled during preview mode.
if (_previewObject getVariable ["BuildAndRessources_buildCanceled", false] == true) exitWith {
    hint "Placement canceled.";
};

//Starts the construction animation before the ACE progress bar begins.
_caller playMove "Acts_carFixingWheel";

[
    _time, //Time needed if the progress bar completes
    [_previewObject, _caller, _name, _time, _ressources, _cost, _sortedCrates, _eventHandler, _buildCostsDisabled], //Arguments
    {
        // Code that runs on completion
        params ["_params"];
        _params params ["_previewObject", "_caller", "_name", "_time", "_ressources", "_cost", "_sortedCrates", "_eventHandler", "_buildCostsDisabled"];

        //Stops the construction animation.
        _caller switchMove "Stand";

        //Removes the construction cost from nearby crates unless free building is enabled.
        if (!_buildCostsDisabled) then {
            [_sortedCrates, _cost, "remove"] remoteExecCall ["BuildAndRessources_fnc_updateRessources", 2];
        };

        //Clears the player's currently selected build object.
        _caller setVariable ["BuildAndRessources_selectedObject", objNull];

        //Saves the completed object through the optional Persistency mod if available.
        if (!isNil "Persistency_fnc_saveObject") then {
            [[_previewObject]] remoteExecCall ["Persistency_fnc_saveObject",2];
        };

        //Adds the ACE deconstruction interaction to the completed object on all machines.
        [_previewObject, _time, _name, _sortedCrates, _cost] remoteExecCall ["BuildAndRessources_fnc_deleteObject", 0, true];

        //Removes the temporary ladder-blocking animation event handler.
        _caller removeEventHandler ["AnimChanged", _eventHandler];
    },
    {
        // Code that runs if the progress bar cancels.
        params ["_params"];
        _params params ["_previewObject", "_caller", "_name", "_time", "_ressources", "_cost", "_sortedCrates", "_eventHandler"];

        //Resets the player's animation and removes the unfinished object.
        _caller switchMove "Stand";
        deleteVehicle _previewObject;

        //Clears the player's selected-object state.
        _caller setVariable ["BuildAndRessources_selectedObject", _objNull];

        //Removes the temporary ladder-blocking animation event handler.
        _caller removeEventHandler ["AnimChanged", _eventHandler];
    },
    _name + " is being build." //Shown Text on progress bar.
] call ace_common_fnc_progressBar;
