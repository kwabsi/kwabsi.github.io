extends Node

enum INDEX { HANDGUN, REVOLVER }

var dict = {
	INDEX.HANDGUN: Weapon.Data.new().fromJSON({
		"displayName": "Handgun",
		"texture": "res://assets/sprites/items/weapons/handgun.png",
		"projectile": 0, "damage": 20, "fireRate": 0, "kickback": 5, "ammunition": 16,
		"accuracy": 90, "weight": 3, "twoHanded": false,
		"origin": { "x": -5.5, "y": -8 }, "muzzle": { "x": 10, "y": -4 },
		"primaryColor": "53676a", "secondaryColor": "1e2020", "projectileColor": "d8d8d6",
	})
}

