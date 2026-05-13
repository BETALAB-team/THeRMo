within HeatPumpModel.Components.Cooling;
model Condenser_vs_2_cooling "This class corresponds to the Evaporator_vs_2 but in cooling mode. Thus, it becomes a condenser"

  // ------------Extend existing component--------------------------------------------------------------------------------------------------------------------------------------------------------

  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final Buildings.Fluid.MixingVolumes.MixingVolume vol(
      final V=V_cond_cool,
      prescribedHeatFlowRate=false,
      nPorts=3));

  // -------------Define input variables-----------------------------------------------------------------------------------------------------------------------------------------------------------

  Real efficiency "HE efficiency";
  Real NTU "Number of transfer unit";
  Real UA "Scaled Heat transfer coefficient on the actual air mass flow rate";
  Real m_flow_safe(unit="kg/s") "Safe value of m_flo if m_flow = 0";

  // ------------Define input parameters-----------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String UA_value_cond_cool="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"));
  parameter Modelica.Units.SI.Time Tau_cost_cond_cool(displayUnit="min") = 900 "Time Constant";
  parameter Modelica.Units.SI.Volume V_cond_cool "Volume";
  replaceable parameter Real UA_nom_cond_cool=1000 "Heat transfer/ area product";

  // ------------Define blocks-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-70})));
  Modelica.Blocks.Sources.RealExpression realExpression(y=Buildings.Utilities.Math.Functions.smoothMax(SensEF.T + HeatFlow/(efficiency*m_flow_safe*cp),SensExF.T,1e-5)) annotation (Placement(transformation(extent={{-94,42},{-74,62}})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{-88,10},{-68,30}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{26,60},{46,80}})));
  Modelica.Units.SI.SpecificHeatCapacity cp=Medium.specificHeatCapacityCp(sta_default) "Density, used to compute fluid volume";
  Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = Tau_cost_cond_cool,
    initType=Modelica.Blocks.Types.Init.InitialState,
    y_start=Medium.T_default) annotation (Placement(transformation(extent={{-64,42},{-44,62}})));

  // ------------Define blocks input and output----------------------------------------------------------------------------------------------------------------------------------------------------

    Modelica.Blocks.Interfaces.RealInput HeatFlow(unit="W") annotation (Placement(transformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-1,-111}), iconTransformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-1,-111})));
    Modelica.Blocks.Interfaces.RealOutput RefT(unit="K") "Medium temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,70}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-50})));

  // =================EQUATION BLOCK===============================================================================================================================================================

equation

  // ------------Mass flow calculation------------------------------------------------------------------------------------------------------------------------------------------------------------

  m_flow_safe = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4, 1e-5);

  // ------------Selection of calculation of UA method---------------------------------------------------------------------------------------------------------------------------------------------

  if UA_value_cond_cool == "Nominal value" then
    UA = UA_nom_cond_cool;
  elseif UA_value_cond_cool == "Parametric correlation" then
    UA = UA_nom_cond_cool*(m_flow_safe/m_flow_nominal)^0.8;
  end if;
  NTU = UA/(m_flow_safe*cp);

// ------------Evaluation of the efficency---------------------------------------------------------------------------------------------------------------------------------------------------------

  efficiency = Buildings.Utilities.Math.Functions.smoothMax(
    1 - Modelica.Constants.e^(-NTU),
    1e-4,
    1e-5);

  connect(preHeaFlo.Q_flow, HeatFlow) annotation (Line(points={{-36,-80},{-36,-92},{-1,-92},{-1,-111}}, color={0,0,127}));
  connect(port_a, SensEF.port) annotation (Line(points={{-100,0},{-78,0},{-78,10}}, color={0,127,255}));
  connect(SensExF.port, vol.ports[3]) annotation (Line(points={{36,60},{36,0},{1,0}}, color={0,127,255}));
  connect(RefT, firstOrder.y) annotation (Line(points={{-110,70},{-38,70},{-38,52},{-43,52}}, color={0,0,127}));
  connect(realExpression.y, firstOrder.u) annotation (Line(points={{-73,52},{-66,52}}, color={0,0,127}));
  connect(preHeaFlo.port, vol.heatPort) annotation (Line(points={{-36,-60},{-36,-10},{-9,-10}}, color={191,0,0}));
  annotation (defaultComponentName="evaCon", Documentation(info="<html>
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
</html>", revisions="<html>
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
end Condenser_vs_2_cooling;
