within HeatPumpModel.Components.ReversibleHP.Validation;
model Test_Control
  Control_vs_1 control_vs_1(
    Tset=20,
    DeltaTup=5,
    DeltaTlow=-5,
    controllerType_heat=Modelica.Blocks.Types.SimpleController.PID,
    controllerType_cool=Modelica.Blocks.Types.SimpleController.PID,
    f_nominal=60) annotation (Placement(transformation(extent={{-12,-20},{24,20}})));
  Modelica.Blocks.Sources.Sine sine(amplitude=50, f(displayUnit="s-1") = 0.05) annotation (Placement(transformation(extent={{-74,-10},{-54,10}})));
equation
  connect(sine.y, control_vs_1.Tmeas) annotation (Line(points={{-53,0},{-13.44,0}}, color={0,0,127}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=20, __Dymola_Algorithm="Dassl"));
end Test_Control;
