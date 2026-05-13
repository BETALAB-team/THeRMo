within HeatPumpModel.Components.Heating;
model Evaporator_vs_2_zones
  "SH is limited to a maximum value which depends on the pinch point"
  extends Buildings.Fluid.Interfaces.TwoPortHeatMassExchanger(redeclare final
      Buildings.Fluid.MixingVolumes.MixingVolume vol(
      final V=0.15*V,
            prescribedHeatFlowRate=false,
      nPorts=2), break connect(vol.ports[2], port_b));

  replaceable parameter Real UA_nom  = 1000 "Heat transfer/ area product";

  Real m_flow_safe( unit = "kg/s")   "Safe value of m_flo if m_flow = 0";

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-36,-54})));
  Modelica.Blocks.Interfaces.RealInput HeatFlow(unit="W") annotation (Placement(
        transformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-39,-111}), iconTransformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-39,-111})));
  Modelica.Blocks.Sources.RealExpression realExpression(y=SensEFEva.T + heaFlo1.Q_flow
        /(efficiency*m_flow_safe*cp))
    annotation (Placement(transformation(extent={{50,-54},{70,-34}})));

  Modelica.Blocks.Interfaces.RealOutput RefT(unit="K") "Medium temperature"
    annotation (Placement(transformation(extent={{108,-54},{128,-34}})));
  Buildings.Fluid.Sensors.Temperature SensEF(redeclare package Medium =
        Medium, warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{-82,-92},{-62,-72}})));
  Buildings.Fluid.Sensors.Temperature SensExF(redeclare package Medium =
        Medium, warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{60,60},{80,80}})));
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
        origin={-36,-28})));
  Real efficiency "HE efficiency";
  Real NTU "Number of transfer unit";
  Real UA "Scaled Heat ransfer coefficient on the actual air mass flow rate";
  Modelica.Blocks.Interfaces.RealOutput T_in "Temperature in port medium"
    annotation (Placement(transformation(extent={{100,-88},{120,-68}}),
        iconTransformation(extent={{100,-88},{120,-68}})));
   Modelica.Blocks.Continuous.FirstOrder firstOrder(
    T(displayUnit="min") = Tau_cost_eva,
    initType=Modelica.Blocks.Types.Init.SteadyState,
    y_start=Medium.T_default)
    annotation (Placement(transformation(extent={{78,-54},{98,-34}})));
  parameter String UA_value_eva = "Select how to calculate UA" annotation (choices(choice = "Nominal value", choice = "Parametric correlation"));
  parameter Modelica.Units.SI.Time Tau_cost_eva(displayUnit="min") = 900
    "Time Constant";
  parameter Modelica.Units.SI.Volume V=m_flow_nominal*tau/rho_default "Volume";

  Buildings.Fluid.MixingVolumes.MixingVolume vol_lat(
    final V=0.85*V,
    prescribedHeatFlowRate=false,
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final mSenFac=1,
    final m_flow_nominal=m_flow_nominal,
    final energyDynamics=energyDynamics,
    final massDynamics=energyDynamics,
    final p_start=p_start,
    final T_start=T_start,
    final X_start=X_start,
    final C_start=C_start,
    nPorts=4) "Volume for fluid stream"
    annotation (Placement(transformation(extent={{43,0},{63,-20}})));
  Buildings.HeatTransfer.Sources.PrescribedHeatFlow preHeaFlo1
                                                              annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={38,-56})));
  Modelica.Blocks.Interfaces.RealInput Ratio(unit="W") annotation (Placement(
        transformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={-5,-111}), iconTransformation(
        extent={{-11,-11},{11,11}},
        rotation=90,
        origin={59,-107})));
  Modelica.Blocks.Sources.RealExpression realExpression1(y=HeatFlow*(1 - Ratio))
    annotation (Placement(transformation(extent={{-8,-9},{8,9}},
        rotation=90,
        origin={-36,-81})));
  Modelica.Blocks.Sources.RealExpression realExpression2(y=HeatFlow*(Ratio))
    annotation (Placement(transformation(extent={{-8,-9},{8,9}},
        rotation=90,
        origin={38,-85})));
  Buildings.Fluid.Sensors.Temperature SensEFEva(redeclare package Medium =
        Medium, warnAboutOnePortConnection=false)
    annotation (Placement(transformation(extent={{18,20},{38,40}})));
  Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heaFlo1
    "Heat flow sensor"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={38,-30})));
equation
  m_flow_safe  = Buildings.Utilities.Math.Functions.smoothMax(abs(port_a.m_flow), 1e-4,1e-5);

   //Selection of calculation methods for UA
   if UA_value_eva == "Nominal value" then
     UA = UA_nom;
  elseif UA_value_eva == "Parametric correlation" then
     UA = UA_nom *(m_flow_safe/m_flow_nominal)^ 0.8;
  end if;
  NTU = UA/(m_flow_safe * cp);
  efficiency = 1 - Modelica.Constants.e^(-NTU);
  //Ratio = HeatFlow/m_flow_safe;

  connect(heaFlo.port_b, vol.heatPort) annotation (Line(points={{-36,-18},{-36,
          -12},{-14,-12},{-14,-10},{-9,-10}},
                                    color={191,0,0}));
  connect(preHeaFlo.port, heaFlo.port_a)
    annotation (Line(points={{-36,-44},{-36,-38}}, color={191,0,0}));
  connect(port_a,SensEF. port)
    annotation (Line(points={{-100,0},{-86,0},{-86,-96},{-72,-96},{-72,-92}},
                                                         color={0,127,255}));
  connect(SensExF.T, T_out)
    annotation (Line(points={{77,70},{110,70}}, color={0,0,127}));
  connect(SensEF.T, T_in) annotation (Line(points={{-65,-82},{-52,-82},{-52,
          -122},{96,-122},{96,-78},{110,-78}},
                     color={0,0,127}));
  connect(RefT, firstOrder.y) annotation (Line(points={{118,-44},{99,-44}},
                                color={0,0,127}));
  connect(realExpression.y, firstOrder.u)
    annotation (Line(points={{71,-44},{76,-44}}, color={0,0,127}));
  connect(vol.ports[2], vol_lat.ports[1])
    annotation (Line(points={{1,0},{51.5,0}}, color={0,127,255}));
  connect(vol_lat.ports[2], port_b)
    annotation (Line(points={{52.5,0},{100,0}}, color={0,127,255}));
  connect(realExpression1.y, preHeaFlo.Q_flow)
    annotation (Line(points={{-36,-72.2},{-36,-64}}, color={0,0,127}));
  connect(realExpression2.y, preHeaFlo1.Q_flow)
    annotation (Line(points={{38,-76.2},{38,-66}}, color={0,0,127}));
  connect(SensEFEva.port, vol_lat.ports[3])
    annotation (Line(points={{28,20},{28,0},{53.5,0}}, color={0,127,255}));
  connect(SensExF.port, vol_lat.ports[4]) annotation (Line(points={{70,60},{72,
          60},{72,0},{54.5,0}}, color={0,127,255}));
  connect(heaFlo1.port_b, vol_lat.heatPort)
    annotation (Line(points={{38,-20},{38,-10},{43,-10}}, color={191,0,0}));
  connect(preHeaFlo1.port, heaFlo1.port_a)
    annotation (Line(points={{38,-46},{38,-40}}, color={191,0,0}));
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
end Evaporator_vs_2_zones;
