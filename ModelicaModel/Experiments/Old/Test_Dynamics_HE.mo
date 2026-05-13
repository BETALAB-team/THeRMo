within HeatPumpModel.Experiments.Old;
model Test_Dynamics_HE
  Modelica.Blocks.Sources.Step step(
    height=1000,
    offset=0,
    startTime(displayUnit="min") = 420)
    annotation (Placement(transformation(extent={{-66,-54},{-46,-34}})));
  Modelica.Blocks.Sources.Step step1(
    height=20,
    offset=293,
    startTime(displayUnit="min") = 60)
    annotation (Placement(transformation(extent={{-68,34},{-48,54}})));
  Modelica.Fluid.Sources.MassFlowSource_T boundary(
    redeclare package Medium = Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T=293.15, X_a
          =0.10),
    use_T_in=true,
    m_flow=0.1,
    nPorts=1)
    annotation (Placement(transformation(extent={{-20,32},{0,52}})));

  Modelica.Fluid.Sources.Boundary_pT boundary1(redeclare package Medium =
        Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T=293.15, X_a
          =0.10), nPorts=1)
    annotation (Placement(transformation(extent={{8,46},{28,66}})));
  Components.EvaporatorCondenserFixedTempFlow_UA_nom evaCon(
    redeclare package Medium = Buildings.Media.Antifreeze.PropyleneGlycolWater
        (property_T=293.15, X_a=0.40)
      "Propylene glycol water, 40% mass fraction",
    m_flow_nominal=0.1,
    dp_nominal=0,
    UA_nom=1000) annotation (Placement(transformation(extent={{8,16},{28,36}})));
equation
  connect(step1.y, boundary.T_in) annotation (Line(points={{-47,44},{-30,44},{-30,
          46},{-22,46}}, color={0,0,127}));
  connect(boundary.ports[1], evaCon.port_a)
    annotation (Line(points={{0,42},{4,42},{4,26},{8,26}}, color={0,127,255}));
  connect(evaCon.port_b, boundary1.ports[1]) annotation (Line(points={{28,26},{
          34,26},{34,56},{28,56}}, color={0,127,255}));
  connect(step.y, evaCon.HeatFlow) annotation (Line(points={{-45,-44},{14.3,-44},
          {14.3,15.3}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=600, __Dymola_Algorithm="Dassl"));
end Test_Dynamics_HE;
