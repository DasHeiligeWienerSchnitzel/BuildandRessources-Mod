#include "BIS_AddonInfo.hpp"
class CfgPatches
{
    class BuildAndRessources
    {
        name = "Build and Ressources";
        author = "Das Heilige Wiener Schnitzel";
        requiredVersion = 2.22;

		requiredAddons[] =
		{
			"A3_Structures_F",
			"cba_main",
			"ace_common",
			"ace_interact_menu"
		};

        units[] =
        {
            "RessourceCrate_Concrete",
            "RessourceCrate_Wood",
            "RessourceCrate_Sand",
            "RessourceCrate_Metal",
            "RessourceDepot"
        };
        weapons[] = {};
    };
};

class CfgFunctions
{
    class BuildAndRessources
    {
        tag = "BuildAndRessources";

        class BuildAndRessources_Functions
        {
            file = "\BuildAndRessources\functions";

            
			class initConfig
            {
                preInit = 1;
            };

            class initSettings {};

            class initClient
            {
                postInit = 1;
            };
			
			class initServer {
				postInit = 1;
			};

            class addBuildActions {};
            class checkCrate {};
            class checkForRessources {};
            class deleteObject {};
            class flatbed {};
            class updateRessources {};
            class placeObject {};
            class finalizePlacement {};
            class addInteractions {};
            class getRessources {};
            class getCrateCapacity {};
            class changeCrateRessourceAmount {};
            class addRessourcesToCrate {};
            class refillCrate {};

            class getDepotCapacity {};
            class getDepotStock {};
            class initializeDepot {};
            class changeDepotRessourceAmount {};
            class findNearbyDepot {};
            class transferDepotToCrate {};
            class transferCrateToDepot {};
            class checkDepot {};
        };
    };
};

class CfgRemoteExec
{
    class Functions
    {
        class BuildAndRessources_fnc_transferDepotToCrate
        {
            allowedTargets = 2;
            jip = 0;
        };

        class BuildAndRessources_fnc_transferCrateToDepot
        {
            allowedTargets = 2;
            jip = 0;
        };
    };
};

class Extended_PreInit_EventHandlers
{
    class BuildAndRessources_CBA_Settings
    {
        init = "call compile preprocessFileLineNumbers '\BuildAndRessources\functions\fn_initSettings.sqf'";
    };
};

class CfgVehicles
{
    class Land_Cargo10_white_F;
    class Land_Cargo10_orange_F;
    class Land_Cargo10_sand_F;
    class Land_Cargo10_grey_F;
    class Land_ContainerLine_01_F;

    class RessourceCrate_Concrete : Land_Cargo10_white_F
    {
        scope = 2;
        scopeCurator = 2;

        displayName = "Ressource Crate — Concrete";

        // Fallback only. Normal capacity comes from the CBA Addon Option.
        BuildAndRessources_ressourceType = "Concrete";
        BuildAndRessources_ressourceAmount = 1000;

        class ACE_Actions
        {
            class ACE_MainActions
            {
                displayName = "Ressources";
                selection = "";
                distance = 5;
                condition = "true";
                statement = "";

                class CheckRessources
                {
                    displayName = "Check ressources";
                    condition = "alive _player";
                    statement = "[_target, _player] call BuildAndRessources_fnc_checkCrate;";
                };

                class WithdrawFromDepot
                {
                    displayName = "Refill from nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferDepotToCrate', 2]; };";
                };

                class StoreInDepot
                {
                    displayName = "Store resources in nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferCrateToDepot', 2]; };";
                };

                class LoadOnFlatbed
                {
                    displayName = "Load onto flatbed";
                    condition = "alive _player && {!(_target getVariable ['BuildAndRessources_loadedOnFlatbed', false])}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };

                class UnloadFromFlatbed
                {
                    displayName = "Unload from flatbed";
                    condition = "alive _player && {_target getVariable ['BuildAndRessources_loadedOnFlatbed', false]}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };
            };
        };

        class Attributes
        {
            class BuildAndRessources_CrateAmount
            {
                displayName = "Initial resource amount";
                tooltip = "Initial amount in this crate. Set -1 to start full, using the CBA crate capacity setting.";
                property = "BuildAndRessources_CrateAmount";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-1";
                expression = "_this setVariable ['BuildAndRessources_CrateAmount', _value, true];";
            };
        };
    };

    class RessourceCrate_Wood : Land_Cargo10_orange_F
    {
        scope = 2;
        scopeCurator = 2;

        displayName = "Ressource Crate — Wood";

        // Fallback only. Normal capacity comes from the CBA Addon Option.
        BuildAndRessources_ressourceType = "Wood";
        BuildAndRessources_ressourceAmount = 1000;

        class ACE_Actions
        {
            class ACE_MainActions
            {
                displayName = "Ressources";
                selection = "";
                distance = 5;
                condition = "true";
                statement = "";

                class CheckRessources
                {
                    displayName = "Check ressources";
                    condition = "alive _player";
                    statement = "[_target, _player] call BuildAndRessources_fnc_checkCrate;";
                };

                class WithdrawFromDepot
                {
                    displayName = "Refill from nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferDepotToCrate', 2]; };";
                };

                class StoreInDepot
                {
                    displayName = "Store resources in nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferCrateToDepot', 2]; };";
                };

                class LoadOnFlatbed
                {
                    displayName = "Load onto flatbed";
                    condition = "alive _player && {!(_target getVariable ['BuildAndRessources_loadedOnFlatbed', false])}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };

                class UnloadFromFlatbed
                {
                    displayName = "Unload from flatbed";
                    condition = "alive _player && {_target getVariable ['BuildAndRessources_loadedOnFlatbed', false]}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };
            };
        };

        class Attributes
        {
            class BuildAndRessources_CrateAmount
            {
                displayName = "Initial resource amount";
                tooltip = "Initial amount in this crate. Set -1 to start full, using the CBA crate capacity setting.";
                property = "BuildAndRessources_CrateAmount";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-1";
                expression = "_this setVariable ['BuildAndRessources_CrateAmount', _value, true];";
            };
        };
    };

    class RessourceCrate_Sand : Land_Cargo10_sand_F
    {
        scope = 2;
        scopeCurator = 2;

        displayName = "Ressource Crate — Sand";

        // Fallback only. Normal capacity comes from the CBA Addon Option.
        BuildAndRessources_ressourceType = "Sand";
        BuildAndRessources_ressourceAmount = 1000;

        class ACE_Actions
        {
            class ACE_MainActions
            {
                displayName = "Ressources";
                selection = "";
                distance = 5;
                condition = "true";
                statement = "";

                class CheckRessources
                {
                    displayName = "Check ressources";
                    condition = "alive _player";
                    statement = "[_target, _player] call BuildAndRessources_fnc_checkCrate;";
                };

                class WithdrawFromDepot
                {
                    displayName = "Refill from nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferDepotToCrate', 2]; };";
                };

                class StoreInDepot
                {
                    displayName = "Store resources in nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferCrateToDepot', 2]; };";
                };

                class LoadOnFlatbed
                {
                    displayName = "Load onto flatbed";
                    condition = "alive _player && {!(_target getVariable ['BuildAndRessources_loadedOnFlatbed', false])}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };

                class UnloadFromFlatbed
                {
                    displayName = "Unload from flatbed";
                    condition = "alive _player && {_target getVariable ['BuildAndRessources_loadedOnFlatbed', false]}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };
            };
        };

        class Attributes
        {
            class BuildAndRessources_CrateAmount
            {
                displayName = "Initial resource amount";
                tooltip = "Initial amount in this crate. Set -1 to start full, using the CBA crate capacity setting.";
                property = "BuildAndRessources_CrateAmount";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-1";
                expression = "_this setVariable ['BuildAndRessources_CrateAmount', _value, true];";
            };
        };
    };

    class RessourceCrate_Metal : Land_Cargo10_grey_F
    {
        scope = 2;
        scopeCurator = 2;

        displayName = "Ressource Crate — Metal";

        // Fallback only. Normal capacity comes from the CBA Addon Option.
        BuildAndRessources_ressourceType = "Metal";
        BuildAndRessources_ressourceAmount = 1000;

        class ACE_Actions
        {
            class ACE_MainActions
            {
                displayName = "Ressources";
                selection = "";
                distance = 5;
                condition = "true";
                statement = "";

                class CheckRessources
                {
                    displayName = "Check ressources";
                    condition = "alive _player";
                    statement = "[_target, _player] call BuildAndRessources_fnc_checkCrate;";
                };

                class WithdrawFromDepot
                {
                    displayName = "Refill from nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'withdraw'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferDepotToCrate', 2]; };";
                };

                class StoreInDepot
                {
                    displayName = "Store resources in nearby depot";
                    condition = "alive _player && {!isNull ([_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot)}";
                    statement = "private _depot = [_target, 'deposit'] call BuildAndRessources_fnc_findNearbyDepot; if (!isNull _depot) then { [_depot, _target] remoteExecCall ['BuildAndRessources_fnc_transferCrateToDepot', 2]; };";
                };

                class LoadOnFlatbed
                {
                    displayName = "Load onto flatbed";
                    condition = "alive _player && {!(_target getVariable ['BuildAndRessources_loadedOnFlatbed', false])}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };

                class UnloadFromFlatbed
                {
                    displayName = "Unload from flatbed";
                    condition = "alive _player && {_target getVariable ['BuildAndRessources_loadedOnFlatbed', false]}";
                    statement = "[_target] call BuildAndRessources_fnc_flatbed;";
                };
            };
        };

        class Attributes
        {
            class BuildAndRessources_CrateAmount
            {
                displayName = "Initial resource amount";
                tooltip = "Initial amount in this crate. Set -1 to start full, using the CBA crate capacity setting.";
                property = "BuildAndRessources_CrateAmount";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-1";
                expression = "_this setVariable ['BuildAndRessources_CrateAmount', _value, true];";
            };
        };
    };

    class RessourceDepot : Land_ContainerLine_01_F
    {
        scope = 2;
        scopeCurator = 2;

        displayName = "Ressource Depot";

        // Used by depot functions to identify valid depot objects.
        BuildAndRessources_isRessourceDepot = 1;
        BuildAndRessources_depotCapacityFallback = 5000;

        class ACE_Actions
        {
            class ACE_MainActions
            {
                displayName = "Ressources";
                position = "[0,0,0.5]";
				doNotCheckLOS = 1;
                distance = 50;
                condition = "true";
                statement = "";

                class CheckDepotStock
                {
                    displayName = "Check depot stock";
                    condition = "alive _player";
                    statement = "[_target, _player] call BuildAndRessources_fnc_checkDepot;";
                };
            };
        };

        class Attributes
        {
            class BuildAndRessources_DepotAllowWithdraw
            {
                displayName = "Allow withdrawal";
                tooltip = "Allow players to refill compatible resource crates from this depot.";
                property = "BuildAndRessources_DepotAllowWithdraw";
                control = "Checkbox";
                typeName = "BOOL";
                defaultValue = "true";
                expression = "_this setVariable ['BuildAndRessources_depotAllowWithdraw', _value, true];";
            };

            class BuildAndRessources_DepotAllowDeposit
            {
                displayName = "Allow deposits";
                tooltip = "Allow players to store resources from compatible crates in this depot. Infinite resource stocks cannot receive deposits.";
                property = "BuildAndRessources_DepotAllowDeposit";
                control = "Checkbox";
                typeName = "BOOL";
                defaultValue = "true";
                expression = "_this setVariable ['BuildAndRessources_depotAllowDeposit', _value, true];";
            };

            class BuildAndRessources_DepotTransferRadius
            {
                displayName = "Transfer radius";
                tooltip = "Maximum distance in metres between the depot and a resource crate for player transfers.";
                property = "BuildAndRessources_DepotTransferRadius";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "50";
                expression = "_this setVariable ['BuildAndRessources_depotTransferRadius', _value, true];";
            };

            class BuildAndRessources_DepotConcreteEnabled
            {
                displayName = "Enable Concrete storage";
                tooltip = "Allow this depot to store and supply Concrete resources.";
                property = "BuildAndRessources_DepotConcreteEnabled";
                control = "Checkbox";
                typeName = "BOOL";
                defaultValue = "true";
                expression = "_this setVariable ['BuildAndRessources_depotConcreteEnabled', _value, true];";
            };

            class BuildAndRessources_DepotConcreteInitial
            {
                displayName = "Concrete initial stock";
                tooltip = "-2 = start full using the CBA depot capacity; -1 = infinite; 0 or higher = exact starting stock.";
                property = "BuildAndRessources_DepotConcreteInitial";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-2";
                expression = "_this setVariable ['BuildAndRessources_depotConcreteInitial', _value, true];";
            };

            class BuildAndRessources_DepotWoodEnabled
            {
                displayName = "Enable Wood storage";
                tooltip = "Allow this depot to store and supply Wood resources.";
                property = "BuildAndRessources_DepotWoodEnabled";
                control = "Checkbox";
                typeName = "BOOL";
                defaultValue = "true";
                expression = "_this setVariable ['BuildAndRessources_depotWoodEnabled', _value, true];";
            };

            class BuildAndRessources_DepotWoodInitial
            {
                displayName = "Wood initial stock";
                tooltip = "-2 = start full using the CBA depot capacity; -1 = infinite; 0 or higher = exact starting stock.";
                property = "BuildAndRessources_DepotWoodInitial";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-2";
                expression = "_this setVariable ['BuildAndRessources_depotWoodInitial', _value, true];";
            };

            class BuildAndRessources_DepotSandEnabled
            {
                displayName = "Enable Sand storage";
                tooltip = "Allow this depot to store and supply Sand resources.";
                property = "BuildAndRessources_DepotSandEnabled";
                control = "Checkbox";
                typeName = "BOOL";
                defaultValue = "true";
                expression = "_this setVariable ['BuildAndRessources_depotSandEnabled', _value, true];";
            };

            class BuildAndRessources_DepotSandInitial
            {
                displayName = "Sand initial stock";
                tooltip = "-2 = start full using the CBA depot capacity; -1 = infinite; 0 or higher = exact starting stock.";
                property = "BuildAndRessources_DepotSandInitial";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-2";
                expression = "_this setVariable ['BuildAndRessources_depotSandInitial', _value, true];";
            };

            class BuildAndRessources_DepotMetalEnabled
            {
                displayName = "Enable Metal storage";
                tooltip = "Allow this depot to store and supply Metal resources.";
                property = "BuildAndRessources_DepotMetalEnabled";
                control = "Checkbox";
                typeName = "BOOL";
                defaultValue = "true";
                expression = "_this setVariable ['BuildAndRessources_depotMetalEnabled', _value, true];";
            };

            class BuildAndRessources_DepotMetalInitial
            {
                displayName = "Metal initial stock";
                tooltip = "-2 = start full using the CBA depot capacity; -1 = infinite; 0 or higher = exact starting stock.";
                property = "BuildAndRessources_DepotMetalInitial";
                control = "Edit";
                typeName = "NUMBER";
                defaultValue = "-2";
                expression = "_this setVariable ['BuildAndRessources_depotMetalInitial', _value, true];";
            };
        };
    };
};
