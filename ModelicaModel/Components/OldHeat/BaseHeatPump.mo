within HeatPumpModel.Components.OldHeat;
model BaseHeatPump "HP version 0.0, no implementation of ref cycle"
  // Condenser
//   replaceable package cond_medium =
//     Modelica.Media.Interfaces.PartialMedium
//     "Medium in the component"
//       annotation (choices(
//         choice(redeclare package Medium = Modelica.Media.Air           "Moist air"),
//         choice(redeclare package Medium =  Buildings.Media.Water
//                                                                 "Water"),
//         choice(redeclare package Medium =
//             Buildings.Media.Antifreeze.PropyleneGlycolWater (
//               property_T=293.15,
//               X_a=0.40)
//               "Propylene glycol water, 40% mass fraction")),
//               Dialog(group="Condenser"));

  replaceable package Cond_Medium = Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true,Dialog(group="Condenser"));

  replaceable parameter Real cond_efficiency = 0.9
  annotation(Dialog(group="Condenser"));
  parameter Modelica.Units.SI.MassFlowRate cond_m_flow_nominal
  annotation(Dialog(group="Condenser"));
  // Evaporator
//   replaceable package ev_medium =
//    Modelica.Media.Interfaces.PartialMedium
//     "Medium in the component"
//       annotation (choices(
//         choice(redeclare package Medium = Buildings.Media.Air "Moist air"),
//         choice(redeclare package Medium = Buildings.Media.Water "Water"),
//         choice(redeclare package Medium =
//             Buildings.Media.Antifreeze.PropyleneGlycolWater (
//               property_T=293.15,
//               X_a=0.40)
//               "Propylene glycol water, 40% mass fraction")),
//               Dialog(group="Evaporator"));

  replaceable package Eva_Medium = Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true,Dialog(group="Evaporator"));

  replaceable parameter Real ev_efficiency = 0.9
  annotation(Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.MassFlowRate ev_m_flow_nominal
  annotation(Dialog(group="Evaporator"));

  HeatPumpTests.Components.EvaporatorCondenserFixedTempFlow condenser(
    redeclare package Medium = Cond_Medium,
    efficiency=cond_efficiency,
    m_flow_nominal=cond_m_flow_nominal,
    dp_nominal=0)
    annotation (Placement(transformation(extent={{-4,42},{16,62}})));
  HeatPumpTests.Components.EvaporatorCondenserFixedTempFlow evaporator(
    redeclare package Medium = Eva_Medium,
    efficiency=ev_efficiency,
    m_flow_nominal=ev_m_flow_nominal,
    dp_nominal=0)
    annotation (Placement(transformation(extent={{-26,-52},{-6,-72}})));
  HeatPumpTests.Components.CompressorConstantEquationFit compressorConstantEquationFit
    annotation (Placement(transformation(extent={{-30,-12},{-10,8}})));
  Modelica.Fluid.Interfaces.FluidPort_a CondEF
    annotation (Placement(transformation(extent={{-70,90},{-50,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a EvEF
    annotation (Placement(transformation(extent={{-70,-110},{-50,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_b CondExF
    annotation (Placement(transformation(extent={{50,90},{70,110}})));
  Modelica.Fluid.Interfaces.FluidPort_b EvExF
    annotation (Placement(transformation(extent={{50,-110},{70,-90}})));
  Modelica.Blocks.Interfaces.RealOutput HR
    annotation (Placement(transformation(extent={{96,26},{116,46}})));
  Modelica.Blocks.Interfaces.RealOutput HE
    annotation (Placement(transformation(extent={{96,-46},{116,-26}})));
  Modelica.Blocks.Interfaces.RealOutput PEl
    annotation (Placement(transformation(extent={{96,-12},{116,8}})));
  Modelica.Blocks.Interfaces.IntegerInput OnOff
    annotation (Placement(transformation(extent={{-126,-20},{-86,20}})));

equation
  connect(condenser.RefT,compressorConstantEquationFit. T_cond) annotation (
      Line(points={{16.6,44.6},{20,44.6},{20,68},{-38,68},{-38,-6},{-30.8,-6}},
                                                             color={0,0,127}));
  connect(evaporator.RefT,compressorConstantEquationFit. T_ev) annotation (
      Line(points={{-5.4,-54.6},{4,-54.6},{4,-78},{-30.8,-78},{-30.8,-10.4}},
        color={0,0,127}));
  connect(compressorConstantEquationFit.Q_flow_ev,evaporator. HeatFlow)
    annotation (Line(points={{-20,-12.6},{-19.5,-12.6},{-19.5,-51.5}},
        color={0,0,127}));
  connect(compressorConstantEquationFit.Q_flow_cond,condenser. HeatFlow)
    annotation (Line(points={{-20,8.4},{-20,36},{2.5,36},{2.5,41.5}},
                                                                   color={0,0,
          127}));
  connect(EvEF, EvEF)
    annotation (Line(points={{-60,-100},{-60,-100}}, color={0,127,255}));
  connect(EvExF, EvExF)
    annotation (Line(points={{60,-100},{60,-100}}, color={0,127,255}));
  connect(compressorConstantEquationFit.Pel, PEl)
    annotation (Line(points={{-9.4,-2},{106,-2}}, color={0,0,127}));
  connect(compressorConstantEquationFit.Q_flow_cond, HR)
    annotation (Line(points={{-20,8.4},{-20,36},{106,36}}, color={0,0,127}));
  connect(compressorConstantEquationFit.Q_flow_ev, HE) annotation (Line(points={
          {-20,-12.6},{-20,-36},{106,-36}}, color={0,0,127}));
  connect(CondEF, CondEF)
    annotation (Line(points={{-60,100},{-60,100}}, color={0,127,255}));
  connect(evaporator.port_b, EvExF)
    annotation (Line(points={{-6,-62},{60,-62},{60,-100}}, color={0,127,255}));
  connect(evaporator.port_a, EvEF) annotation (Line(points={{-26,-62},{-60,-62},
          {-60,-100}}, color={0,127,255}));
  connect(CondEF, condenser.port_a)
    annotation (Line(points={{-60,100},{-60,52},{-4,52}}, color={0,127,255}));
  connect(CondExF, condenser.port_b)
    annotation (Line(points={{60,100},{60,52},{16,52}}, color={0,127,255}));
  connect(OnOff, compressorConstantEquationFit.Mode) annotation (Line(points={{-106,
          0},{-40,0},{-40,2},{-30.6,2}}, color={255,127,0}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end BaseHeatPump;
