/obj/machinery/power/shield_core//хз надо разные тиры сюда добавлять думаю все таки нет либо
	name = "Shield generator Cobra"
	desc = "It's a high efficiency shields generator."
	//icon_state = "shields-unassembled"
	icon_state = "wabbajack_statue"
	density = TRUE
	use_power = NO_POWER_USE
	integrity_failure = 0.375

	var/shield_integrity = 0
	var/max_shield_integrity = 0
	var/shield_recharge_speed = 0
	var/mode = 0 // 0 - выключен; 1,2,3,4,5 - скорости зарядки
	var/power_usage = 5

	var/list/modules
	//var/modules_max если добавлять тиры то можно юзать эту переменную

/obj/machinery/power/shield_core/proc/recharge(var/forced_full = FALSE)
	if(forced_full)
		shield_integrity = max_shield_integrity
		return
	if(shield_integrity >= max_shield_integrity)
		return

	shield_integrity = min(shield_integrity + shield_recharge_speed, max_shield_integrity)

/obj/machinery/power/shield_core/proc/do_damage(var/damage = 0)
	if(shield_integrity - damage >= 0)
		shield_integrity = max(shield_integrity - damage, 0)
		return FALSE
	shield_integrity -= damage
	return TRUE

/obj/machinery/power/shield_core/process()
	if(!mode)
		return

	src.recharge()

/obj/machinery/power/shield_core/proc/update_modules()
	return
