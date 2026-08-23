/*
Finds the nearest compatible Ressource Depot for a crate.

_mode:
"withdraw" - depot can refill the crate.
"deposit"  - depot can receive resources from the crate.

The function is read-only and may be called on clients for ACE conditions.
*/

params [
    ["_crate", objNull, [objNull]],
    ["_mode", "withdraw", [""]]
];

//Stops the function if no valid crate was supplied.
if (isNull _crate) exitWith { objNull };

//Reads the ressource type assigned to this crate from its config.
private _crateConfig = configOf _crate;
private _ressourceType = getText (_crateConfig >> "BuildAndRessources_ressourceType");

//Finds the index of that ressource type in the global ressource list.
private _ressourceIndex = BuildAndRessources_names find _ressourceType;

//Stops if the crate uses an unknown ressource type.
if (_ressourceIndex < 0) exitWith { objNull };

//Reads the crate's current amount and maximum capacity for its ressource type.
private _crateRessources = [_crate] call BuildAndRessources_fnc_getRessources;
private _crateAmount = _crateRessources select _ressourceIndex;
private _crateCapacity = [_crate] call BuildAndRessources_fnc_getCrateCapacity;

//Finds all Ressource Depots within the broad search radius.
private _candidateDepots = nearestObjects [_crate, ["RessourceDepot"], 1000];

//Looks for the first depot that is compatible with the requested transfer mode.
private _matchingDepot = _candidateDepots findIf
{
    private _depot = _x;

    //Makes sure the object is actually configured as a Ressource Depot.
    if ((getNumber (configOf _depot >> "BuildAndRessources_isRessourceDepot")) <= 0) then {
        false
    }else{
        //Reads and sanitizes the depot's individual transfer radius.
        private _radius = _depot getVariable ["BuildAndRessources_depotTransferRadius",50];

        if !(_radius isEqualType 0) then {
            _radius = parseNumber str _radius;
        };

        _radius = _radius max 0;

        //Checks whether this ressource type is enabled for the depot.
        private _enabled = _depot getVariable [format ["BuildAndRessources_depot%1Enabled", _ressourceType],true];

        if !(_enabled isEqualType true) then {
            _enabled = _enabled in [1, "1", "true", "TRUE"];
        };

        //Rejects the depot if the crate is outside its transfer radius or the ressource type is disabled.
        if ((_crate distance _depot) > _radius || {!_enabled}) then {
            false
        }else{
            //Reads the depot's current stock and capacity for this ressource type.
            private _stocks = [_depot] call BuildAndRessources_fnc_getDepotStock;
            private _stock = _stocks select _ressourceIndex;
            private _capacity = [_depot, _ressourceType] call BuildAndRessources_fnc_getDepotCapacity;

            //Checks whether the depot can perform the requested transfer operation.
            switch (_mode) do
            {
                case "withdraw": {
                    //Checks whether withdrawing ressources from this depot is allowed.
                    private _allowWithdraw = _depot getVariable ["BuildAndRessources_depotAllowWithdraw",true];

                    if !(_allowWithdraw isEqualType true) then {
                        _allowWithdraw = _allowWithdraw in [1, "1", "true", "TRUE"];
                    };

                    //The crate must have free capacity and the depot must contain ressources or have infinite stock.
                    _allowWithdraw &&
                    {_crateAmount < _crateCapacity} &&
                    {_stock isEqualTo -1 || {_stock > 0}}
                };

                case "deposit": {
                    //Checks whether depositing ressources into this depot is allowed.
                    private _allowDeposit = _depot getVariable ["BuildAndRessources_depotAllowDeposit",true];

                    if !(_allowDeposit isEqualType true) then {
                        _allowDeposit = _allowDeposit in [1, "1", "true", "TRUE"];
                    };

                    //The crate must contain ressources and the depot must have remaining finite capacity.
                    _allowDeposit &&
                    {_crateAmount > 0} &&
                    {_stock >= 0} &&
                    {_stock < _capacity}
                };

                //Rejects unsupported transfer modes.
                default { false };
            };
        };
    };
};

//Returns objNull if no compatible depot was found.
if (_matchingDepot < 0) exitWith { objNull };

//Returns the first compatible depot found.
_candidateDepots select _matchingDepot
