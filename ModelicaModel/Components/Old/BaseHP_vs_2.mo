within HeatPumpModel.Components;
model BaseHP_vs_2

 replaceable package Condenser_Medium =
      Modelica.Media.Interfaces.PartialMedium annotation (choicesAllMatching=true,Dialog(group="Condenser"));
  parameter Real efficiency_cond=0.9 annotation (Dialog(group="Condenser"));
 replaceable package Evaporator_Medium =
      Modelica.Media.Interfaces.PartialMedium annotation (choicesAllMatching=true,Dialog(group="Evaporator"));
  parameter Real efficiency_eva=0.9 annotation (Dialog(group="Evaporator"));

  Modelica.Blocks.Interfaces.IntegerInput OnOff annotation (Placement(
        transformation(extent={{-128,-14},{-86,28}}), iconTransformation(extent
          ={{-128,-14},{-86,28}})));
  Modelica.Blocks.Interfaces.RealOutput Pel
    annotation (Placement(transformation(extent={{110,6},{130,26}})));
  Modelica.Fluid.Interfaces.FluidPort_a Load_in(redeclare package Medium =
        Condenser_Medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-54,94},{-34,114}})));
  Modelica.Fluid.Interfaces.FluidPort_b Load_outr(redeclare package Medium =
        Condenser_Medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{18,94},{38,114}})));
  Modelica.Fluid.Interfaces.FluidPort_a Source_in(redeclare package Medium =
        Evaporator_Medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-44,-114},{-24,-94}})));
  Modelica.Fluid.Interfaces.FluidPort_b Source_out(redeclare package Medium =
        Evaporator_Medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{48,-114},{68,-94}})));
  Modelica.Blocks.Interfaces.RealOutput CC
    annotation (Placement(transformation(extent={{102,-42},{122,-22}})));
  Modelica.Blocks.Interfaces.RealOutput HC
    annotation (Placement(transformation(extent={{104,22},{124,42}})));
  parameter Modelica.Units.SI.MassFlowRate m_cond_nominal
    "Nominal mass flow rate" annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.PressureDifference dp__cond_nominal = 0
    "Pressure difference" annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.MassFlowRate m_eva_nominal
    "Nominal mass flow rate" annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.PressureDifference dp_eva_nominal = 0
    "Pressure difference" annotation (Dialog(group="Evaporator"));
  EvaporatorCondenserFixedTempFlow Condenser(redeclare package Medium =
        Condenser_Medium, efficiency=efficiency_cond)
    annotation (Placement(transformation(extent={{-10,46},{10,66}})));
  EvaporatorCondenserFixedTempFlow Evaporator(redeclare package Medium =
        Evaporator_Medium, efficiency=efficiency_eva)
    annotation (Placement(transformation(extent={{-10,-42},{10,-62}})));


  CompressorConstantEquationFit compressorConstantEquationFit
    annotation (Placement(transformation(extent={{-14,-8},{6,12}})));
  Modelica.Blocks.Interfaces.RealOutput m_ref "refrigerant mass flow rate"
    annotation (Placement(transformation(extent={{110,-18},{130,2}})));
equation
  connect(Pel, Pel)
    annotation (Line(points={{120,16},{120,16}},
                                               color={0,0,127}));
  connect(Source_in, Source_in)
    annotation (Line(points={{-34,-104},{-34,-104}}, color={0,127,255}));
  connect(Load_in, Condenser.port_a)
    annotation (Line(points={{-44,104},{-44,56},{-10,56}}, color={0,127,255}));
  connect(Condenser.port_b, Load_outr)
    annotation (Line(points={{10,56},{28,56},{28,104}}, color={0,127,255}));
  connect(Source_in, Evaporator.port_a) annotation (Line(points={{-34,-104},{-34,
          -52},{-10,-52}}, color={0,127,255}));
  connect(Evaporator.port_b, Source_out)
    annotation (Line(points={{10,-52},{58,-52},{58,-104}}, color={0,127,255}));
  connect(compressorConstantEquationFit.HC, Condenser.HeatFlow) annotation (
      Line(points={{-4,12.4},{-3.5,14},{-3.5,45.5}}, color={0,0,127}));
  connect(compressorConstantEquationFit.CC, Evaporator.HeatFlow) annotation (
      Line(points={{-4,-8.6},{-3.5,-8.6},{-3.5,-41.5}}, color={0,0,127}));
  connect(compressorConstantEquationFit.Mode, OnOff) annotation (Line(points={{-14.6,
          6},{-82,6},{-82,7},{-107,7}}, color={255,127,0}));
  connect(compressorConstantEquationFit.Tcond, Condenser.RefT) annotation (Line(
        points={{-14.8,-2},{-36,-2},{-36,48.6},{10.6,48.6}}, color={0,0,127}));
  connect(Evaporator.RefT,compressorConstantEquationFit.Teva)  annotation (Line(
        points={{10.6,-44.6},{10.6,-44},{-36,-44},{-36,-6.4},{-14.8,-6.4}},
        color={0,0,127}));
  connect(compressorConstantEquationFit.Wel, Pel)
    annotation (Line(points={{6.6,4},{98,4},{98,16},{120,16}},
                                               color={0,0,127}));
  connect(compressorConstantEquationFit.HC, HC)
    annotation (Line(points={{-4,12.4},{-4,32},{114,32}}, color={0,0,127}));
  connect(compressorConstantEquationFit.CC, CC)
    annotation (Line(points={{-4,-8.6},{-4,-32},{112,-32}}, color={0,0,127}));
  connect(compressorConstantEquationFit.m_ref, m_ref) annotation (Line(points={
          {6.6,0},{98,0},{98,-10},{110,-10},{110,-8},{120,-8}}, color={0,0,127}));
end BaseHP_vs_2;
