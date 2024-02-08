1. Add the following items to your shared.lua/items.lua depending if using qbcore 

```lua
['boombox'] 			 = {['name'] = 'boombox', 				['label'] = 'Boombox', 				['weight'] = 500, 		['type'] = 'item', 		['image'] = 'boombox.png', 		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Plays Music'},
```
2. Add The following query if you use ESX

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('boombox', 'Boombox', 1, 0, 1) 

```

If you use some other random inventory make sure to add the items accordingly
