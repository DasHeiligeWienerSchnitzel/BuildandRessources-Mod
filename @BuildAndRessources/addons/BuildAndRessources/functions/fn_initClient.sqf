/*
Adds a EventHandler that calls the addBuildAction function everytime the players controlled unit changes,
so everytime the player dies essentially the addBuildAction function is called again to ensure the 
interaction points will be added correctly.
*/

if (!hasInterface) exitWith {};

[
    "unit",
    {
        params ["_unit"];

        if (isNull _unit) exitWith {};

        [_unit] call BuildAndRessources_fnc_addBuildActions;
    },
    true
] call CBA_fnc_addPlayerEventHandler;

/*
Force ACE to compile the config-defined interaction trees for the depot
and all resource crate classes.
*/
[] spawn
{
    waitUntil
    {
        !isNil "ace_interact_menu_fnc_compileMenu"
    };

    {
        [_x] call ace_interact_menu_fnc_compileMenu;
    } forEach
    [
        "RessourceDepot",
        "RessourceCrate_Concrete",
        "RessourceCrate_Wood",
        "RessourceCrate_Sand",
        "RessourceCrate_Metal"
    ];
};