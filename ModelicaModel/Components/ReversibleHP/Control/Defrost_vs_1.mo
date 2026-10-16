within HeatPumpModel.Components.ReversibleHP.Control;
model Defrost_vs_1 "Model for calculating the amount of condensate in the coil"
  // -------------Define variables-------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Real  mWatMax( unit = "kg/s") "maximum water mass flow rate allowed";
  Real mass_ice( unit = "kg") "mass of condensate";
  // -------------Define Blocks--------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Buildings.Fluid.HeatExchangers.BaseClasses.MassExchange massExchange(redeclare package Medium = Buildings.Media.Air)
  annotation (Placement(transformation(extent={{-6,-8},{14,12}})));
  Modelica.Blocks.Math.Gain LatentHeat(k=2501E3) "Latent heat water 0°C" annotation (Placement(transformation(extent={{30,-2},{38,6}})));
  Modelica.Blocks.Continuous.Integrator integrator(
    use_reset=true,
    use_set=false,                                 u = - mWat_true) annotation (Placement(transformation(extent={{-56,16},{-36,36}})));
  Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=272.15, uHigh=274.15) annotation (Placement(transformation(extent={{-52,46},{-38,60}})));
  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(extent={{-18,46},{-4,60}})));
  Modelica.Blocks.Sources.Constant const(k=0)
                                         annotation (Placement(transformation(extent={{-54,70},{-34,90}})));

  //-------------Input - Output blocks------------------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.RealInput Tref "Surface temperature" annotation (Placement(transformation(extent={{-118,-8},{-100,10}}), iconTransformation(extent={{-118,-8},{-100,10}})));
  Modelica.Blocks.Interfaces.RealInput Gc1 "Signal representing the convective (sensible) thermal conductance in [W/K]"
                                                                                                                       annotation (Placement(transformation(extent={{-118,-68},{-100,-50}}), iconTransformation(extent={{-118,
            -68},{-100,-50}})));
  Modelica.Blocks.Interfaces.RealInput XInf1 "Water mass fraction of medium" annotation (Placement(transformation(extent={{-118,-30},{-100,-12}}),
                                                                                                                                                 iconTransformation(extent={{-118,-30},{-100,-12}})));
  Modelica.Blocks.Interfaces.RealInput HeatFlow "compressor frequency" annotation (Placement(transformation(extent={{-120,50},{-100,70}}), iconTransformation(extent={{-116,50},{-100,66}})));
  Modelica.Blocks.Interfaces.RealOutput Qlatent(unit="W") annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Modelica.Blocks.Interfaces.RealOutput mWat_true( unit = "kg/s") annotation (Placement(transformation(extent={{100,-54},{120,-34}})));
  Modelica.Blocks.Interfaces.IntegerInput HP_operative_mode annotation (Placement(transformation(extent={{-118,-98},{-100,-80}}),
                                                                                                                                iconTransformation(extent={{-118,-98},{-100,-80}})));

  Modelica.Blocks.Interfaces.RealInput Tair annotation (Placement(transformation(extent={{-118,22},{-100,40}}), iconTransformation(extent={{-118,22},{-100,40}})));
  Modelica.Blocks.Interfaces.RealOutput m_ice "Connector of Real output signal" annotation (Placement(transformation(extent={{104,42},{124,62}})));
  Modelica.Blocks.Interfaces.BooleanInput Defrost annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-60,-110}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-60,-110})));
equation
  mWatMax = - HeatFlow /(2501*10^3);
  mass_ice = switch1.y;
  if abs(HeatFlow) > 1e-3 and HP_operative_mode == 1 then
     Qlatent =  Buildings.Utilities.Math.Functions.smoothMax(-HeatFlow, LatentHeat.y,1e-4);
     mWat_true =  Buildings.Utilities.Math.Functions.smoothMax(massExchange.mWat_flow,mWatMax,1e-4);
  else
    Qlatent = 0;
    mWat_true = 0;
  end if;

  connect(massExchange.TSur, Tref) annotation (Line(points={{-8,10},{-58,10},{-58,1},{-109,1}}, color={0,0,127}));
  connect(massExchange.Gc, Gc1) annotation (Line(points={{-8,-6},{-14,-6},{-14,-59},{-109,-59}}, color={0,0,127}));
  connect(massExchange.mWat_flow, LatentHeat.u) annotation (Line(points={{15,2},{29.2,2}}, color={0,0,127}));
  connect(massExchange.XInf, XInf1) annotation (Line(points={{-8,2},{-50,2},{-50,-20},{-98,-20},{-98,-21},{-109,-21}},
                                                                                               color={0,0,127}));
  connect(hysteresis.y, switch1.u2) annotation (Line(points={{-37.3,53},{-19.4,53}}, color={255,0,255}));
  connect(hysteresis.u, Tair) annotation (Line(points={{-53.4,53},{-94,53},{-94,31},{-109,31}}, color={0,0,127}));
  connect(integrator.y, switch1.u3) annotation (Line(points={{-35,26},{-22,26},{-22,47.4},{-19.4,47.4}}, color={0,0,127}));
  connect(const.y, switch1.u1) annotation (Line(points={{-33,80},{-26,80},{-26,58.6},{-19.4,58.6}}, color={0,0,127}));
  connect(switch1.y, m_ice) annotation (Line(points={{-3.3,53},{100,53},{100,52},{114,52}}, color={0,0,127}));
  connect(integrator.reset, Defrost) annotation (Line(points={{-40,14},{-40,-94},{-60,-94},{-60,-110}}, color={255,0,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)));
end Defrost_vs_1;
