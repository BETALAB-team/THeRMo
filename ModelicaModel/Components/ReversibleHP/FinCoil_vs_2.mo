within HeatPumpModel.Components.ReversibleHP;
model FinCoil_vs_2 "Reversible finned coil model with defrost block"

  // ------------Extend existing component--------------------------------------------------------------------------------------------------------------------------------------------------------

  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final Buildings.Fluid.MixingVolumes.BaseClasses.MixingVolumeHeatMoisturePort
                                                                                                                         vol(
      final V=V,
      prescribedHeatFlowRate = true,
      nPorts=4));

  // -------------Define input variables-----------------------------------------------------------------------------------------------------------------------------------------------------------

  Real efficiency "HE efficiency";
  Real NTU "Number of transfer unit";
  Real UA "Scaled Heat ransfer coefficient on the actual air mass flow rate";
  Real UA_nom "nominal Heat transfer/ area product";
  Real m_flow_safe(unit="kg/s") "Safe value of m_flo if m_flow = 0";
  Real T_ref( unit = "K") "refrigerant temperature";
  Real HeatFlow( unit = "W") "Heat flow";
  Real h_sat(  unit = "J/kg") "saturation enthalpy of the air at surface temperature == refrigerant temperature";
  Real T_ref_trial(unit = "degC") "T refrigerant trial ";

  // ------------Define input parameters-----------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String UA_value_FC="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"));
  parameter Modelica.Units.SI.Time Tau_cost_FC(displayUnit="min") = 900 "Time Constant";
  parameter Modelica.Units.SI.Volume V "Volume";
  parameter Real UA_nom_heat "Heat transfer/ area product in heating";
  parameter Real UA_nom_cool "Heat transfer/ area product in cooling";
  parameter Real m_f_nom_heat( unit = "kg/s") "nominal mass flow rate heating";
  parameter Real m_f_nom_cool( unit = "kg/s") "nominal mass flow rate cooling";

  // ------------Define blocks-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-32,-24})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{-78,-18},{-62,-6}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{28,32},{40,44}})));
  Modelica.Units.SI.SpecificHeatCapacity cp=Medium.specificHeatCapacityCp(sta_default) "Density, used to compute fluid volume";
  Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = Tau_cost_FC,
    initType=Modelica.Blocks.Types.Init.SteadyState,
    y_start=Medium.T_default) annotation (Placement(transformation(extent={{-60,60},{-40,80}})));

  Modelica.Blocks.Sources.RealExpression TrefValue(y=T_ref) annotation (Placement(transformation(extent={{-96,60},{-76,80}})));
  Modelica.Blocks.Sources.RealExpression HeatFlowValue(y=HeatFlow) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-32,-52})));
  Defrost_vs_1 defrost_vs_1 annotation (Placement(transformation(extent={{58,-84},{78,-64}})));
  Buildings.Fluid.Sensors.SpecificEnthalpy senSpeEnt(redeclare package Medium = Buildings.Media.Air "Moist air", warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{-72,20},{-60,30}})));
  Modelica.Blocks.Sources.RealExpression UA_tot(y=UA) "Assumed total UA aproximatly equal to UA of air (dominat thermal resistance)" annotation (Placement(transformation(extent={{22,-96},{42,-76}})));
  Buildings.Fluid.Sensors.MassFraction Xin(redeclare package Medium = Buildings.Media.Air "Moist air") annotation (Placement(transformation(extent={{-84,18},{-74,28}})));
  Buildings.Fluid.Sensors.MassFraction Xout(redeclare package Medium = Buildings.Media.Air "Moist air") annotation (Placement(transformation(extent={{50,4},{62,16}})));

  Buildings.Fluid.Sensors.SpecificEnthalpy senSpeEntOut(redeclare package Medium = Buildings.Media.Air "Moist air", warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{72,16},{84,26}})));

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
        origin={-108,98}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-50})));
   Modelica.Blocks.Interfaces.IntegerInput HP_operative_status annotation (Placement(transformation(extent={{-116,-62},{-100,-46}}),
                                                                                                                                  iconTransformation(extent={{-122,68},{-100,90}})));

  // =================EQUATION BLOCK===============================================================================================================================================================


equation

  // ------------Mass flow calculation-------------------------------------------------------------------------------------------------------------------------------------------------------------

  m_flow_safe = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4, 1e-5);

 // ------------Selection of calculation of UA method----------------------------------------------------------------------------------------------------------------------------------------------

  if HP_operative_status ==1 then
      UA_nom = UA_nom_heat;
      HeatFlow = -HE_input - defrost_vs_1.Qlatent;
      h_sat = Buildings.Utilities.Math.Functions.smoothMin(senSpeEnt.h_out + HeatFlow/(efficiency*m_flow_safe),senSpeEnt.h_out,1e-5);
      T_ref_trial =  -4.107546730803439e-08 * (h_sat/1000)^4 + 2.1895273437089793e-05 * (h_sat/1000)^3  -0.004834360421358121 * (h_sat/1000)^2 + 0.6631988148446378 * h_sat/1000 -5.829992392788608;
      T_ref =Buildings.Utilities.Math.Functions.smoothMin(T_ref_trial + 273.15,SensExF.T,1E-4);

  else
      UA_nom = UA_nom_cool;
      HeatFlow =  HE_input;
      h_sat = Buildings.Utilities.Math.Functions.smoothMax(senSpeEnt.h_out - HeatFlow/(efficiency*m_flow_safe),senSpeEnt.h_out,1e-5);
      T_ref_trial = -4.107546730803439e-08 * (h_sat/1000)^4 + 2.1895273437089793e-05 * (h_sat/1000)^3  -0.004834360421358121 * (h_sat/1000)^2 + 0.6631988148446378 * h_sat/1000 -5.829992392788608;
      T_ref =Buildings.Utilities.Math.Functions.smoothMax(T_ref_trial + 273.15,SensExF.T,1E-4);

  end if;

  if UA_value_FC == "Nominal value" then
    UA = UA_nom;
  elseif UA_value_FC == "Parametric correlation" then
    if HP_operative_status ==1 then
       UA = UA_nom*(m_flow_safe/m_f_nom_heat)^0.8;
    else
       UA = UA_nom*(m_flow_safe/m_f_nom_cool)^0.8;
    end if;
  end if;
  NTU = UA/(m_flow_safe*cp);

  // ------------Evaluation of the efficency---------------------------------------------------------------------------------------------------------------------------------------------------------

  efficiency = Buildings.Utilities.Math.Functions.smoothMax(
    1 - Modelica.Constants.e^(-NTU),
    1e-4,
    1e-5);

  connect(port_a, SensEF.port) annotation (Line(points={{-100,0},{-82,0},{-82,-22},{-70,-22},{-70,-18}},
                                                                                                       color={0,127,255}));
  connect(SensExF.port, vol.ports[3]) annotation (Line(points={{34,32},{34,0},{1,0}}, color={0,127,255}));
  connect(preHeaFlo.port, vol.heatPort) annotation (Line(points={{-32,-14},{-32,-10},{-9,-10}},                     color={191,0,0}));
  connect(firstOrder.y, RefT) annotation (Line(points={{-39,70},{-36,70},{-36,98},{-108,98}}, color={0,0,127}));
  connect(TrefValue.y, firstOrder.u) annotation (Line(points={{-75,70},{-62,70}}, color={0,0,127}));
  connect(HeatFlowValue.y, preHeaFlo.Q_flow) annotation (Line(points={{-32,-41},{-32,-34}}, color={0,0,127}));
  connect(firstOrder.y, defrost_vs_1.Tref) annotation (Line(points={{-39,70},{50,70},{50,-70},{57,-70}},
                                                                                                       color={0,0,127}));
  connect(UA_tot.y, defrost_vs_1.Gc1) annotation (Line(points={{43,-86},{54,-86},{54,-80.8},{57,-80.8}},
                                                                                                      color={0,0,127}));
  connect(senSpeEnt.port, preDro.port_a) annotation (Line(points={{-66,20},{-66,14},{-64,14},{-64,0},{-60,0}},                                            color={0,127,255}));
  connect(vol.X_w, defrost_vs_1.XInf1) annotation (Line(points={{13,-6},{28,-6},{28,-76},{57.2,-76}},   color={0,0,127}));
  connect(Xin.port, preDro.port_a) annotation (Line(points={{-79,18},{-79,0},{-60,0}},          color={0,127,255}));
  connect(Xout.port, port_b) annotation (Line(points={{56,4},{56,0},{100,0}},            color={0,127,255}));
  connect(vol.mWat_flow, defrost_vs_1.mWat_true) annotation (Line(points={{-11,-18},{-12,-18},{-12,-100},{84,-100},{84,-78.4},{79,-78.4}},
                                                                                                                                       color={0,0,127}));
  connect(defrost_vs_1.HP_operative_mode, HP_operative_status) annotation (Line(points={{57.1,-65.7},{-94,-65.7},{-94,-54},{-108,-54}}, color={255,127,0}));
  connect(HE_input, defrost_vs_1.HeatFlow) annotation (Line(points={{-35,-111},{-36,-111},{-36,-72},{54,-72},{54,-73.8},{57.2,-73.8}}, color={0,0,127}));
  connect(senSpeEntOut.port, vol.ports[4]) annotation (Line(points={{78,16},{80,16},{80,0},{1,0}}, color={0,127,255}));
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
end FinCoil_vs_2;
