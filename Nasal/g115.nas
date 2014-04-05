# Only move flaps if voltage is sufficient

var flapsDown = controls.flapsDown;
controls.flapsDown = func(v){
  var volts = getprop("systems/electrical/outputs/flaps");
  print("Flap Volts: ",volts);
        flapsDown(volts > 16 ? v : 0);
}

var startEngine = controls.startEngine;
controls.startEngine = func(){
        var volts = getprop("systems/electrical/outputs/starter[0]");
  print("Starter Volts: ",volts);
  if (volts > 16) {
    startEngine();
  }
}
