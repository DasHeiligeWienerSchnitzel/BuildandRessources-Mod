params ["_object","_worldPos","_dirAdd","_surfaceNormal"];

//Stops the function if no valid object was supplied.
if (isNull _object) exitWith {};

//Detaches the preview object from any temporary parent object used during placement.
detach _object;

//Calculates the final object direction and converts it into a direction vector.
private _dir = (getDir _object + _dirAdd) % 360;
private _vectorDir = [_dir] call BIS_fnc_dirToVector;

//Places the object at its final world position and aligns it with the surface normal.
_object setPosWorld _worldPos;
_object setVectorDirAndUp [_vectorDir, _surfaceNormal];

//Re-enables global simulation after placement is finalized.
_object enableSimulationGlobal true;
