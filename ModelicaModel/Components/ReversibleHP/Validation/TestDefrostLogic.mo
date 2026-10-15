within HeatPumpModel.Components.ReversibleHP.Validation;
model TestDefrostLogic
  parameter Real t_def(unit="s") = 1200;
  parameter Real t_lock(unit="s") = 600;
  parameter Real p_def = 3 "bar";
  Real p_eva "bar";
  Boolean c_mode = true;
  Boolean c_p = p_eva < p_def;
  Boolean c_lock = (time >= t_lock) and (time >= pre(t_start) + t_def + t_lock);
  Boolean startCond = c_mode and c_p and c_lock;
  discrete Real t_start(unit="s", start=-1e9, fixed=true);
  Boolean defrost;
equation
  p_eva = 4 + 2*sin(2*Modelica.Constants.pi*time/3000);
  defrost = time < t_start + t_def;
  when startCond then
    t_start = time;
  end when;
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)));
end TestDefrostLogic;
