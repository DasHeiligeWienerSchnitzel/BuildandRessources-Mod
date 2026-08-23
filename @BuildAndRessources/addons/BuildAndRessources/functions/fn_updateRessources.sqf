params [
    ["_sortedCrates", [], [[]]],
    ["_cost", [0, 0, 0, 0], [[]]],
    ["_addOrRemove", "remove", [""]]
];

//Resource changes are authoritative and are therefore only performed on the server.
if (!isServer) exitWith {};

/*
    This is the authoritative safety check. It blocks both construction
    removal and deconstruction refunds when free building is enabled.
*/
if (missionNamespace getVariable ["BuildAndRessources_disableBuildCosts", false]) exitWith {};

//Uses the global resource order to match cost-array indexes to resource names.
private _names = BuildAndRessources_names;

//Processes each of the four resource types independently.
for "_ressourceIndex" from 0 to 3 do
{
    //Reads how much of this resource type the construction or refund requires.
    private _amount = _cost select _ressourceIndex;

    //Skips resource types that have no cost.
    if (_amount <= 0) then { continue; };

    //Gets the resource name belonging to the current array index.
    private _ressourceName = _names select _ressourceIndex;

    //Chooses whether resources should be consumed or refunded.
    switch (_addOrRemove) do {
        case "remove": {
            //Tracks how much of this resource still needs to be removed.
            private _remaining = _amount;

            {
                //Stops checking more crates once the full cost has been removed.
                if (_remaining <= 0) exitWith {};

                private _crate = _x;

                //Reads which resource type this crate can contain.
                private _crateType = getText (
                    configOf _crate >> "BuildAndRessources_ressourceType"
                );

                //Ignores crates that do not match the currently processed resource type.
                if !(_crateType isEqualTo _ressourceName) then
                {
                    continue;
                };

                //Reads the crate's current runtime resource array.
                private _crateRessources = [
                    _crate
                ] call BuildAndRessources_fnc_getRessources;

                //Gets the amount available in this matching crate.
                private _available = _crateRessources select _ressourceIndex;

                //Skips empty crates.
                if (_available <= 0) then
                {
                    continue;
                };

                //Only requests as much as this crate can provide or is still needed.
                private _requestedRemoval = _available min _remaining;

                //Removes the resource from this crate.
                private _changeResult = [
                    _crate,
                    -_requestedRemoval
                ] call BuildAndRessources_fnc_changeCrateRessourceAmount;

                //Subtracts the amount that was actually removed from the remaining cost.
                private _actuallyRemoved = -(_changeResult select 0);
                _remaining = _remaining - _actuallyRemoved;
            } forEach _sortedCrates;

            //Logs a warning if the complete resource cost could not be removed.
            if (_remaining > 0) then
            {
                diag_log format [
                    "BuildAndRessources: Could not remove %1 %2.",
                    _remaining,
                    _ressourceName
                ];
            };
        };

        case "add": {
            //Deconstruction refunds half of the original construction cost.
            private _refund = _amount / 2;

            //Finds the first nearby crate that matches this resource type.
            private _crateIndex = _sortedCrates findIf
            {
                getText (
                    configOf _x >> "BuildAndRessources_ressourceType"
                ) isEqualTo _ressourceName
            };

            //Logs a warning if there is no matching crate available for the refund.
            if (_crateIndex < 0) then
            {
                diag_log format [
                    "BuildAndRessources: No nearby %1 crate found for refund.",
                    _ressourceName
                ];

                continue;
            };

            //Adds the refund to the first matching nearby crate.
            private _crate = _sortedCrates select _crateIndex;

            [ _crate, _refund ] call BuildAndRessources_fnc_addRessourcesToCrate;
        };

        //Logs unsupported operation names instead of silently doing nothing.
        default {
            diag_log format ["BuildAndRessources: Unknown update mode '%1'.", _addOrRemove];
        };
    };
};
