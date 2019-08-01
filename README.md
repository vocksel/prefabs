# Prefabs

This plugin allows you to make reuseable models that you can update and have your changes synced across all other copies.

The plugin gives you a few buttons to play around with, which are:

## Add

This is your gateway to prefabs. Once you create a model you like, you register it to have the plugin take control.

The only requirements are:
- The model has a PrimaryPart
- The model is named something unique

With the model selected click the "Add" button. From here you can simply copy/paste the model around as you would normally. The real magic happens with the next button:

## Update

This syncs the changes you've made to one prefab with all the others.

You'll no doubt want to change a prefab eventually. To do this you edit it like you normally would. Once you're done and you're happy with your changes, you select the model and press the "Update" button.

This will take the changes you've made and replicate them to all other prefabs of the same type.

You can also do this while a _descendant_ of the prefab is selected. You aren't required to select the model itself each time you want to update your prefab.

## Development

Install [Hotswap](https://www.roblox.com/library/184216383/HotSwap-v1-1) and [Rojo](https://github.com/rojo-rbx/rojo/)

```
rojo build -o prefabs.rbxlx
rojo serve
```

- Open the place and start up Rojo
- Start up Hotswap and point it to `ReplicatedStorage.Prefabs`
- Run the game
