within HeatPumpModel.Experiments.Old;
model BaseHP_Test_vs_3_Tcost "Test BaseHP with constant input e variable speed"
  import Modelica;
  Modelica.Blocks.Math.RealToInteger realToInteger1
    annotation (Placement(transformation(extent={{-38,-6},{-28,4}})));
  Components.BaseHP_vs_5 baseHP_vs_5(
    redeclare package cond_medium = Modelica.Media.Water.StandardWaterOnePhase,
    efficiency_cond=0.7,
    m_flow_cond_nominal=1,
    dp__cond_nominal=0,
    redeclare package eva_medium =
        Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T = 293.15,X_a = 0.40),
    efficiency_eva=0.7,
    m_flow_eva_nominal=0.9,
    dp__eva_nominal=0)
    annotation (Placement(transformation(extent={{0,-14},{26,10}})));
  Modelica.Fluid.Sources.MassFlowSource_T Load(
    redeclare package Medium = Modelica.Media.Water.StandardWaterOnePhase,
    use_m_flow_in=false,
    m_flow=1,
    T(displayUnit="degC") = 303.15,
    nPorts=1) annotation (Placement(transformation(extent={{-42,18},{-22,38}})));
  Modelica.Fluid.Sources.MassFlowSource_T Source(
    redeclare package Medium = Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T = 293.15,X_a = 0.40),
    use_m_flow_in=false,
    use_T_in=false,
    m_flow=0.9,
    T=266.15,
    nPorts=1)
    annotation (Placement(transformation(extent={{-44,-42},{-24,-22}})));
  Modelica.Fluid.Sources.Boundary_ph Load_Volume(redeclare package Medium =
        Modelica.Media.Water.StandardWaterOnePhase, nPorts=1)
    annotation (Placement(transformation(extent={{0,48},{20,68}})));
  Modelica.Fluid.Sources.Boundary_ph Source_Volume(redeclare package Medium =
        Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T = 293.15,X_a = 0.40),
                                                    nPorts=1)
    annotation (Placement(transformation(extent={{24,-58},{44,-38}})));
  Modelica.Fluid.Sensors.Temperature T_load_out(redeclare package Medium =
        Modelica.Media.Water.StandardWaterOnePhase)
    annotation (Placement(transformation(extent={{68,18},{88,38}})));
  Modelica.Fluid.Sensors.Temperature T_source_out(redeclare package Medium =
        Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T = 293.15,X_a = 0.40))
    annotation (Placement(transformation(extent={{70,-24},{90,-4}})));
  Modelica.Blocks.Sources.RealExpression Wel(y=1)
    annotation (Placement(transformation(extent={{-72,-14},{-48,8}})));
  Modelica.Blocks.Sources.RealExpression frequency(y=50)
    annotation (Placement(transformation(extent={{-72,4},{-48,26}})));
equation
  connect(realToInteger1.y, baseHP_vs_5.OnOff) annotation (Line(points={{-27.5,
          -1},{-27.5,-2},{-6,-2},{-6,-4.16},{-4.16,-4.16}}, color={255,127,0}));
  connect(Load.ports[1], baseHP_vs_5.Load_in) annotation (Line(points={{-22,28},
          {9.62,28},{9.62,11.2}}, color={0,127,255}));
  connect(Source.ports[1], baseHP_vs_5.Source_in) annotation (Line(points={{-24,
          -32},{10.4,-32},{10.4,-15.44}}, color={0,127,255}));
  connect(Load_Volume.ports[1], baseHP_vs_5.Load_out) annotation (Line(points={
          {20,58},{28,58},{28,11.2},{16.9,11.2}}, color={0,127,255}));
  connect(Source_Volume.ports[1], baseHP_vs_5.Source_out) annotation (Line(
        points={{44,-48},{48,-48},{48,-20},{18.2,-20},{18.2,-15.44}}, color={0,
          127,255}));
  connect(baseHP_vs_5.Source_out, T_source_out.port) annotation (Line(points={{
          18.2,-15.44},{18.2,-20},{48,-20},{48,-30},{80,-30},{80,-24}}, color={
          0,127,255}));
  connect(T_load_out.port, baseHP_vs_5.Load_out) annotation (Line(points={{78,
          18},{78,11.2},{16.9,11.2}}, color={0,127,255}));
  connect(Wel.y, realToInteger1.u)
    annotation (Line(points={{-46.8,-3},{-42,-3},{-42,-1},{-39,-1}},
                                                   color={0,0,127}));
  connect(frequency.y, baseHP_vs_5.CMP_frequency) annotation (Line(points={{-46.8,
          15},{-46.8,14},{-12,14},{-12,1.36},{-3.12,1.36}},       color={0,0,
          127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=86400, __Dymola_Algorithm="Dassl"));
end BaseHP_Test_vs_3_Tcost;
