within HeatPumpModel.Components.Heating;
model OnOff_vs_4 "Introduced variable band with hysteresis"
  Modelica.Blocks.Interfaces.RealInput CMP_frequency
    annotation (Placement(transformation(extent={{-104,-12},{-80,12}}),
        iconTransformation(extent={{-104,-12},{-80,12}})));
  Modelica.Blocks.Interfaces.IntegerOutput OnOff
    "Connector of Integer output signal"
    annotation (Placement(transformation(extent={{80,-40},{100,-20}}),
        iconTransformation(extent={{80,-40},{100,-20}})));
  Modelica.Blocks.Logical.Switch switch2
    annotation (Placement(transformation(extent={{8,32},{32,56}})));
  Modelica.Blocks.Sources.Constant const2(k=0)
    annotation (Placement(transformation(extent={{-20,6},{0,26}})));
  Modelica.Blocks.Interfaces.RealOutput Output
    "Connector of Real output signal"
    annotation (Placement(transformation(extent={{80,28},{100,48}}),
        iconTransformation(extent={{80,28},{100,48}})));
  Modelica.Blocks.Math.BooleanToInteger booleanToInteger(integerTrue=1,
      integerFalse=0)
    annotation (Placement(transformation(extent={{14,-10},{34,10}})));
  parameter Real bandwidth=10 "Bandwidth around reference signal"
    annotation (Dialog(group="Controller"));
  parameter Modelica.Blocks.Interfaces.RealOutput MinFrequency=20
    "Minimum frequency of compressor "
     annotation(Dialog(group="Controller"));

  Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=0.15*f_nominal,   uHigh = 0.5 * f_nominal)
    annotation (Placement(transformation(extent={{-52,-10},{-32,10}})));
  parameter Real f_nominal( unit = "Hz") "nominal compressor frequency [Hz]";
  parameter Modelica.Units.SI.Time T(displayUnit="min") = 60 "Time Constant"
    annotation (Dialog(group="Controller"));
equation
  connect(hysteresis.u, CMP_frequency) annotation (Line(points={{-54,0},{-92,0}},
                            color={0,0,127}));
  connect(hysteresis.y, booleanToInteger.u) annotation (Line(points={{-31,0},{
          12,0}},              color={255,0,255}));
  connect(switch2.u1, hysteresis.u) annotation (Line(points={{5.6,53.6},{-64,
          53.6},{-64,0},{-54,0}}, color={0,0,127}));
  connect(switch2.u2, hysteresis.y) annotation (Line(points={{5.6,44},{-28,44},
          {-28,0},{-31,0}}, color={255,0,255}));
  connect(const2.y, switch2.u3)
    annotation (Line(points={{1,16},{5.6,16},{5.6,34.4}}, color={0,0,127}));
  connect(booleanToInteger.y, OnOff)
    annotation (Line(points={{35,0},{90,0},{90,-30}}, color={255,127,0}));
  connect(switch2.y, Output) annotation (Line(points={{33.2,44},{74,44},{74,38},
          {90,38}}, color={0,0,127}));
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
      StartTime=1728000,
      StopTime=2332800,
      Interval=60.0001344,
      __Dymola_Algorithm="Dassl"));
end OnOff_vs_4;
