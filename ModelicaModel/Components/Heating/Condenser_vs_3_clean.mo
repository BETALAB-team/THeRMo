within HeatPumpModel.Components.Heating;
model Condenser_vs_3_clean "Exponential UA formulation as function of mass flow rates"

  // ------------Extend existing component---------------------------------------------------------------------------------------------------------------------------------------------------------

  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final Buildings.Fluid.MixingVolumes.MixingVolume vol(
      V=V,
      final prescribedHeatFlowRate=false,
      nPorts=3));

  // ------------Obtain polynomial coefficients---------------------------------------------------------------------------------------------------------------------------------------------------
  inner parameter ExternData.XLSXFile dataSource(fileName=fileName) annotation (Placement(transformation(extent={{-30,26},{-10,46}})));
  Real m_coeff[6]=vector(
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
  Real HC_sec(unit="W") "Heat capacity calculated in the secondary side";
  Real HC_ref(unit="W") "refrigerant heat capacity";
  //Real m_vector[5] = { m_ref_rel,m_ref_rel^2,m_flow_rel,m_flow_rel^2, m_ref_rel*m_flow_rel} "polynomial equation";

  // ------------Define input parameters-----------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String fileName=fileName_cond;
  parameter String UA_value_cond="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"));
  parameter Real m_ref_nom(unit="kg/s") "Nominal refrigerant mass flow rate [kg/s]";
  parameter Real UA_nom(unit="W/K") "Nominal UA value";
  parameter Modelica.Units.SI.Time Tau_cost_cond(displayUnit="min") = 900 "Time Constant of Condenser";
  parameter Modelica.Units.SI.Volume V "Volume";

  // ------------Define blocks-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,-50})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{-74,22},{-54,42}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{28,20},{48,40}})));
  Modelica.Units.SI.SpecificHeatCapacity cp=Medium.specificHeatCapacityCp(sta_default) "Density, used to compute fluid volume";
  Modelica.Blocks.Sources.RealExpression realExpression(y= Buildings.Utilities.Math.Functions.smoothMax(SensEF.T + HC_ref/(efficiency*m_flow_safe*cp),SensExF.T,1e-5)) annotation (Placement(transformation(extent={{-110,-82},{-90,-62}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = Tau_cost_cond,
    initType=Modelica.Blocks.Types.Init.SteadyState,
    y_start=Medium.T_default) annotation (Placement(transformation(extent={{-76,-82},{-56,-62}})));
  Modelica.Blocks.Routing.DeMultiplex2 deMultiplex2 annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={18,-84})));


  // ------------Define blocks input and output----------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.RealInput HC_tot[2](unit="W") annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112}), iconTransformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112})));
  Modelica.Blocks.Interfaces.RealOutput RefT(unit="K") "Medium temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-40}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-40})));
  Modelica.Blocks.Interfaces.RealOutput HC_secondary(unit="W") = HC_sec "Heat transferred to the secondary fluid"
    annotation (Placement(transformation(extent={{100,-52},{120,-32}}), iconTransformation(extent={{100,-52},{120,-32}})));

  // =================EQUATION BLOCK===============================================================================================================================================================


equation

  // ------------Relative mass flow calculation----------------------------------------------------------------------------------------------------------------------------------------------------

  m_ref = deMultiplex2.y2[1];
  m_flow_safe = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4, 1e-5);
  m_flow_rel = m_flow_safe/m_flow_nominal;
  m_ref_rel = m_ref/m_ref_nom;

  // ------------Selection of calculation of UA method---------------------------------------------------------------------------------------------------------------------------------------------

  if UA_value_cond == "Nominal value" then
    UA = UA_nom;
  elseif UA_value_cond == "Parametric correlation" then
    //UA = smooth(1, noEvent(if m_ref < 1e-4 then 1e-4 else m_coeff[3]*(m_ref_rel^(m_coeff[1]))*(m_flow_rel^(m_coeff[2]))*UA_nom));

//     UA = smooth(1, noEvent(if m_ref < 1e-4 then 1e-4 else smooth(1, noEvent( if m_flow < 1e-4 then 1e-4 else
//                (m_coeff[1]+ m_coeff[2] * m_ref_rel + m_coeff[3]* m_ref_rel ^2 + m_coeff[4]* m_flow_rel +
//                m_coeff[5]* m_flow_rel^2 +  m_coeff[6] * m_ref_rel * m_flow_rel)*UA_nom))));

      UA = Buildings.Utilities.Math.Functions.smoothMax((m_coeff[1]+ m_coeff[2] * m_ref_rel + m_coeff[3]* m_ref_rel ^2 + m_coeff[4]* m_flow_rel +
            m_coeff[5]* m_flow_rel^2 +  m_coeff[6] * m_ref_rel * m_flow_rel)*UA_nom,1e-4,1e-5);

  end if;

  // ------------Evaluation of the efficency and CC -----------------------------------------------------------------------------------------------------------------------------------------------

  NTU = UA/(m_flow_safe*cp);
  HC_ref = deMultiplex2.y1[1];
  efficiency = Buildings.Utilities.Math.Functions.smoothMax(
    1 - Modelica.Constants.e^(-NTU),
    1e-4,
    1e-5);
  HC_sec = port_a.m_flow*cp*(SensExF.T - SensEF.T);
  connect(port_a, SensEF.port) annotation (Line(points={{-100,0},{-64,0},{-64,22}}, color={0,127,255}));
  connect(SensExF.port, vol.ports[3]) annotation (Line(points={{38,20},{38,0},{1,0}}, color={0,127,255}));
  connect(realExpression.y, firstOrder.u) annotation (Line(points={{-89,-72},{-78,-72}}, color={0,0,127}));
  connect(firstOrder.y, RefT) annotation (Line(points={{-55,-72},{-42,-72},{-42,-40},{-110,-40}}, color={0,0,127}));
  connect(preHeaFlo.port, vol.heatPort) annotation (Line(points={{-22,-40},{-22,-10},{-9,-10}}, color={191,0,0}));
  connect(HC_tot, deMultiplex2.u) annotation (Line(points={{0,-112},{0,-100},{18,-100},{18,-91.2}}, color={0,0,127}));
  connect(deMultiplex2.y1[1], preHeaFlo.Q_flow) annotation (Line(points={{14.4,-77.4},{14.4,-70},{-22,-70},{-22,-60}}, color={0,0,127}));
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
end Condenser_vs_3_clean;
