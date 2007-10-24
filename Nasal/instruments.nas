# set the timer for the selected function

UPDATE_PERIOD = 0;

instrumenttimers = func {

	settimer(gmeterUpdate, UPDATE_PERIOD);
	settimer(func {radiodisplay("comm[0]")}, UPDATE_PERIOD);
	settimer(func {radiodisplay("nav[0]")}, UPDATE_PERIOD);
	settimer(func {radiodisplay("nav[1]")}, UPDATE_PERIOD);
}

# =============================== end timer stuff ===========================================

# =============================== G-Meter stuff =============================================

gmeterUpdate = func {

	GCurrent = props.globals.getNode("/accelerations/pilot-g[0]").getValue();
	GMin = props.globals.getNode("/accelerations/pilot-gmin[0]").getValue();
	GMax = props.globals.getNode("/accelerations/pilot-gmax[0]").getValue();

	if(GCurrent < 1 and GCurrent < GMin){setprop("/accelerations/pilot-gmin[0]", GCurrent);}
	else {if(GCurrent > GMax){setprop("/accelerations/pilot-gmax[0]", GCurrent);}}

instrumenttimers();

}

# ==================== Radio Frequency Display =========================

radiodisplay = func(radio) {
	selected=getprop("/instrumentation/"~radio~"/frequencies/selected-mhz");
	digit1=int(selected/100);
	digit2=int((selected/10)-(10*digit1));
	digit3=int(selected-(100*digit1)-(10*digit2));
	digit4=int(10*(selected-int(selected)));
	digit5=int(10*(10*(selected-int(selected)))-(10*digit4));
	setprop("instrumentation/"~radio~"/selected/digit1",digit1);
	setprop("instrumentation/"~radio~"/selected/digit2",digit2);
	setprop("instrumentation/"~radio~"/selected/digit3",digit3);
	setprop("instrumentation/"~radio~"/selected/digit4",digit4);
	setprop("instrumentation/"~radio~"/selected/digit5",digit5);

	standby=getprop("/instrumentation/"~radio~"/frequencies/standby-mhz");
	digit1=int(standby/100);
	digit2=int((standby/10)-(10*digit1));
	digit3=int(standby-(100*digit1)-(10*digit2));
	digit4=int(10*(standby-int(standby)));
	digit5=int(10*(10*(standby-int(standby)))-(10*digit4));
	
	setprop("instrumentation/"~radio~"/standby/digit1",digit1);
	setprop("instrumentation/"~radio~"/standby/digit2",digit2);
	setprop("instrumentation/"~radio~"/standby/digit3",digit3);
	setprop("instrumentation/"~radio~"/standby/digit4",digit4);
	setprop("instrumentation/"~radio~"/standby/digit5",digit5);

}

####################### Initialise ##############################################

initialize = func {

	### Initialise gmeter stuff ###
	props.globals.getNode("accelerations/pilot-g[0]", 1).setDoubleValue(1.01);
	props.globals.getNode("accelerations/pilot-gmin[0]", 1).setDoubleValue(1);
	props.globals.getNode("accelerations/pilot-gmax[0]", 1).setDoubleValue(1);

	### Initialise Radio stuff ###
	props.globals.getNode("instrumentation/uhf/commvol-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("instrumentation/kn53/navvol-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("instrumentation/kx155a/commvol-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("instrumentation/kx155a/navvol-norm", 1).setDoubleValue(0.0);

	instrumenttimers();
	# Finished Initialising
	print ("Instruments : initialised");
	initialized = 1;

} #end func

######################### Fire it up ############################################
setlistener("/sim/signals/fdm-initialized",initialize);
