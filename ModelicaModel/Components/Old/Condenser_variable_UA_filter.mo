within HeatPumpModel.Components;
model Condenser_variable_UA_filter
  "Added a filter on the calculation of the refrigerant temperature"
  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final
      Buildings.Fluid.MixingVolumes.MixingVolume vol(final
          prescribedHeatFlowRate=false, nPorts=3));

  //Get polynomial coefficents
  inner parameter ExternData.XLSXFile dataSource(
                                                fileName=fileName)
  annotation (Placement(transformation(extent={{-30,26},{-10,46}})));
  Real m_coeff[6] = vector(dataSource.getRealArray2D("A2","Polynomials",6,1));

  //Safe mass flows if no mass floe rate is present
  Real m_flow_safe( unit = "kg/s") = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), m_flow_small, m_flow_small/10)   "Safe value of m_flow if m_flow = 0";
  Real m_ref_safe( unit = "kg/s") = Buildings.Utilities.Math.Functions.smoothMax(abs(m_ref), m_flow_small, m_flow_small/10)   "Safe value of m_ref if m_ref = 0";

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-66})));
  Modelica.Blocks.Interfaces.RealInput HeatFlow(unit="W") annotation (Placement(
        transformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={-40,-112}), iconTransformation(
        extent={{-12,-12},{12,12}},
        rotation=90,
        origin={-40,-112})));

  Modelica.Blocks.Interfaces.RealOutput RefT(unit="K") "Medium temperature"
    annotation (Placement(transformation(extent={{100,-40},{120,-20}})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium =
        Medium, warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{-18,74},{2,94}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium =
        Medium, warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{30,24},{50,44}})));
  Modelica.Blocks.Interfaces.RealOutput T_out(unit="K") "Medium temperature"
    annotation (Placement(transformation(extent={{100,24},{120,44}})));

  Modelica.Units.SI.SpecificHeatCapacity cp= Medium.specificHeatCapacityCp(sta_default)
    "Density, used to compute fluid volume";

  Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heaFlo "Heat flow sensor"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-40})));

  Modelica.Blocks.Interfaces.RealOutput T_in "Temperature in port medium"
    annotation (Placement(transformation(extent={{100,60},{120,80}}),
        iconTransformation(extent={{100,60},{120,80}})));

  Modelica.Blocks.Sources.RealExpression realExpression(y=SensEF.T + HeatFlow /(efficiency*m_flow_safe*cp))
    annotation (Placement(transformation(extent={{42,-40},{62,-20}})));

  // Efficency equations
  Modelica.Blocks.Interfaces.RealInput m_ref(unit="kg/s") annotation (Placement(
        transformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={61,-107}),iconTransformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={39,-111})));
  Real m_vector[6] = {1,m_ref_safe,m_ref_safe^2,m_flow_safe,m_flow_safe^2,m_ref_safe*m_flow_safe} "polynomial equation";
  Real efficiency "HE efficiency";
  Real NTU "Number of transfer unit";
  Real UA "Heat transfer/ area product";

  parameter String fileName= fileName_cond;
   Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = 600,                                               initType
      =Modelica.Blocks.Types.Init.SteadyState, y_start = Medium.T_default)
    annotation (Placement(transformation(extent={{72,-40},{92,-20}})));
equation
  UA =smooth(1,noEvent(if m_ref < 1e-7 then 1e-4 else m_vector * m_coeff));
  NTU = smooth(1,noEvent(if m_ref < 1e-7 then 1e-4 else UA/(m_flow_safe * cp)));
  efficiency =  smooth(1,noEvent(if m_ref < 1e-7 then 1e-4 else 1 - Modelica.Constants.e^(-NTU)));

  connect(heaFlo.port_b, vol.heatPort) annotation (Line(points={{-36,-30},{-36,
          -30},{-36,-10},{-9,-10}}, color={191,0,0}));
  connect(preHeaFlo.port, heaFlo.port_a)
    annotation (Line(points={{-36,-56},{-36,-50}}, color={191,0,0}));
  connect(preHeaFlo.Q_flow, HeatFlow) annotation (Line(points={{-36,-76},{-36,-94},
          {-36,-112},{-40,-112}},color={0,0,127}));
  connect(port_a,SensEF. port)
    annotation (Line(points={{-100,0},{-64,0},{-64,56},{-8,56},{-8,74}},
                                                         color={0,127,255}));
  connect(SensExF.port, vol.ports[3])
    annotation (Line(points={{40,24},{40,0},{1,0}}, color={0,127,255}));
  connect(SensExF.T, T_out)
    annotation (Line(points={{47,34},{110,34}}, color={0,0,127}));
  connect(SensEF.T, T_in) annotation (Line(points={{-1,84},{96,84},{96,70},{110,
          70}},      color={0,0,127}));
  connect(realExpression.y, firstOrder.u)
    annotation (Line(points={{63,-30},{70,-30}}, color={0,0,127}));
  connect(firstOrder.y, RefT)
    annotation (Line(points={{93,-30},{110,-30}}, color={0,0,127}));
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
end Condenser_variable_UA_filter;
