## [0.0.1] -  Initial Release.

## [0.1.0] -  Stable Release : 
Added Support for listening the updates via onUpdate method. It can be used for pushing routes or showing snackbar. See More in Example

## [0.1.2] -  New Function :
Added Support for relaying more than one updates at a time via relayMultiple() function.

## [0.1.4] -  Major Bug Fixes:
Bug of re-initialization of station object fixed.

## [0.2.1] - Major Api Breaking Changes :
- Renamed Station to Store.
- Provider Widgets are decoupled using ProviderMixin.
- Store Initialization made global and uplifted to Provider Widget.

## [0.3.0] - Major Api Breaking Changes :
- Added New Class : Action and Update
- Used Stream and yield to release update.
- Changes are within updates. No need of store in build methods.

## [0.3.1] - Bug Fixes :
- Fixed Counter Bug in Example.

## [0.3.2] - New Features :
- Removed Parameter Store From Relay Builder( You can explicitly specify it also).
- Dispatcher Widget can be used to get store object for dispatching actions.