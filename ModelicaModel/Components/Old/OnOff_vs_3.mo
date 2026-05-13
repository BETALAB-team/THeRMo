within HeatPumpModel.Components;
model OnOff_vs_3 "Added PID inside the on-off controller"
  Modelica.Blocks.Interfaces.IntegerOutput OnOff
    "Connector of Integer output signal"
    annotation (Placement(transformation(extent={{82,-50},{102,-30}}),
        iconTransformation(extent={{82,-50},{102,-30}})));
  Modelica.Blocks.Logical.Switch switch2
    annotation (Placement(transformation(extent={{54,50},{78,74}})));
  Modelica.Blocks.Sources.Constant const2(k=0)
    annotation (Placement(transformation(extent={{14,16},{34,36}})));
  Modelica.Blocks.Logical.OnOffController onOffController(bandwidth=bandwidth)
    annotation (Placement(transformation(extent={{-18,-10},{2,10}})));
  Modelica.Blocks.Math.BooleanToInteger booleanToInteger(integerTrue=1,
      integerFalse=0)
    annotation (Placement(transformation(extent={{38,-40},{58,-20}})));
  Modelica.Blocks.Sources.RealExpression realExpression(y=MinFrequency)
    annotation (Placement(transformation(extent={{-52,-24},{-32,-4}})));
  Buildings.Controls.Continuous.LimPID conPID(
    controllerType=controllerType,
    k=k,
    Ti=Ti,
    Td=Td,
    yMax=yMax,
    yMin=yMin)
    annotation (Placement(transformation(extent={{-76,16},{-56,-4}})));
  Modelica.Blocks.Interfaces.RealInput T
    "Connector of measurement input signal" annotation (Placement(
        transformation(extent={{-134,24},{-104,54}}), iconTransformation(extent
          ={{-134,24},{-104,54}})));
  Modelica.Blocks.Interfaces.RealInput T_setpoint
    "Connector of setpoint input signal" annotation (Placement(transformation(
          extent={{-138,-56},{-106,-24}}), iconTransformation(extent={{-138,-56},
            {-106,-24}})));
  Modelica.Blocks.Interfaces.RealOutput y1 "Connector of Real output signal"
    annotation (Placement(transformation(extent={{82,30},{102,50}}),
        iconTransformation(extent={{82,30},{102,50}})));
  parameter Modelica.Blocks.Types.SimpleController controllerType=
      controllerType "Type of controller"
    annotation (Dialog(group="Controller"));
  parameter Real k=k "Gain of controller"
    annotation (Dialog(group="Controller"));
  parameter Modelica.Units.SI.Time Ti=Ti "Time constant of Integrator block"
    annotation (Dialog(group="Controller"));
  parameter Modelica.Units.SI.Time Td=Td "Time constant of Derivative block"
    annotation (Dialog(group="Controller"));
  parameter Real yMax=yMax "Upper limit of output"
    annotation (Dialog(group="Controller"));
  parameter Real yMin=yMin "Lower limit of output"
    annotation (Dialog(group="Controller"));
  parameter Real bandwidth=10 "Bandwidth around reference signal"
    annotation (Dialog(group="Controller"));
  parameter Modelica.Blocks.Interfaces.RealOutput MinFrequency=20
    "Mnimum frequency of CMP operation" annotation (Dialog(group="Controller"));
equation
  connect(const2.y, switch2.u3) annotation (Line(points={{35,26},{44,26},{44,52.4},
          {51.6,52.4}},         color={0,0,127}));
  connect(booleanToInteger.y, OnOff)
    annotation (Line(points={{59,-30},{94,-30},{94,-40},{92,-40}},
                                              color={255,127,0}));
  connect(realExpression.y, onOffController.u) annotation (Line(points={{-31,-14},
          {-28,-14},{-28,-6},{-20,-6}},      color={0,0,127}));
  connect(onOffController.y, booleanToInteger.u) annotation (Line(points={{3,0},
          {26,0},{26,-30},{36,-30}}, color={255,0,255}));
  connect(switch2.u2, onOffController.y) annotation (Line(points={{51.6,62},{4,62},
          {4,0},{3,0}}, color={255,0,255}));
  connect(conPID.y, onOffController.reference)
    annotation (Line(points={{-55,6},{-20,6}}, color={0,0,127}));
  connect(conPID.u_m, T)
    annotation (Line(points={{-66,18},{-66,39},{-119,39}}, color={0,0,127}));
  connect(conPID.u_s, T_setpoint) annotation (Line(points={{-78,6},{-100,6},{-100,
          -40},{-122,-40}}, color={0,0,127}));
  connect(conPID.y, switch2.u1) annotation (Line(points={{-55,6},{-28,6},{-28,71.6},
          {51.6,71.6}}, color={0,0,127}));
  connect(switch2.y, y1) annotation (Line(points={{79.2,62},{104,62},{104,40},{92,
          40}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-78,76},{80,-68}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineThickness=1),
        Bitmap(extent={{-88,-46},{114,74}}, fileName=
              "modelica://HeatPumpModel/../Incons/Immagine 2025-11-26 101316.png"),
        Text(
          extent={{-88,-38},{76,-94}},
          textColor={0,0,0},
          textString="%name
")}), Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StartTime=2160000,
      StopTime=2332800,
      Interval=299.999808,
      __Dymola_Algorithm="Dassl"));
end OnOff_vs_3;
