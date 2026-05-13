within HeatPumpModel.Components.OldCool;
model Evaporator_vs_4_cooling "Added direct efficency calculation"

  // ------------Extend existing component---------------------------------------------------------------------------------------------------------------------------------------------------------

  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final Buildings.Fluid.MixingVolumes.MixingVolume vol(
      V=V_eva_cool,
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
  //Real m_vector[5] = { m_ref_rel,m_ref_rel^2,m_flow_rel,m_flow_rel^2, m_ref_rel*m_flow_rel} "polynomial equation";
  Real efficiency "HE efficiency";
  Real CC_ref(unit="W") "refrigerant cooling capacity";
  Real CC_sec(unit ="W") "refrigerant secondary cooling capacity";
  Real NTU "Number of transfer unit";
  Real UA "Heat transfer/ area product";

  // ------------Define input parameters-----------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter Real m_ref_nom(unit="kg/s") "Nominal refrigerant mass flow rate [kg/s]";
  parameter Real UA_nom(unit="W/K") "Nominal UA value";
  parameter String fileName=fileName_eva_cool;
  parameter String UA_value_eva_cool="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"));
  parameter Modelica.Units.SI.Time Tau_cost_eva_cool(displayUnit="min") = 900 "Time Constant of Condenser";
  parameter Modelica.Units.SI.Volume V_eva_cool "Volume of the secondary fluid";

   // ------------Define blocks-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,-58})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{-74,22},{-54,42}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{28,20},{48,40}})));
  Modelica.Units.SI.SpecificHeatCapacity cp = Medium.specificHeatCapacityCp(sta_default) "Density, used to compute fluid volume";
  Modelica.Blocks.Sources.RealExpression realExpression(y=Buildings.Utilities.Math.Functions.smoothMin(SensEF.T +  CC_ref/(efficiency*m_flow_safe*cp),SensExF.T,1E-5)) annotation (Placement(transformation(extent={{-110,-82},{-90,-62}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = Tau_cost_eva_cool,
    initType=Modelica.Blocks.Types.Init.SteadyState,
    y_start=Medium.T_default) annotation (Placement(transformation(extent={{-76,-82},{-56,-62}})));

  // ------------Define blocks input and output----------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.RealInput CC_tot[3] "Connector of Real input signals" annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112}),  iconTransformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112})));
  Modelica.Blocks.Interfaces.RealOutput CC_secondary(unit="W") "Heat removed from the secondary fluid"
    annotation (Placement(transformation(extent={{100,-52},{120,-32}}), iconTransformation(extent={{100,-52},{120,-32}})));
  Modelica.Blocks.Routing.DeMultiplex3 deMultiplex3 annotation (Placement(transformation(
      extent={{-5,-5},{5,5}},
      rotation=90,
      origin={27,-85})));
  Modelica.Blocks.Interfaces.RealOutput RefT(unit="K") "Medium temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-40}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,-40})));
  Modelica.Blocks.Math.Gain gain(k=-1) annotation (Placement(transformation(extent={{8,-82},{-2,-72}})));

  // =================EQUATION BLOCK===============================================================================================================================================================

equation

  // ------------Relative mass flow calculation----------------------------------------------------------------------------------------------------------------------------------------------------

  m_ref = deMultiplex3.y2[1];
  m_flow_safe = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4, 1e-5);
  m_flow_rel = m_flow_safe/m_flow_nominal;
  m_ref_rel = m_ref/m_ref_nom;

  // ------------Selection of calculation of UA method---------------------------------------------------------------------------------------------------------------------------------------------

  if UA_value_eva_cool == "Nominal value" then
    UA = UA_nom;
  elseif UA_value_eva_cool == "Parametric correlation" then
    UA =  Buildings.Utilities.Math.Functions.smoothMax((m_coeff[1]+ m_coeff[2] * m_ref_rel + m_coeff[3]* m_ref_rel ^2 + m_coeff[4]* m_flow_rel +
            m_coeff[5]* m_flow_rel^2 +  m_coeff[6] * m_ref_rel * m_flow_rel)*UA_nom,1e-4,1e-5);
  end if;

  // ------------Evaluation of the efficency and CC -----------------------------------------------------------------------------------------------------------------------------------------------

  NTU = UA/(m_flow_safe*cp);
  CC_ref = gain.y;
  efficiency = Buildings.Utilities.Math.Functions.smoothMax(
   Buildings.Utilities.Math.Functions.smoothMin((SensExF.T - SensEF.T)/(deMultiplex3.y3[1] -SensEF.T),1,1e-5),
    1e-4,
    1e-5);
  CC_secondary = CC_sec;
  CC_sec = - port_a.m_flow*cp*(SensExF.T - SensEF.T);
  connect(port_a, SensEF.port) annotation (Line(points={{-100,0},{-64,0},{-64,22}}, color={0,127,255}));
  connect(SensExF.port, vol.ports[3]) annotation (Line(points={{38,20},{38,0},{1,0}}, color={0,127,255}));
  connect(realExpression.y, firstOrder.u) annotation (Line(points={{-89,-72},{-78,-72}}, color={0,0,127}));
  connect(preHeaFlo.port, vol.heatPort) annotation (Line(points={{-22,-48},{-22,-10},{-9,-10}}, color={191,0,0}));
  connect(gain.y, preHeaFlo.Q_flow) annotation (Line(points={{-2.5,-77},{-22,-77},{-22,-68}}, color={0,0,127}));
  connect(firstOrder.y, RefT) annotation (Line(points={{-55,-72},{-52,-72},{-52,-40},{-110,-40}}, color={0,0,127}));
  connect(CC_tot, deMultiplex3.u) annotation (Line(points={{0,-112},{0,-98},{28,-98},{28,-91},{27,-91}}, color={0,0,127}));
  connect(deMultiplex3.y1[1], gain.u) annotation (Line(points={{23.5,-79.5},{23.5,-76},{14,-76},{14,-77},{9,-77}}, color={0,0,127}));
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
end Evaporator_vs_4_cooling;
