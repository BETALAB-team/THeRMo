within HeatPumpModel.Components;
model BaseHP_vs_5 "Variable compressor speed"
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
    annotation (Placement(transformation(extent={{108,14},{128,34}}),
        iconTransformation(extent={{108,14},{128,34}})));
  Modelica.Blocks.Interfaces.RealOutput m_ref( unit ="kg/s")
                                                            "Refrigerant mass flow rate"
    annotation (Placement(transformation(extent={{110,-38},{130,-18}}),
        iconTransformation(extent={{110,-38},{130,-18}})));
  Modelica.Blocks.Interfaces.RealOutput Tcond(  unit ="K", displayUnit ="degC") "Condensing temperature"
    annotation (Placement(transformation(extent={{110,70},{130,90}}),
        iconTransformation(extent={{110,70},{130,90}})));
  Modelica.Blocks.Interfaces.RealOutput Teva( unit ="K", displayUnit ="degC") "Evaporating temperature"
    annotation (Placement(transformation(extent={{110,-96},{130,-76}}),
        iconTransformation(extent={{110,-96},{130,-76}})));
  CMP_poly_vs_3 CMP_3(fileName=fileName, CMP_type=CMP_type)
    annotation (Placement(transformation(extent={{-22,-16},{28,20}})));
  parameter String fileName="C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xls"
    "File where external data is stored" annotation (Dialog(group="CMP"));
  Modelica.Blocks.Math.Gain gain(k=-1)
    annotation (Placement(transformation(extent={{80,-66},{94,-52}})));
  Dew_T_calculation DewT(redeclare package Medium = Medium) annotation (Placement(transformation(
        extent={{-10,-11},{10,11}},
        rotation=90,
        origin={-41,-28})));
  replaceable package Medium = ExternalMedia.Media.CoolPropMedium(
        mediumName = "R410a",
        substanceNames = {"R410a"})
        annotation (choices(choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R290",substanceNames = {"R290"}) "R290"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R32",substanceNames = {"R32"})
                                                                                                                                             "R32"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R410A",substanceNames = {"R410A"})
                                                                                                                                                 "R410A")));
  Modelica.Blocks.Interfaces.RealOutput T_load_out( unit= "K", displayUnit ="degC")
    "Medium temperature"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={76,108}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={80,112})));
  Modelica.Blocks.Interfaces.RealOutput T_source_out( unit= "K", displayUnit ="degC")
    "Medium temperature"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={70,-120})));
  Modelica.Blocks.Interfaces.RealInput CMP_frequency(  unit= "Hz", displayUnit ="Hz")
    "Medium temperatureCompressor frequency / speed "
    annotation (Placement(transformation(extent={{-144,8},{-104,48}}),
        iconTransformation(extent={{-144,8},{-104,48}})));
  parameter String CMP_type="Fixed speed" annotation (Dialog(group="CMP"));
  OnOff onOff "On off switcher"
    annotation (Placement(transformation(extent={{-82,-14},{-58,14}})));
  Modelica.Blocks.Interfaces.IntegerOutput Mode_Output
    annotation (Placement(transformation(extent={{102,-10},{122,10}})));
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
    annotation (Line(points={{118,24},{118,24}},
                                               color={0,0,127}));
  connect(Condenser.RefT, Tcond) annotation (Line(points={{20.9,45.9},{86,45.9},
          {86,80},{120,80}},         color={0,0,127}));
  connect(Evaporator.RefT, Teva) annotation (Line(points={{22.9,-49.9},{68,-49.9},
          {68,-86},{120,-86}},
                      color={0,0,127}));
  connect(Tcond, Tcond)
    annotation (Line(points={{120,80},{120,80}}, color={0,0,127}));
  connect(Teva, Teva)
    annotation (Line(points={{120,-86},{120,-86}},   color={0,0,127}));
  connect(CMP_3.HC, Condenser.HeatFlow) annotation (Line(points={{13.5,20.72},{13.5,
          28},{-0.25,28},{-0.25,41.25}}, color={0,0,127}));
  connect(HC,CMP_3. HC) annotation (Line(points={{120,50},{92,50},{92,28},{13.5,
          28},{13.5,20.72}}, color={0,0,127}));
  connect(CMP_3.Wel, Wel) annotation (Line(points={{21.5,15.32},{92,15.32},{92,
          24},{118,24}},
                color={0,0,127}));
  connect(CMP_3.m_ref, m_ref) annotation (Line(points={{21.5,-4.84},{92,-4.84},
          {92,-28},{120,-28}},
                      color={0,0,127}));
  connect(CMP_3.CC, Evaporator.HeatFlow) annotation (Line(points={{14,-14.56},{14,
          -28},{1.75,-28},{1.75,-45.25}}, color={0,0,127}));
  connect(CMP_3.Tcond, Condenser.RefT) annotation (Line(points={{-27,17.12},{
          -30,17.12},{-30,18},{-42,18},{-42,46},{6,46},{6,45.9},{20.9,45.9}},
                                                            color={0,0,127}));
  connect(gain.y, CC) annotation (Line(points={{94.7,-59},{94.7,-60},{120,-60}},
        color={0,0,127}));
  connect(gain.u, Evaporator.HeatFlow) annotation (Line(points={{78.6,-59},{
          78.6,-48},{80,-48},{80,-28},{1.75,-28},{1.75,-45.25}},
                                                            color={0,0,127}));
  connect(DewT.T_dew,CMP_3. Teva) annotation (Line(points={{-41,-16.2},{-42,
          -16.2},{-42,-9.88},{-27,-9.88}},
                                      color={0,0,127}));
  connect(DewT.T_eva_in, Evaporator.RefT) annotation (Line(points={{-41,-40},{
          -42,-40},{-42,-50},{24,-50},{24,-49.9},{22.9,-49.9}},
        color={0,0,127}));
  connect(Condenser.T_out, T_load_out) annotation (Line(points={{21.5,67.5},{22,
          67.5},{22,68},{76,68},{76,108}}, color={0,0,127}));
  connect(T_load_out, T_load_out)
    annotation (Line(points={{76,108},{76,108}}, color={0,0,127}));
  connect(T_source_out, T_source_out)
    annotation (Line(points={{70,-120},{70,-120}}, color={0,0,127}));
  connect(Evaporator.T_out, T_source_out) annotation (Line(points={{23.5,-71.5},
          {56,-71.5},{56,-100},{70,-100},{70,-120}}, color={0,0,127}));
  connect(CMP_3.Mode_Output, Mode_Output) annotation (Line(points={{21.5,0.92},
          {67.75,0.92},{67.75,0},{112,0}}, color={255,127,0}));
  connect(CMP_3.CMP_f, CMP_frequency) annotation (Line(points={{-27,10.28},{-50,
          10.28},{-50,28},{-124,28}}, color={0,0,127}));
  connect(onOff.OnOff, CMP_3.Mode) annotation (Line(points={{-55.6,0},{-36,0},{
          -36,0.2},{-27.5,0.2}},
                       color={255,127,0}));
  connect(onOff.CMP_frequency, CMP_frequency) annotation (Line(points={{-85.84,
          0},{-98,0},{-98,28},{-124,28}}, color={0,0,127}));
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
end BaseHP_vs_5;
