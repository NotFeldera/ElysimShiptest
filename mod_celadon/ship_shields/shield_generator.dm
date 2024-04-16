/obj/machinery/power/shield_generator
	name = "Shield generator Cobra"
	desc = "It's a high efficiency shields generator."
	//icon = 'icons/obj/machines/shieldsgen.dmi'
	icon_state = "shields-unassembled"
	density = TRUE
	use_power = NO_POWER_USE
	integrity_failure = 0.375

	var/obj/machinery/power/defence/stabilizedfield
	var/obj/machinery/power/defence/stabilizedfieldtwo

	var/shield_integrity = 0
	var/max_shield_integrity = 100
	var/shield_recharge_speed = 1
	var/mode = 0 // 0 - выключен; 1,2,3,4,5 - скорости зарядки

/*
/obj/machinery/power/generator/Initialize(mapload)
	. = ..()
	find_circs()
	connect_to_network()
	SSair.start_processing_machine(src, mapload)
	update_appearance()
	component_parts = list(new /obj/item/circuitboard/machine/shield_generator)

/obj/machinery/power/generator/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS)

/obj/machinery/power/generator/Destroy()
	kill_circs()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/power/generator/update_appearance()
	cut_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

	if(machine_stat & (BROKEN))
		icon_state = "shields-broken"
		return
	if(hot_circ && cold_circ)
		icon_state = "shields-assembled"
	else
		icon_state = "shields-unassembled"
		if(panel_open)
			add_overlay("shields-panel")
		return

	if(machine_stat & (NOPOWER))
		return
	else
		var/L = min(round(lastgenlev/100000),11)
		if(L != 0)
			SSvis_overlays.add_vis_overlay(src, icon, "shields-op[L]", ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir)
	return ..()


#define GENRATE 800		// generator output coefficient from Q


/obj/machinery/power/generator/process()
	//Setting this number higher just makes the change in power output slower, it doesnt actualy reduce power output cause **math**
	var/power_output = round(lastgen / 10)
	add_avail(power_output)
	lastgenlev = power_output
	lastgen -= power_output
	..()

/obj/machinery/power/generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThermalGenerator", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/power/generator/ui_data(mob/user)
//	var/datum/gas_mixture/cold_circ_air1 = cold_circ.airs[1] //outlet cold
	var/datum/gas_mixture/cold_circ_air2 = cold_circ.airs[2] //inlet cold
//	var/datum/gas_mixture/hot_circ_air1 = hot_circ.airs[1] //outlet hot
	var/datum/gas_mixture/hot_circ_air2 = hot_circ.airs[2] //inlet hot

	. = ..()
	.["powernet"] = powernet
	.["power"] = lastgenlev
	.["coldCircTemp"] = round(cold_circ_air2.return_temperature(), 0.1)
	.["coldCircPressure"] = round(cold_circ_air2.return_pressure(), 0.1)
	.["hotCircTemp"] = round(hot_circ_air2.return_temperature(), 0.1)
	.["hotCircPressure"] = round(hot_circ_air2.return_pressure(), 0.1)
	.["hotCirc"] = hot_circ
	.["coldCirc"] = cold_circ

/obj/machinery/power/generator/proc/find_circs()
	kill_circs()
	var/list/circs = list()
	var/obj/machinery/atmospherics/components/binary/circulator/C
	var/circpath = /obj/machinery/atmospherics/components/binary/circulator
	if(dir == NORTH || dir == SOUTH)
		C = locate(circpath) in get_step(src, EAST)
		if(C && C.dir == WEST && C.anchored && !(C.machine_stat &(BROKEN)) && !C.panel_open)
			circs += C

		C = locate(circpath) in get_step(src, WEST)
		if(C && C.dir == EAST && C.anchored && !(C.machine_stat &(BROKEN)) && !C.panel_open)
			circs += C

	else
		C = locate(circpath) in get_step(src, NORTH)
		if(C && C.dir == SOUTH && C.anchored && !(C.machine_stat &(BROKEN)) && !C.panel_open)
			circs += C

		C = locate(circpath) in get_step(src, SOUTH)
		if(C && C.dir == NORTH && C.anchored && !(C.machine_stat &(BROKEN)) && !C.panel_open)
			circs += C

	if(length(circs) == 2)
		for(C in circs)
			if(C.mode == CIRCULATOR_COLD && !cold_circ)
				cold_circ = C
				C.generator = src
			else if(C.mode == CIRCULATOR_HOT && !hot_circ)
				hot_circ = C
				C.generator = src
		if(!hot_circ || !cold_circ)
			kill_circs()
			return 3
	return length(circs)

/obj/machinery/power/generator/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.a_intent == INTENT_HARM)
		return

	if(!panel_open) //connect/disconnect circulators
		if(!anchored)
			to_chat(user, "<span class='warning'>Anchor [src] before trying to connect the circulators!</span>")
			return TRUE
		else
			if(stabilizedfield && stabilizedfieldtwo)
				to_chat(user, "<span class='notice'>You start removing the circulators...</span>")
				if(I.use_tool(src, user, 30, volume=50))
					kill_circs()
					update_appearance()
					to_chat(user, "<span class='notice'>You disconnect [src]'s circulator links.</span>")
					playsound(src, 'sound/misc/box_deploy.ogg', 50)
				return TRUE

			to_chat(user, "<span class='notice'>You attempt to attach the circulators...</span>")
			if(I.use_tool(src, user, 30, volume=50))
				switch(find_circs())
					if(0)
						to_chat(user, "<span class='warning'>No circulators found!</span>")
					if(1)
						to_chat(user, "<span class='warning'>Only one circulator found!</span>")
					if(2)
						to_chat(user, "<span class='notice'>You connect [src]'s circulator links.</span>")
						playsound(src, 'sound/misc/box_deploy.ogg', 50)
						return TRUE
					if(3)
						to_chat(user, "<span class='warning'>Both circulators are the same mode!</span>")
				return TRUE

	set_anchored(!anchored)
	I.play_tool_sound(src)
	if(!anchored)
		kill_circs()
	connect_to_network()
	to_chat(user, "<span class='notice'>You [anchored?"secure":"unsecure"] [src].</span>")
	update_appearance()
	return TRUE

/obj/machinery/power/generator/screwdriver_act(mob/user, obj/item/I)
	if(..())
		return TRUE
	if(user.a_intent == INTENT_HARM)
		return

	if(stabilizedfield && stabilizedfieldtwo)
		to_chat(user, "<span class='warning'>Disconnect the circulators first!</span>")
		return TRUE
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [panel_open?"open":"close"] the panel on [src].</span>")
	update_appearance()
	return TRUE

/obj/machinery/power/generator/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return

	if(anchored)
		to_chat(user, "<span class='warning'>[src] is anchored!</span>")
		return TRUE
	else if(!panel_open)
		to_chat(user, "<span class='warning'>Open the panel first!</span>")
		return TRUE
	else
		default_deconstruction_crowbar(I)
		return TRUE

/obj/machinery/power/generator/on_deconstruction()
	kill_circs()

/obj/machinery/power/generator/proc/kill_circs()
	if(stabilizedfield)
		stabilizedfield.generator = null
		stabilizedfield.update_appearance()
		stabilizedfield = null
	if(stabilizedfieldtwo)
		stabilizedfieldtwo.generator = null
		stabilizedfieldtwo.update_appearance()
		stabilizedfieldtwo = null

/obj/machinery/power/generator/obj_break(damage_flag)
	kill_circs()
	..()
*/
/obj/machinery/power/shield_generator/proc/recharge(forced_full = FALSE)
	if(forced_full)
		shield_integrity = max_shield_integrity
		return
	if(shield_integrity >= max_shield_integrity)
		return

	shield_integrity = min(shield_integrity + shield_recharge_speed, max_shield_integrity)

/obj/machinery/power/shield_generator/proc/do_damage(damage = 0)
	if(shield_integrity - damage >= 0)
		shield_integrity = max(shield_integrity - damage, 0)
		return FALSE
	shield_integrity -= damage
	return TRUE

/obj/machinery/power/shield_generator/process()
	if(!mode)
		return

	src.recharge()
