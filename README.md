# TSD-script-storage
because roblox was not gracious enough to let the dex asset model + its scripts be placed on the marketplace, i have decided to move the scripts here, as well as the roblox api too in case maximum adhd stops willingly providing the updated rbx api

what changed from secure dex?

dex has blue/purple tone now
uses classitems like iy dex does, also uses famfamfam for other icons
preloadasync is (or will be) deemed less effective as assets that dex uses are now (or soon to be) directly sourced from rbxasset:// (above)
script viewer doesnt error (trying to save a script does though)
sidebar is now at the top because it looks cooler i guess
unused/unnecessary gui items removed
loader for dex scripts is much faster because fenv of scripts is the same as the original loader
click to select part/selection box works
newer functions are syntaxed for script viewing
callremote supports unreliableremoteevent instances (checking for IsA BaseRemoteEvent)
guis by themselves are updated (every other frame had a border pixel)
getproperties/getfunctions uses the api by maximumadhd (as previously mentioned)

i think that's about it
