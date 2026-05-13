within HeatPumpModel.Components.ReversibleHP;
model PlateHE_vs_1 "Exponential UA formulation as function of mass flow rates"

  // ------------Extend existing component---------------------------------------------------------------------------------------------------------------------------------------------------------

  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final Buildings.Fluid.MixingVolumes.MixingVolume vol(
      V=V,
      final prescribedHeatFlowRate=true,
      nPorts=3));

  // ------------Obtain polynomial coefficients---------------------------------------------------------------------------------------------------------------------------------------------------
  inner parameter ExternData.XLSXFile dataHeat(fileName=fileNameH) annotation (Placement(transformation(extent={{-30,26},{-10,46}})));
  Real m_coeff_H[6]=vector(
      dataSource.getRealArray2D(
        "A2",
        "Polynomials",
        6,
        1));

  inner parameter ExternData.XLSXFile dataCool(fileName=fileNameC) annotation (Placement(transformation(extent={{-30,54},{-10,74}})));
  Real m_coeff_C[6]=vector(
      dataSource.getRealArray2D(
        "A2",
        "Polynomials",
        6,
        1));

  // ------------Define input variables------------------------------------------------------------------------------------------------------------------------------------------------------------

  Real m_flow_rel(unit="kg/s") "relative secondary fluid flow rate";
  Real m_ref_rel(unit="kg/s") "relative srefrigerant fluid flow rate";
  Real m_flow_safe(unit="kg/s") "Safe value of m_flo if m_flow = 0";
  Real m_ref(unit="kg/s") "refrigerant mass flow";
  Real efficiency "HE efficiency";
  Real NTU "Number of transfer unit";
  Real UA "Heat transfer/ area product";
  Real UA_nom "nominal Heat transfer/ area product";
  Real Pow_sec(unit="W") "Heat capacity calculated in the secondary side";
  Real T_ref( unit = "K") "refrigerant temperature";
  Real HeatFlow( unit="W") "heatflow";

  // ------------Define input parameters-----------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String fileNameH;
  parameter String fileNameC;
  parameter String UA_value_PHE="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"));
  parameter Real m_ref_nom_H(unit="kg/s") "Nominal refrigerant mass flow rate [kg/s]";
  parameter Real m_ref_nom_C(unit="kg/s") "Nominal refrigerant mass flow rate [kg/s]";
  parameter Real m_f_nom_H(unit="kg/s") "Nominal flow mass flow rate heating [kg/s]";
  parameter Real m_f_nom_C(unit="kg/s") "Nominal flow mass flow rate cooling [kg/s]";
  parameter Real UA_nom_heat(unit="W/K") "Nominal UA value heating";
  parameter Real UA_nom_cool(unit="W/K") "Nominal UA value cooling";
  parameter Modelica.Units.SI.Time Tau_cost_PHE(displayUnit="min") = 900 "Time Constant of Condenser";
  parameter Modelica.Units.SI.Volume V "Volume";


  // ------------Define blocks-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,-42})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{-74,22},{-54,42}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{28,20},{48,40}})));
  Modelica.Units.SI.SpecificHeatCapacity cp=Medium.specificHeatCapacityCp(sta_default) "Density, used to compute fluid volume";
  Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = Tau_cost_PHE,
    initType=Modelica.Blocks.Types.Init.SteadyState,
    y_start=Medium.T_default) annotation (Placement(transformation(extent={{-76,-82},{-56,-62}})));
  Modelica.Blocks.Routing.DeMultiplex2 deMultiplex2 annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={18,-84})));
  Modelica.Blocks.Sources.RealExpression TrefValue(y=T_ref) annotation (Placement(transformation(extent={{-106,-82},{-86,-62}})));
  Modelica.Blocks.Sources.RealExpression HeatFlowValue(y=HeatFlow) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,-72})));

  // ------------Define blocks input and output----------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.RealInput HE_input[2](unit="W") annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112}), iconTransformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112})));
  Modelica.Blocks.Interfaces.RealOutput RefT_filter(unit="K") "Medium temperature filtered" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-40}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-40})));
  Modelica.Blocks.Interfaces.RealOutput Pow_secondary(unit="W") = Pow_sec "Heat transferred ore removed to the secondary fluid"
    annotation (Placement(transformation(extent={{100,-52},{120,-32}}), iconTransformation(extent={{100,-52},{120,-32}})));
  Modelica.Blocks.Interfaces.IntegerInput HP_operative_status annotation (Placement(transformation(extent={{-122,68},{-100,90}}), iconTransformation(extent={{-122,68},{-100,90}})));

  // =================EQUATION BLOCK===============================================================================================================================================================


equation

  // ------------Relative mass flow calculation----------------------------------------------------------------------------------------------------------------------------------------------------

  m_ref = deMultiplex2.y2[1];
  m_flow_safe = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4, 1e-5);
  if HP_operative_status ==1 then
    m_flow_rel = m_flow_safe/m_f_nominal_H;
    m_ref_rel = m_ref/m_ref_nom_H;
  else
    m_flow_rel = m_flow_safe/m_f_nominal_C;
    m_ref_rel = m_ref/m_ref_nom_C;
  end if;

  // ------------Selection of calculation of UA method---------------------------------------------------------------------------------------------------------------------------------------------

  if UA_value_PHE == "Nominal value" then
    UA = UA_nom;
  elseif UA_value_PHE == "Parametric correlation" then
    if HP_operative_status ==1 then
      UA = Buildings.Utilities.Math.Functions.smoothMax((m_coeff_H[1]+ m_coeff_H[2] * m_ref_rel + m_coeff_H[3]* m_ref_rel ^2 + m_coeff_H[4]* m_flow_rel +
           m_coeff_H[5]* m_flow_rel^2 +  m_coeff_H[6] * m_ref_rel * m_flow_rel)*UA_nom,1e-4,1e-5);
    else
      UA = Buildings.Utilities.Math.Functions.smoothMax((m_coeff_C[1]+ m_coeff_C[2] * m_ref_rel + m_coeff_C[3]* m_ref_rel ^2 + m_coeff_C[4]* m_flow_rel +
           m_coeff_C[5]* m_flow_rel^2 +  m_coeff_C[6] * m_ref_rel * m_flow_rel)*UA_nom,1e-4,1e-5);
    end if;
  end if;

  // ------------Evaluation of the efficency and CC -----------------------------------------------------------------------------------------------------------------------------------------------

  NTU = UA/(m_flow_safe*cp);
  if HP_operative_status ==1 then
      UA_nom = UA_nom_heat;
      HeatFlow = deMultiplex2.y1[1];
      T_ref = Buildings.Utilities.Math.Functions.smoothMax(SensEF.T + deMultiplex2.y1[1]/(efficiency*m_flow_safe*cp),SensExF.T,1e-5);
  else
      UA_nom = UA_nom_cool;
      HeatFlow = -deMultiplex2.y1[1];
      T_ref = Buildings.Utilities.Math.Functions.smoothMin(SensEF.T -deMultiplex2.y1[1]/(efficiency*m_flow_safe*cp),SensExF.T,1E-5);
  end if;

  efficiency = Buildings.Utilities.Math.Functions.smoothMax(
    1 - Modelica.Constants.e^(-NTU),
    1e-4,
    1e-5);
  Pow_sec = port_a.m_flow*cp*(SensExF.T - SensEF.T);

  connect(port_a, SensEF.port) annotation (Line(points={{-100,0},{-64,0},{-64,22}}, color={0,127,255}));
  connect(SensExF.port, vol.ports[3]) annotation (Line(points={{38,20},{38,0},{1,0}}, color={0,127,255}));
  connect(firstOrder.y, RefT_filter) annotation (Line(points={{-55,-72},{-42,-72},{-42,-40},{-110,-40}}, color={0,0,127}));
  connect(preHeaFlo.port, vol.heatPort) annotation (Line(points={{-22,-32},{-22,-10},{-9,-10}}, color={191,0,0}));
  connect(HE_input, deMultiplex2.u) annotation (Line(points={{0,-112},{0,-100},{18,-100},{18,-91.2}}, color={0,0,127}));
  connect(TrefValue.y, firstOrder.u) annotation (Line(points={{-85,-72},{-78,-72}}, color={0,0,127}));
  connect(preHeaFlo.Q_flow, HeatFlowValue.y) annotation (Line(points={{-22,-52},{-22,-61}}, color={0,0,127}));
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
end PlateHE_vs_1;
