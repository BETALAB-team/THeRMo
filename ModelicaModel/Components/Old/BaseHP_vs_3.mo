within HeatPumpModel.Components;
model BaseHP_vs_3
  EvaporatorCondenserFixedTempFlow Condenser(
    redeclare package Medium = cond_medium,
    m_flow_nominal=m_flow_cond_nominal,
    dp_nominal=dp__cond_nominal,
    efficiency=efficiency_cond)
    annotation (Placement(transformation(extent={{-10,42},{20,72}})));
  EvaporatorCondenserFixedTempFlow Evaporator(
    redeclare package Medium = eva_medium,
    m_flow_nominal=m_flow_eva_nominal,
    dp_nominal=dp__eva_nominal,
    efficiency=efficiency_eva)
    annotation (Placement(transformation(extent={{-8,-46},{22,-76}})));
  replaceable package cond_medium = Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true,Dialog(group="Condenser"));
  parameter Real efficiency_cond=0.9 annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.MassFlowRate m_flow_cond_nominal
    "Nominal mass flow rate" annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.PressureDifference dp__cond_nominal
    "Pressure difference" annotation (Dialog(group="Condenser"));

  replaceable package eva_medium = Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true,Dialog(group="Evaporator"));
  parameter Real efficiency_eva=0.9 annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.MassFlowRate m_flow_eva_nominal
    "Nominal mass flow rate" annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.PressureDifference dp__eva_nominal
    "Pressure difference" annotation (Dialog(group="Evaporator"));
  Modelica.Blocks.Interfaces.IntegerInput OnOff
    annotation (Placement(transformation(extent={{-144,-20},{-104,20}}),
        iconTransformation(extent={{-144,-20},{-104,20}})));
  Modelica.Fluid.Interfaces.FluidPort_a Load_in(redeclare package Medium =
        cond_medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-36,100},{-16,120}}),
        iconTransformation(extent={{-36,100},{-16,120}})));
  Modelica.Fluid.Interfaces.FluidPort_b Load_out(redeclare package Medium =
        cond_medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{20,100},{40,120}}),
        iconTransformation(extent={{20,100},{40,120}})));
  Modelica.Fluid.Interfaces.FluidPort_a Source_in(redeclare package Medium =
        eva_medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-30,-122},{-10,-102}}),
        iconTransformation(extent={{-30,-122},{-10,-102}})));
  Modelica.Fluid.Interfaces.FluidPort_b Source_out(redeclare package Medium =
        eva_medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{30,-122},{50,-102}}),
        iconTransformation(extent={{30,-122},{50,-102}})));
  Modelica.Blocks.Interfaces.RealOutput HC( unit ="W")
                                                      "Heating capacity"
    annotation (Placement(transformation(extent={{110,40},{130,60}}),
        iconTransformation(extent={{110,40},{130,60}})));
  Modelica.Blocks.Interfaces.RealOutput CC( unit ="W")
                                                      "Cooling capacity"
    annotation (Placement(transformation(extent={{110,-70},{130,-50}}),
        iconTransformation(extent={{110,-70},{130,-50}})));
  Modelica.Blocks.Interfaces.RealOutput Wel( unit ="W")
                                                       "Electric power"
    annotation (Placement(transformation(extent={{108,8},{128,28}}),
        iconTransformation(extent={{108,8},{128,28}})));
  Modelica.Blocks.Interfaces.RealOutput m_ref( unit ="kg/s")
                                                            "Refrigerant mass flow rate"
    annotation (Placement(transformation(extent={{110,-38},{130,-18}}),
        iconTransformation(extent={{110,-38},{130,-18}})));
  Modelica.Blocks.Interfaces.RealOutput Tcond(  unit ="K", displayUnit ="degC") "Condensing temperature"
    annotation (Placement(transformation(extent={{108,70},{128,90}}),
        iconTransformation(extent={{108,70},{128,90}})));
  Modelica.Blocks.Interfaces.RealOutput Teva( unit ="K", displayUnit ="degC") "Evaporating temperature"
    annotation (Placement(transformation(extent={{110,-96},{130,-76}}),
        iconTransformation(extent={{110,-96},{130,-76}})));
  CMP_poly_vs_2 cMP_poly_vs_2
    annotation (Placement(transformation(extent={{-16,-14},{24,18}})));
  parameter String fileName="C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xls"
    "File where external data is stored" annotation (Dialog(group="CMP"));
  Modelica.Blocks.Math.Gain gain(k=-1)
    annotation (Placement(transformation(extent={{80,-66},{94,-52}})));
equation
  connect(Condenser.port_a, Load_in)
    annotation (Line(points={{-10,57},{-26,57},{-26,110}},color={0,127,255}));
  connect(Condenser.port_b, Load_out)
    annotation (Line(points={{20,57},{30,57},{30,110}}, color={0,127,255}));
  connect(Evaporator.port_a, Source_in) annotation (Line(points={{-8,-61},{-8,-60},
          {-20,-60},{-20,-112}},
                            color={0,127,255}));
  connect(Evaporator.port_b, Source_out)
    annotation (Line(points={{22,-61},{22,-60},{40,-60},{40,-112}},
                                                           color={0,127,255}));
  connect(Source_out, Source_out)
    annotation (Line(points={{40,-112},{40,-112}}, color={0,127,255}));
  connect(Wel,Wel)
    annotation (Line(points={{118,18},{118,18}},
                                               color={0,0,127}));
  connect(Condenser.RefT, Tcond) annotation (Line(points={{20.9,45.9},{84,45.9},
          {84,80},{118,80}},         color={0,0,127}));
  connect(Evaporator.RefT, Teva) annotation (Line(points={{22.9,-49.9},{58,-49.9},
          {58,-86},{120,-86}},
                      color={0,0,127}));
  connect(Tcond, Tcond)
    annotation (Line(points={{118,80},{118,80}}, color={0,0,127}));
  connect(Teva, Teva)
    annotation (Line(points={{120,-86},{120,-86}},   color={0,0,127}));
  connect(cMP_poly_vs_2.HC, Condenser.HeatFlow) annotation (Line(points={{12.4,
          18.64},{12.4,24},{-0.25,24},{-0.25,41.25}}, color={0,0,127}));
  connect(HC, cMP_poly_vs_2.HC) annotation (Line(points={{120,50},{92,50},{92,24},
          {12.4,24},{12.4,18.64}},     color={0,0,127}));
  connect(cMP_poly_vs_2.Wel, Wel) annotation (Line(points={{19.2,5.2},{104,5.2},
          {104,18},{118,18}}, color={0,0,127}));
  connect(cMP_poly_vs_2.m_ref, m_ref) annotation (Line(points={{19.2,-1.2},{92,-1.2},
          {92,-28},{120,-28}},       color={0,0,127}));
  connect(cMP_poly_vs_2.CC, Evaporator.HeatFlow) annotation (Line(points={{12.8,
          -12.72},{12.8,-28},{1.75,-28},{1.75,-45.25}}, color={0,0,127}));
  connect(cMP_poly_vs_2.Tcond, Condenser.RefT) annotation (Line(points={{-14,
          -0.88},{-62,-0.88},{-62,46},{-10,46},{-10,45.9},{20.9,45.9}}, color={
          0,0,127}));
  connect(Evaporator.RefT, cMP_poly_vs_2.Teva) annotation (Line(points={{22.9,
          -49.9},{-62,-49.9},{-62,-7.92},{-14,-7.92}}, color={0,0,127}));
  connect(OnOff, cMP_poly_vs_2.Mode) annotation (Line(points={{-124,0},{-92,0},{
          -92,14.48},{-14,14.48}}, color={255,127,0}));
  connect(gain.y, CC) annotation (Line(points={{94.7,-59},{94.7,-60},{120,-60}},
        color={0,0,127}));
  connect(gain.u, Evaporator.HeatFlow) annotation (Line(points={{78.6,-59},{78.6,
          -50},{68,-50},{68,-28},{1.75,-28},{1.75,-45.25}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Bitmap(extent={{-98,-68},{94,92}}, fileName="modelica://HeatPumpModel/../Incons/Immagine 2025-11-17 121921.png"),
        Text(
          extent={{-106,-74},{114,-158}},
          textColor={0,0,0},
          textString="%name


")}),                                                            Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end BaseHP_vs_3;
