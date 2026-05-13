within HeatPumpModel.Components.ReversibleHP;
model FinCoil_vs_1 "Reversible finned coil model"

  // ------------Extend existing component--------------------------------------------------------------------------------------------------------------------------------------------------------

  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final Buildings.Fluid.MixingVolumes.MixingVolume vol(
      final V=V,
      prescribedHeatFlowRate=false,
      nPorts=3));

  // -------------Define input variables-----------------------------------------------------------------------------------------------------------------------------------------------------------

  Real efficiency "HE efficiency";
  Real NTU "Number of transfer unit";
  Real UA "Scaled Heat ransfer coefficient on the actual air mass flow rate";
  Real UA_nom "nominal Heat transfer/ area product";
  Real m_flow_safe(unit="kg/s") "Safe value of m_flo if m_flow = 0";
  Real T_ref( unit = "K") "refrigerant temperature";
  Real HeatFlow( unit = "W") "Heat flow";
  // ------------Define input parameters-----------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String UA_value_FC="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"));
  parameter Modelica.Units.SI.Time Tau_cost_FC(displayUnit="min") = 900 "Time Constant";
  parameter Modelica.Units.SI.Volume V "Volume";
  parameter Real UA_nom_heat "Heat transfer/ area product in heating";
  parameter Real UA_nom_cool "Heat transfer/ area product in cooling";

  // ------------Define blocks-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-36})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{-76,-42},{-56,-22}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{26,60},{46,80}})));
  Modelica.Units.SI.SpecificHeatCapacity cp=Medium.specificHeatCapacityCp(sta_default) "Density, used to compute fluid volume";
  Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = Tau_cost_FC,
    initType=Modelica.Blocks.Types.Init.SteadyState,
    y_start=Medium.T_default) annotation (Placement(transformation(extent={{-62,30},{-42,50}})));

  Modelica.Blocks.Sources.RealExpression TrefValue(y=T_ref) annotation (Placement(transformation(extent={{-102,30},{-82,50}})));
  Modelica.Blocks.Sources.RealExpression HeatFlowValue(y=HeatFlow) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-68})));

  // ------------Define blocks input and output----------------------------------------------------------------------------------------------------------------------------------------------------

   Modelica.Blocks.Interfaces.RealInput HE_input(unit="W") annotation (Placement(transformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-35,-111}), iconTransformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-35,-111})));
   Modelica.Blocks.Interfaces.RealOutput RefT(unit="K") "Medium temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,68}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-50})));
   Modelica.Blocks.Interfaces.IntegerInput HP_operative_status annotation (Placement(transformation(extent={{-122,-72},{-100,-50}}),
                                                                                                                                  iconTransformation(extent={{-122,68},{-100,90}})));

  // =================EQUATION BLOCK===============================================================================================================================================================

equation

  // ------------Mass flow calculation-------------------------------------------------------------------------------------------------------------------------------------------------------------

  m_flow_safe = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4, 1e-5);

 // ------------Selection of calculation of UA method----------------------------------------------------------------------------------------------------------------------------------------------

  if HP_operative_status ==1 then
      UA_nom = UA_nom_heat;
      HeatFlow = -HE_input;
      T_ref = Buildings.Utilities.Math.Functions.smoothMin(SensEF.T + HeatFlow/(efficiency*m_flow_safe*cp),SensExF.T,1e-5);
  else
      UA_nom = UA_nom_cool;
      HeatFlow =  HE_input;
      T_ref = Buildings.Utilities.Math.Functions.smoothMax(SensEF.T + HeatFlow/(efficiency*m_flow_safe*cp),SensExF.T,1E-5);
  end if;

  if UA_value_FC == "Nominal value" then
    UA = UA_nom;
  elseif UA_value_FC == "Parametric correlation" then
    UA = UA_nom*(m_flow_safe/m_flow_nominal)^0.8;
  end if;
  NTU = UA/(m_flow_safe*cp);

  // ------------Evaluation of the efficency---------------------------------------------------------------------------------------------------------------------------------------------------------

  efficiency = Buildings.Utilities.Math.Functions.smoothMax(
    1 - Modelica.Constants.e^(-NTU),
    1e-4,
    1e-5);

  connect(port_a, SensEF.port) annotation (Line(points={{-100,0},{-82,0},{-82,-46},{-66,-46},{-66,-42}},
                                                                                                       color={0,127,255}));
  connect(SensExF.port, vol.ports[3]) annotation (Line(points={{36,60},{36,0},{1,0}}, color={0,127,255}));
  connect(preHeaFlo.port, vol.heatPort) annotation (Line(points={{-36,-26},{-36,-10},{-9,-10}},                     color={191,0,0}));
  connect(firstOrder.y, RefT) annotation (Line(points={{-41,40},{-38,40},{-38,68},{-110,68}}, color={0,0,127}));
  connect(TrefValue.y, firstOrder.u) annotation (Line(points={{-81,40},{-64,40}}, color={0,0,127}));
  connect(HeatFlowValue.y, preHeaFlo.Q_flow) annotation (Line(points={{-36,-57},{-36,-46}}, color={0,0,127}));
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
end FinCoil_vs_1;
