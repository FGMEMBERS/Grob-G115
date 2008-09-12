# set the timer for the selected function

var UPDATE_PERIOD = 0;

WP_timer = func {

	settimer(WarningPanelUpdate, UPDATE_PERIOD);

}

# =============================== end timer stuff ===========================================

WarningPanelUpdate = func {

	var volts = props.globals.getNode("/systems/electrical/volts").getValue();
	var genvolts = props.globals.getNode("/systems/electrical/alternator").getValue();
	var fuel =  props.globals.getNode("/consumables/fuel/tank[0]/level-lbs").getValue()+ props.globals.getNode("/consumables/fuel/tank[1]/level-lbs").getValue();
	var starter = props.globals.getNode("/controls/engines/engine/starter").getValue();
	var dim = ( props.globals.getNode("/instrumentation/warning-panel/night").getValue() ? 0.5 : 1.0 );
	var test = props.globals.getNode("/instrumentation/warning-panel/test").getValue();
	var lampnorm=0.0;

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

	WP_timer();

}

####################### Initialise ##############################################

initialize = func {

	### Initialise Warning Panel ###
	props.globals.getNode("/instrumentation/warning-panel/test", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/warning-panel/night", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/warning-panel/lovolt-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/gen-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/looil-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/fuel-norm", 1).setDoubleValue(0.0);
	props.globals.getNode("/instrumentation/warning-panel/starter-norm", 1).setDoubleValue(0.0);

	WP_timer();
	# Finished Initialising
	print ("Warning Panel : initialised");
	var initialized = 1;

} #end func

######################### Fire it up ############################################
setlistener("/sim/signals/electrical-initialized",initialize);
