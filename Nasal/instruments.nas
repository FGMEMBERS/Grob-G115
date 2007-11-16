# set the timer for the selected function

UPDATE_PERIOD = 0;

instrumenttimers = func {

	settimer(gmeterUpdate, UPDATE_PERIOD);
	settimer(func {radiodisplay("comm[0]")}, UPDATE_PERIOD);
	settimer(func {radiodisplay("nav[0]")}, UPDATE_PERIOD);
	settimer(func {radiodisplay("nav[1]")}, UPDATE_PERIOD);
	settimer(WarningPanelUpdate, UPDATE_PERIOD);

}

# =============================== end timer stuff ===========================================

# =============================== G-Meter stuff =============================================

gmeterUpdate = func {

	GCurrent = props.globals.getNode("/accelerations/pilot-g[0]").getValue();
	GMin = props.globals.getNode("/accelerations/pilot-gmin[0]").getValue();
	GMax = props.globals.getNode("/accelerations/pilot-gmax[0]").getValue();

	if(GCurrent < GMin)
	{ if (GCurrent > -6) 
	  { setprop("/accelerations/pilot-gmin[0]", GCurrent);
          }
          else
          { setprop("/accelerations/pilot-gmin[0]", -6);
          }
	}
	elsif(GCurrent > GMax)
	{ if(GCurrent < 10) 
          { setprop("/accelerations/pilot-gmax[0]", GCurrent);
          }
          else
          { setprop("/accelerations/pilot-gmax[0]", 10);
          }
	}

	instrumenttimers();

}

# =============================== Warning Panel =============================================

WarningPanelUpdate = func {

	volts = props.globals.getNode("/systems/electrical/volts").getValue();
	genvolts = props.globals.getNode("/systems/electrical/alternator").getValue();
	fuel =  props.globals.getNode("/consumables/fuel/tank[0]/level-lbs").getValue()+ props.globals.getNode("/consumables/fuel/tank[1]/level-lbs").getValue();
	starter = props.globals.getNode("/controls/engines/engine/starter").getValue();
	dim = ( props.globals.getNode("/instrumentation/warning-panel/night").getValue() ? 0.5 : 1.0 );
	test = props.globals.getNode("/instrumentation/warning-panel/test").getValue();

	if ( (volts<25) or test )
	{
		lampnorm=getprop("/systems/electrical/outputs/lo-volt-warning") * dim * 0.041666;
		setprop("/instrumentation/warning-panel/lovolt-norm",lampnorm);
	} else {
		setprop("/instrumentation/warning-panel/lovolt-norm",0.0);
	}

	if ( (fuel<20) or test )
	{
		lampnorm=getprop("/systems/electrical/outputs/fuel-lo-lev") * dim * 0.041666;
		setprop("/instrumentation/warning-panel/fuel-norm",lampnorm);
	} else {
		setprop("/instrumentation/warning-panel/fuel-norm",0.0);
	}

	if ( (genvolts<25) or test )
	{
		lampnorm=volts * dim * 0.041666;
		setprop("/instrumentation/warning-panel/gen-norm",lampnorm);
	} else {
		setprop("/instrumentation/warning-panel/gen-norm",0.0);
	}

	if ( test )
	{
		lampnorm=getprop("/systems/electrical/outputs/fuel-lo-lev") * dim * 0.041666;
		setprop("/instrumentation/warning-panel/looil-norm",lampnorm);
	} else {
		setprop("/instrumentation/warning-panel/looil-norm",0.0);
	}

	if ( starter or test )
	{
		lampnorm=getprop("/systems/electrical/outputs/starter[0]") * dim * 0.041666;
		setprop("/instrumentation/warning-panel/starter-norm",lampnorm);
	} else {
		setprop("/instrumentation/warning-panel/starter-norm",0.0);
	}

}

# ==================== Radio Frequency Display =========================

radiodisplay = func(radio) {
	selected=getprop("/instrumentation/"~radio~"/frequencies/selected-mhz");
	formatted=sprintf("%.02f",selected);

	digit1=substr(formatted,0,1);
	digit2=substr(formatted,1,1);
	digit3=substr(formatted,2,1);
	digit4=substr(formatted,4,1);
	digit5=substr(formatted,5,1);

	setprop("instrumentation/"~radio~"/selected/digit1",digit1);
	setprop("instrumentation/"~radio~"/selected/digit2",digit2);
	setprop("instrumentation/"~radio~"/selected/digit3",digit3);
	setprop("instrumentation/"~radio~"/selected/digit4",digit4);
	setprop("instrumentation/"~radio~"/selected/digit5",digit5);

	standby=getprop("/instrumentation/"~radio~"/frequencies/standby-mhz");
	formatted=sprintf("%.02f",standby);

	digit1=substr(formatted,0,1);
	digit2=substr(formatted,1,1);
	digit3=substr(formatted,2,1);
	digit4=substr(formatted,4,1);
	digit5=substr(formatted,5,1);
	
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

	### Initialise Warning Panel ###
	props.globals.getNode("/instrumentation/warning-panel/test", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/warning-panel/night", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/warning-panel/lovolt-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/gen-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/looil-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/fuel-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/starter-norm", 1).setDoubleValue(0.0);

	### Initialise Radio stuff ###
	props.globals.getNode("instrumentation/uhf/commvol-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("instrumentation/kn53/navvol-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("instrumentation/kx155a/commvol-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("instrumentation/kx155a/navvol-norm", 1).setDoubleValue(0.0);

	### Initialise electrical stuff  (move to electric system init once electrical system exists complete) ###
	props.globals.getNode("controls/circuit-breakers/start-ctrl", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/gen-ctrl", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/strobe-white", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/strobe-red", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/panel-lights", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/avionic-blower", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/pitot-heat", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/fuel-pump", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/eng-instr-2", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/gps", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/com2-nav2", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/avionic-bus-2", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/dme", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/audio-marker", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/att-indic-2", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/land-light", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/map-light", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/nav-lights", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/eng-instr-1", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/instr-lights", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/rpm-ind", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/lo-volt-warning", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/tands", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/fuel-lo-lev", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/att-indic-1", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/stall-warning", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/ess-bus", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/main-bus", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/gen", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/avionic-relay", 1).setBoolValue(1);
	props.globals.getNode("controls/circuit-breakers/flaps", 1).setBoolValue(1);

	instrumenttimers();
	# Finished Initialising
	print ("Instruments : initialised");
	initialized = 1;

} #end func

######################### Fire it up ############################################
setlistener("/sim/signals/fdm-initialized",initialize);
