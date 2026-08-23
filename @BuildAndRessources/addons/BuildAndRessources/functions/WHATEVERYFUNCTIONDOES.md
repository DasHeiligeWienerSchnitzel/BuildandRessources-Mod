**fn\_addBuildActions.sqf**

This script adds the new ace interaction points that enables the player to build pre determined structures 

through the Classnames List. Found in the ER32\_Classnames.sqf file.



**fn\_addInteractions.sqf**

Creates an ace interaction point to check for ressources inside the crate.



**fn\_addResourcesToCrate.sqf**

Adds resources to one valid BuildAndRessources crate.



This function is deliberately limited to positive values. It returns the

same result format as fn\_changeCrateRessourceAmount:



\[actuallyAdded, newAmount, capacity]



**fn\_changeCrateRessourceAmount.sqf**

Changes the currently stored amount in one valid BuildAndRessources crate.



This is the central, server-side write function for crate resources.

A positive delta adds resources; a negative delta removes resources.

The resulting amount is always clamped between 0 and the crate capacity.



Return value:

\[actualChange, newAmount, capacity]



actualChange can be lower than the requested delta when the crate is

already nearly full or nearly empty.



**fn\_changeDepotRessourceAmount.sqf**

Central server-side write function for Ressource Depot stock.



Positive delta: store resources in the depot.

Negative delta: remove resources from the depot.



Return value:

\[actualChange, newAmount, capacity]



Infinite stock is represented by -1. Removing from it returns the requested

negative change while leaving the stock at -1. Depositing into it returns 0

because depositing into infinity would silently destroy resources.



**fn\_checkCrate.sqf**

Checks the amount of ressources inside a crate and hints the amount.



**fn\_checkDepot.sqf**

Displays the currently configured depot stocks for the interacting player.



**fn\_checkForRessources.sqf**

Checks the amount of ressources inside all crates nearby the player and hints the amount.



**fn\_deleteObject.sqf**

Deletes the object and returns partial refund cost.



**fn\_finalizePlacement.sqf**

Finalizes Placement of build object, so all players look at the same object.



**fn\_findNearbyDepot.sqf**

Finds the nearest compatible Ressource Depot for a crate.



\_mode:

"withdraw" - depot can refill the crate.

"deposit"  - depot can receive resources from the crate.



The function is read-only and may be called on clients for ACE conditions.



**fn\_flatbed.sqf**

Toggles the selected object's flatbed state:

\- unloaded object: load it onto the nearest compatible flatbed

\- loaded object: unload this exact object from its saved flatbed



**fn\_getCrateCapacity.sqf**

Returns the current globally configured capacity for this crate type.

The config value is only a fallback in case the CBA setting is unavailable.



**fn\_getDepotCapacity.sqf**

Returns the globally configured finite capacity for a given resource type

inside a Ressource Depot.



**fn\_getDepotStock.sqf**

Returns the current depot-stock array in the normal resource order:

\[Concrete, Wood, Sand, Metal].



\-1 means an enabled infinite resource stock.

0 or higher is a finite stock amount.



Before a depot is first used, this function derives the initial array from

its Eden attributes without writing mission state. The server writes that

same array when fn\_initializeDepot is called.



**fn\_getRessources.sqf**

Gets the ressources out of a crate.



**fn\_initClient.sqf**

Initialises Scripts for Clients and forces ACE to recompile config-defined interactions.



**fn\_initConfig.sqf**

General BuildAndRessources setup.



CBA settings are registered separately in fn\_initSettings.sqf via the

Extended\_PreInit\_EventHandlers entry in config.cpp.



**fn\_initializeDepot.sqf**

Initializes a depot's persistent stock array on the server.

This is deliberately lazy so Eden attributes have already been applied

before their values are converted into runtime mission state.



**fn\_initSettings.sqf**

Register BuildAndRessources CBA Addon Options.



This file is launched by Extended\_PreInit\_EventHandlers after CBA's

settings component is available.



**fn\_placeObject.sqf**

Handles preview and placement of Objects.



**fn\_refillCrate.sqf**

Refills one valid BuildAndRessources crate to its configured capacity.

Return value: \[actuallyAdded, newAmount, capacity]



**fn\_transferCrateToDepot.sqf**

Transfers as much of a crate's stored resource as possible into a nearby

compatible finite depot stock.



Depositing into an infinite depot is intentionally prohibited so resources

cannot disappear into an already unlimited pool.



Return value:

\[transferred, crateAmount, crateCapacity, depotAmount, depotCapacity]



**fn\_transferDepotToCrate.sqf**

Transfers as much of the crate's resource type as possible from a depot

into a nearby compatible resource crate.



This function is server-side only and may be safely requested by a client

through remoteExecCall. The server rechecks compatibility, distance and the

remote caller's position before changing any stock.



Return value:

\[transferred, crateAmount, crateCapacity, depotAmount, depotCapacity]



**fn\_updateRessource.sqf**

Updates Amount of Ressource inside the crate.





