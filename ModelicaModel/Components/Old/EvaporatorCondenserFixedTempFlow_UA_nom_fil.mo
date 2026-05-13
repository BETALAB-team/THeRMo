within HeatPumpModel.Components;
model EvaporatorCondenserFixedTempFlow_UA_nom_fil
  "Evaporator or condenser with refrigerant experiencing constant temperature phase change"
  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final
      Buildings.Fluid.MixingVolumes.MixingVolume vol(final
        prescribedHeatFlowRate=false, nPorts=3));

  replaceable parameter Real UA_nom  = 1000 "Heat transfer/ area product";

  Modelica.Blocks.Interfaces.RealOutput Q_flow(unit="W")
    "Heat added to the fluid"
    annotation (Placement(transformation(extent={{100,30},{120,50}})));

  Real m_flow_safe( unit = "kg/s")   "Safe value of m_flo if m_flow = 0";

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-70})));
  Modelica.Blocks.Interfaces.RealInput HeatFlow(unit="W") annotation (Placement(
        transformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-37,-107}), iconTransformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-37,-107})));
  Modelica.Blocks.Sources.RealExpression realExpression(y=SensEF.T + HeatFlow
        /(efficiency*m_flow_safe*cp))
    annotation (Placement(transformation(extent={{42,-62},{62,-42}})));

  Modelica.Blocks.Interfaces.RealOutput RefT(unit="K") "Medium temperature"
    annotation (Placement(transformation(extent={{100,-62},{120,-42}})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium =
        Medium, warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{-4,-80},{16,-60}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium =
        Medium, warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{26,60},{46,80}})));
  Modelica.Blocks.Interfaces.RealOutput T_out(unit="K") "Medium temperature"
    annotation (Placement(transformation(extent={{100,60},{120,80}})));

  Modelica.Units.SI.SpecificHeatCapacity cp=
      Medium.specificHeatCapacityCp(sta_default)
    "Density, used to compute fluid volume";

  Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heaFlo
    "Heat flow sensor"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-40})));
  Real efficiency "HE efficiency";
  Real NTU "Number of transfer unit";
  Modelica.Blocks.Interfaces.RealOutput T_in "Temperature in port medium"
    annotation (Placement(transformation(extent={{100,-88},{120,-68}}),
        iconTransformation(extent={{100,-88},{120,-68}})));
   Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = T_cost_eva,
    initType=Modelica.Blocks.Types.Init.SteadyState,
    y_start=Medium.T_default)
    annotation (Placement(transformation(extent={{70,-62},{90,-42}})));
  parameter Modelica.Units.SI.Time T_cost_eva(displayUnit="min") = 900
    "Time Constant";
  parameter Modelica.Units.SI.Volume V=m_flow_nominal*tau/rho_default "Volume";
equation
  m_flow_safe  = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4,1e-5);
  NTU = UA_nom/(m_flow_safe * cp);
  efficiency = 1 - Modelica.Constants.e^(-NTU);

  connect(heaFlo.port_b, vol.heatPort) annotation (Line(points={{-36,-30},{-36,
          -30},{-36,-10},{-9,-10}}, color={191,0,0}));
  connect(heaFlo.Q_flow, Q_flow) annotation (Line(points={{-25,-40},{-25,-40},{60,
          -40},{60,40},{110,40}},    color={0,0,127}));
  connect(preHeaFlo.port, heaFlo.port_a)
    annotation (Line(points={{-36,-60},{-36,-50}}, color={191,0,0}));
  connect(preHeaFlo.Q_flow, HeatFlow) annotation (Line(points={{-36,-80},{-36,
          -92},{-37,-92},{-37,-107}},
                                 color={0,0,127}));
  connect(port_a,SensEF. port)
    annotation (Line(points={{-100,0},{-64,0},{-64,-122},{6,-122},{6,-80}},
                                                         color={0,127,255}));
  connect(SensExF.port, vol.ports[3])
    annotation (Line(points={{36,60},{36,0},{1,0}}, color={0,127,255}));
  connect(SensExF.T, T_out)
    annotation (Line(points={{43,70},{110,70}}, color={0,0,127}));
  connect(SensEF.T, T_in) annotation (Line(points={{13,-70},{62,-70},{62,-78},{
          110,-78}}, color={0,0,127}));
  connect(RefT, firstOrder.y) annotation (Line(points={{110,-52},{104.5,-52},{
          104.5,-52},{91,-52}}, color={0,0,127}));
  connect(realExpression.y, firstOrder.u)
    annotation (Line(points={{63,-52},{68,-52}}, color={0,0,127}));
  annotation (
defaultComponentName="evaCon",
Documentation(info="<html>
<p>
Model for a constant temperature evaporator or condenser based on a &epsilon;-NTU
heat exchanger model.
</p>
<p>
The heat exchanger effectiveness is calculated from the number of transfer units
(NTU):
</p>
<p align=\"center\" style=\"font-style:italic;\">
&epsilon; = 1 - exp(UA &frasl; (m&#775; c<sub>p</sub>))
</p>
<p>
Optionally, this model can have a flow resistance.
If no flow resistance is requested, set <code>dp_nominal=0</code>.
</p>
<h4>Limitations</h4>
<p>
This model does not consider any superheating or supercooling on the refrigerant
side. The refrigerant is considered to exchange heat at a constant temperature
throughout the heat exchanger.
</p>
</html>",
revisions="<html>
<ul>
<li>
March 7, 2022, by Michael Wetter:<br/>
Removed <code>massDynamics</code>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1542\">#1542</a>.
</li>
<li>
May 27, 2017, by Filip Jorissen:<br/>
Regularised heat transfer around zero flow.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/769\">#769</a>.
</li>
<li>
April 12, 2017, by Michael Wetter:<br/>
Corrected invalid syntax for computing the specific heat capacity.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/707\">#707</a>.
</li>
<li>
October 11, 2016, by Massimo Cimmino:<br/>
First implementation.
</li>
</ul>
</html>"));
end EvaporatorCondenserFixedTempFlow_UA_nom_fil;
