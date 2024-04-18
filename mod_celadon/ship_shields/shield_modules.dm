/obj/machinery/shield
	name = "Shield module"
	desc = "It's a high efficiency shields generator."

	var/shield_storage
	var/power_usage
	var/shield_recharge_speed

/obj/machinery/shield/proc/install(var/obj/machinery/power/shield_core/core)
	core.max_shield_integrity += shield_storage
	core.shield_recharge_speed += shield_recharge_speed
	core.power_usage += power_usage
	return src//ретурн срц это кароче я потом сделаю что бы оно было типо в файле щилд кор такая залупа modules.append(module.install(src))

/obj/machinery/shield/proc/uninstall(var/obj/machinery/power/shield_core/core)
	core.max_shield_integrity -= shield_storage
	core.shield_recharge_speed -= shield_recharge_speed
	core.power_usage -= power_usage
	return src


/obj/machinery/shield/capacitor//для каждой залупки надо добавить разные тиры(tier1, tier2...)
	name = "Shield capacitor"
	desc = "It's a high efficiency shields generator."

	shield_storage = 1000
	power_usage = 10

/obj/machinery/shield/accumulator
	name = "Shield gaccumulator"//или generator
	desc = "It's a high efficiency shields generator."

	shield_recharge_speed = 1
	power_usage = 10

