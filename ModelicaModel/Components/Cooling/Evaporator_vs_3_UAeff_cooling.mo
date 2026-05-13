within HeatPumpModel.Components.Cooling;
model Evaporator_vs_3_UAeff_cooling "This class corresponds to the Condenser_vs_3 class, but it is implemente for the cooling mode. Thus, it becomes the Evapoator"

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
        origin={-22,-68})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{-74,22},{-54,42}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium = Medium, warnAboutOnePortConnection=false) annotation (Placement(transformation(extent={{28,20},{48,40}})));
  Modelica.Units.SI.SpecificHeatCapacity cp = Medium.specificHeatCapacityCp(sta_default) "Density, used to compute fluid volume";
  Modelica.Blocks.Routing.DeMultiplex2 deMultiplex2 annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={66,-90})));
          Modelica.Blocks.Sources.RealExpression UAeff(final y=Buildings.Utilities.Math.Functions.smoothMax(
        x1=UA,
        x2=efficiency*cp*abs(port_a.m_flow)/(1 - efficiency + 1e-4),
        deltaX=UA/10))
    "Effective heat transfer coefficient"
    annotation (Placement(transformation(extent={{-72,-44},{-52,-24}})));
  public
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor temperatureSensor annotation (Placement(transformation(extent={{-52,-70},{-72,-50}})));
  protected
  Modelica.Thermal.HeatTransfer.Components.Convection con
    "Convective heat transfer"
    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-22,-34})));
  // ------------Define blocks input and output----------------------------------------------------------------------------------------------------------------------------------------------------
  public
  Modelica.Blocks.Interfaces.RealInput CC_tot[2] "Connector of Real input signals" annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112}),  iconTransformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={0,-112})));
  Modelica.Blocks.Math.Gain gain(k=-1) annotation (Placement(transformation(extent={{46,-84},{36,-74}})));
  Modelica.Blocks.Interfaces.RealOutput CC_secondary(unit="W") "Heat removed from the secondary fluid"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}}), iconTransformation(extent={{100,-70},{120,-50}})));
  Modelica.Blocks.Interfaces.RealOutput Tref "Absolute temperature as output signal" annotation (Placement(transformation(extent={{-100,-70},{-120,-50}})));

  // =================EQUATION BLOCK===============================================================================================================================================================


equation

  // ------------Relative mass flow calculation----------------------------------------------------------------------------------------------------------------------------------------------------

  m_ref = deMultiplex2.y2[1];
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
    1 - Modelica.Constants.e^(-NTU),
    1e-4,
    1e-5);
  CC_secondary = CC_sec;
  CC_sec = - port_a.m_flow*cp*(SensExF.T - SensEF.T);
  connect(port_a, SensEF.port) annotation (Line(points={{-100,0},{-64,0},{-64,22}}, color={0,127,255}));
  connect(SensExF.port, vol.ports[3]) annotation (Line(points={{38,20},{38,0},{1,0}}, color={0,127,255}));
  connect(deMultiplex2.u, CC_tot) annotation (Line(points={{66,-97.2},{66,-98},{16,-98},{16,-96},{0,-96},{0,-112}},
                                                                                  color={0,0,127}));
  connect(gain.y, preHeaFlo.Q_flow) annotation (Line(points={{35.5,-79},{35.5,-80},{-22,-80},{-22,-78}},
                                                                                              color={0,0,127}));
  connect(deMultiplex2.y1[1], gain.u) annotation (Line(points={{62.4,-83.4},{62.4,-79},{47,-79}},color={0,0,127}));
  connect(UAeff.y,con. Gc) annotation (Line(points={{-51,-34},{-32,-34}}, color={0,0,127}));
  connect(preHeaFlo.port, con.solid) annotation (Line(points={{-22,-58},{-22,-44}}, color={191,0,0}));
  connect(temperatureSensor.port, con.solid) annotation (Line(points={{-52,-60},{-38,-60},{-38,-48},{-22,-48},{-22,-44}}, color={191,0,0}));
  connect(temperatureSensor.T, Tref) annotation (Line(points={{-73,-60},{-110,-60}}, color={0,0,127}));
  connect(vol.heatPort, con.fluid) annotation (Line(points={{-9,-10},{-22,-10},{-22,-24}}, color={191,0,0}));
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
end Evaporator_vs_3_UAeff_cooling;
