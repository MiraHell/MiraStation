/obj/item/gun/syringe
	name = "medical syringe gun"
	desc = "A spring loaded gun designed to fit syringes, used to incapacitate unruly patients from a distance."
	icon = 'icons/obj/weapons/guns/syringegun.dmi'
	icon_state = "medicalsyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_icon_state = "medicalsyringegun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throw_speed = 3
	throw_range = 7
	force = 6
	base_pixel_x = -4
	pixel_x = -4
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	gun_flags = NOT_A_REAL_GUN
	var/load_sound = 'sound/items/weapons/gun/shotgun/insert_shell.ogg'
	var/list/syringes = list()
	/// The number of syringes it can store.
	var/max_syringes = 1
	/// If it has an overlay for inserted syringes. If true, the overlay is determined by the number of syringes inserted into it.
	var/has_syringe_overlay = TRUE
	/// In low power mode syringes will instead embed and slowly inject their reagents
	var/low_power = FALSE

/obj/item/gun/syringe/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/syringegun(src)
	recharge_newshot()

/obj/item/gun/syringe/apply_fantasy_bonuses(bonus)
	. = ..()
	max_syringes = modify_fantasy_variable("max_syringes", max_syringes, bonus, minimum = 1)

/obj/item/gun/syringe/remove_fantasy_bonuses(bonus)
	max_syringes = reset_fantasy_variable("max_syringes", max_syringes)
	return ..()

/obj/item/gun/syringe/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in syringes)
		syringes -= gone

/obj/item/gun/syringe/recharge_newshot()
	if(!syringes.len)
		return
	chambered.newshot()

/obj/item/gun/syringe/can_shoot()
	return syringes.len

/obj/item/gun/syringe/handle_chamber()
	if(chambered && !chambered.loaded_projectile) //we just fired
		recharge_newshot()
	update_appearance()

/obj/item/gun/syringe/examine(mob/user)
	. = ..()
	. += span_notice("Может держать в себе [max_syringes] шприц[declension_ru(max_syringes, "", "а", "ов")]. Имеет внутри [syringes.len] шприц[declension_ru(syringes.len, "", "а", "ов")].")
	if (low_power)
		. += span_notice("Регулятор давление выставлен в минимальный режим, что гарантирует, что шприцы будут медленно впрыскивать реагенты в цель.")
	else
		. += span_notice("Регулятор давление выкручен на максимум, что гарантирует моментальный ввод реагентов, уничтожая при этом шприц.")
	. += span_notice("ПКМ по [src] в руке для переключения давления в [low_power ? "максимальный" : "минимальный"] режим.")

/obj/item/gun/syringe/attack_self(mob/living/user, list/modifiers)
	if (!syringes.len)
		balloon_alert(user, "пусто!")
		return FALSE

	var/obj/item/reagent_containers/syringe/syringe = syringes[syringes.len]

	if (!syringe)
		return FALSE
	user.put_in_hands(syringe)

	syringes.Remove(syringe)
	balloon_alert(user, "снятие [syringe.declent_ru(GENITIVE)]")
	update_appearance()
	return TRUE

/obj/item/gun/syringe/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if (.)
		return

	low_power = !low_power
	if (low_power)
		balloon_alert(user, "enabled low power mode")
		to_chat(user, span_notice("You carefully lower the pressure regulator setting, ensuring that fired syringes embed in your target."))
	else
		balloon_alert(user, "enabled high power mode")
		to_chat(user, span_notice("You crank the pressure regulator to the max, making sure that fired syringes inject their contents instantly."))
	playsound(user, 'sound/machines/click.ogg', 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/syringe/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/reagent_containers/syringe/bluespace))
		balloon_alert(user, "[tool.declent_ru(NOMINATIVE)] не влезает!")
		return ITEM_INTERACT_BLOCKING

	if(!istype(tool, /obj/item/reagent_containers/syringe))
		return NONE

	if(syringes.len >= max_syringes)
		balloon_alert(user, "нет места!")
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "вставка [tool.declent_ru(GENITIVE)]")
	syringes += tool
	recharge_newshot()
	update_appearance()
	playsound(src, load_sound, 40)
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/syringe/update_overlays()
	. = ..()
	if(!has_syringe_overlay)
		return
	var/syringe_count = syringes.len
	. += "[initial(icon_state)]_[syringe_count ? clamp(syringe_count, 1, initial(max_syringes)) : "empty"]"

/obj/item/gun/syringe/rapidsyringe
	name = "compact rapid syringe gun"
	desc = "A modification of the syringe gun design to be more compact and use a rotating cylinder to store up to six syringes."
	icon_state = "rapidsyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "syringegun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	max_syringes = 6
	force = 4

/obj/item/gun/syringe/syndicate
	name = "dart pistol"
	desc = "A small spring-loaded sidearm that functions identically to a syringe gun."
	icon_state = "dartsyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "gun" //Smaller inhand
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	force = 2 //Also very weak because it's smaller
	suppressed = TRUE //Softer fire sound
	can_unsuppress = FALSE //Permanently silenced
	syringes = list(new /obj/item/reagent_containers/syringe())

/obj/item/gun/syringe/dna
	name = "modified compact syringe gun"
	desc = "A syringe gun that has been modified to be compact and fit DNA injectors instead of normal syringes."
	icon_state = "dnasyringegun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "syringegun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	force = 4

/obj/item/gun/syringe/dna/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/dnainjector(src)

/obj/item/gun/syringe/dna/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/dnainjector))
		var/obj/item/dnainjector/D = tool
		if(D.used)
			balloon_alert(user, "внутри [D.declent_ru(GENITIVE)] пусто!")
			return ITEM_INTERACT_BLOCKING
		if(syringes.len < max_syringes)
			if(!user.transferItemToLoc(D, src))
				return ITEM_INTERACT_BLOCKING
			balloon_alert(user, "вставка [D.declent_ru(GENITIVE)]")
			syringes += D
			recharge_newshot()
			update_appearance()
			playsound(loc, load_sound, 40)
			return ITEM_INTERACT_SUCCESS
		balloon_alert(user, "нет места!")
		return ITEM_INTERACT_BLOCKING
	return NONE

/obj/item/gun/syringe/blowgun
	name = "blowgun"
	desc = "Fire syringes at a short distance."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "blowgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "blowgun"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	worn_icon_state = "gun"
	has_syringe_overlay = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	base_pixel_x = 0
	pixel_x = 0
	force = 4
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/syringe/blowgun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] стреляет из [declent_ru(GENITIVE)]!"))
	user.adjustStaminaLoss(20, updating_stamina = FALSE)
	user.adjustOxyLoss(20)
