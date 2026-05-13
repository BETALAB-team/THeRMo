within HeatPumpModel.Components;
model OnOff_vs_2
  Modelica.Blocks.Interfaces.RealInput CMP_frequency
    annotation (Placement(transformation(extent={{-104,-12},{-80,12}}),
        iconTransformation(extent={{-104,-12},{-80,12}})));
  Modelica.Blocks.Interfaces.IntegerOutput OnOff
    "Connector of Integer output signal"
    annotation (Placement(transformation(extent={{80,-40},{100,-20}}),
        iconTransformation(extent={{80,-40},{100,-20}})));
  Modelica.Blocks.Logical.Switch switch2
    annotation (Placement(transformation(extent={{50,28},{74,52}})));
  Modelica.Blocks.Sources.Constant const2(k=0)
    annotation (Placement(transformation(extent={{4,8},{24,28}})));
  Modelica.Blocks.Interfaces.RealOutput Output
    "Connector of Real output signal"
    annotation (Placement(transformation(extent={{80,14},{100,34}}),
        iconTransformation(extent={{80,14},{100,34}})));
  Modelica.Blocks.Logical.OnOffController onOffController(bandwidth=bandwidth)
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Modelica.Blocks.Math.BooleanToInteger booleanToInteger(integerTrue=1,
      integerFalse=0)
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression(y=MinFrequency)
    annotation (Placement(transformation(extent={{-74,-24},{-54,-4}})));
  parameter Real bandwidth=10 "Bandwidth around reference signal"
    annotation (Dialog(group="Controller"));
  parameter Modelica.Blocks.Interfaces.RealOutput MinFrequency=20
    "Minimum frequency of compressor "
     annotation(Dialog(group="Controller"));

equation
  connect(const2.y, switch2.u3) annotation (Line(points={{25,18},{40,18},{40,
          30.4},{47.6,30.4}},   color={0,0,127}));
  connect(CMP_frequency, onOffController.reference) annotation (Line(points={{-92,0},
          {-78,0},{-78,6},{-42,6}},           color={0,0,127}));
  connect(booleanToInteger.y, OnOff)
    annotation (Line(points={{61,0},{88,0},{88,-30},{90,-30}},
                                              color={255,127,0}));
  connect(realExpression.y, onOffController.u) annotation (Line(points={{-53,-14},
          {-50,-14},{-50,-6},{-42,-6}},      color={0,0,127}));
  connect(CMP_frequency, switch2.u1) annotation (Line(points={{-92,0},{-78,0},{
          -78,49.6},{47.6,49.6}},    color={0,0,127}));
  connect(onOffController.y, booleanToInteger.u)
    annotation (Line(points={{-19,0},{38,0}}, color={255,0,255}));
  connect(switch2.u2, onOffController.y) annotation (Line(points={{47.6,40},{
          -16,40},{-16,0},{-19,0}},
                               color={255,0,255}));
  connect(switch2.y, Output) annotation (Line(points={{75.2,40},{100,40},{100,
          24},{90,24}},
                    color={0,0,127}));
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
end OnOff_vs_2;
