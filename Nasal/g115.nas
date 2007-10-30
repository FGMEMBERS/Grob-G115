# Only move flaps if voltage is sufficient

var flapsDown = controls.flapsDown;
controls.flapsDown = func(v){
	var volts = getprop("systems/electrical/outputs/flaps");
        flapsDown(volts > 8 ? v : 0);
}
