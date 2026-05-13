within HeatPumpModel.Components;
model HeatPump_vs_2
  "BaseHP with poly calculations combined with refrigerant cycle and correction of Daibiri"
  BaseHP_vs_4 baseHP_vs_4(
    redeclare package cond_medium = cond_medium,
    efficiency_cond=efficiency_cond,
    m_flow_cond_nominal=m_flow_cond_nominal,
    dp__cond_nominal=dp__cond_nominal,
    redeclare package eva_medium = eva_medium,
    efficiency_eva=efficiency_eva,
    m_flow_eva_nominal=m_flow_eva_nominal,
    dp__eva_nominal=dp__eva_nominal,
    fileName=fileName,
    redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-82,-26},{-18,28}})));
  Ref_cycle_vs_3 ref_cycle_vs_3(
    SH=SH,
    SBC=SBC,
    redeclare package Medium = Medium,
    F=F) annotation (Placement(transformation(extent={{30,-28},{84,26}})));
  replaceable package Medium = ExternalMedia.Media.CoolPropMedium(
        mediumName = "R410a",
        substanceNames = {"R410a"})
        annotation (choices(choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R290",substanceNames = {"R290"}) "R290"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R32",substanceNames = {"R32"})
                                                                                                                                             "R32"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R410A",substanceNames = {"R410A"})
                                                                                                                                                 "R410A")),Dialog(group = "Refrigerant"));
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
  parameter String fileName="C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xls"
    "File where external data is stored" annotation (Dialog(group="CMP"));
  parameter Real SH "superheat" annotation (Dialog(group="Refrigerant"));
  parameter Real SBC "subcooling" annotation (Dialog(group="Refrigerant"));
  Modelica.Blocks.Interfaces.RealOutput HC_ref
    "heating capacity calculated with refrigerant cycle" annotation (Placement(
        transformation(extent={{100,20},{120,40}}), iconTransformation(extent={{
            100,20},{120,40}})));
  Modelica.Blocks.Interfaces.RealOutput CC_ref
    "heating capacity calculated with refrigerant cycle" annotation (Placement(
        transformation(extent={{100,-20},{120,0}}),   iconTransformation(extent={{100,-20},
            {120,0}})));
  Modelica.Blocks.Interfaces.IntegerInput OnOff annotation (Placement(
        transformation(extent={{-126,-14},{-100,12}}), iconTransformation(
          extent={{-126,-14},{-100,12}})));
  Modelica.Fluid.Interfaces.FluidPort_a Load_in( redeclare package Medium =
        cond_medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-80,100},{-60,120}}),
        iconTransformation(extent={{-80,100},{-60,120}})));
  Modelica.Fluid.Interfaces.FluidPort_b Load_out( redeclare package Medium =
        cond_medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{62,104},{82,124}}),
        iconTransformation(extent={{62,104},{82,124}})));
  Modelica.Fluid.Interfaces.FluidPort_a Source_in( redeclare package Medium =
        eva_medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-80,-120},{-60,-100}}),
        iconTransformation(extent={{-80,-120},{-60,-100}})));
  Modelica.Fluid.Interfaces.FluidPort_b Source_out( redeclare package Medium =
        eva_medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{60,-120},{80,-100}}),
        iconTransformation(extent={{60,-120},{80,-100}})));
  parameter Real F "Dabiri Correlation parameter"
    annotation (Dialog(group="CMP"));
  Modelica.Blocks.Interfaces.RealOutput Wel_ref
    "heating capacity calculated with refrigerant cycle"
    annotation (Placement(transformation(extent={{100,-2},{120,18}})));
  Modelica.Blocks.Interfaces.RealOutput COP "Coefficient of performance"
    annotation (Placement(transformation(extent={{100,-42},{120,-22}})));
  Modelica.Blocks.Interfaces.RealOutput T_load_out( unit = "K", displayUnit = "degC") "Medium temperature"
    annotation (Placement(transformation(extent={{100,40},{120,60}})));
  Modelica.Blocks.Interfaces.RealOutput T_source_out(  unit = "K", displayUnit = "degC") "Medium temperature"
    annotation (Placement(transformation(extent={{102,-68},{122,-48}})));
equation
  connect(ref_cycle_vs_3.HC_ref, HC_ref) annotation (Line(points={{90.21,20.87},
          {90.21,30},{110,30}}, color={0,0,127}));
  connect(baseHP_vs_4.Load_in, Load_in) annotation (Line(points={{-58.32,30.7},{
          -58.32,92},{-70,92},{-70,110}}, color={0,127,255}));
  connect(baseHP_vs_4.Load_out, Load_out) annotation (Line(points={{-40.4,30.7},
          {-40.4,62},{-40,62},{-40,92},{72,92},{72,114}}, color={0,127,255}));
  connect(Load_in, Load_in)
    annotation (Line(points={{-70,110},{-70,110}}, color={0,127,255}));
  connect(baseHP_vs_4.Source_in, Source_in) annotation (Line(points={{-56.4,-29.24},
          {-56.4,-64},{-70,-64},{-70,-110}}, color={0,127,255}));
  connect(baseHP_vs_4.Source_out, Source_out) annotation (Line(points={{-37.2,-29.24},
          {-37.2,-64},{70,-64},{70,-110}}, color={0,127,255}));
  connect(Source_out, Source_out)
    annotation (Line(points={{70,-110},{70,-110}}, color={0,127,255}));
  connect(Load_out, Load_out)
    annotation (Line(points={{72,114},{72,114}}, color={0,127,255}));
  connect(CC_ref, CC_ref)
    annotation (Line(points={{110,-10},{110,-10}}, color={0,0,127}));
  connect(OnOff, baseHP_vs_4.OnOff) annotation (Line(points={{-113,-1},{-88,-1},
          {-88,0},{-89.68,0},{-89.68,1}}, color={255,127,0}));
  connect(baseHP_vs_4.Tcond, ref_cycle_vs_3.Tcond) annotation (Line(points={{-11.6,
          22.6},{-10,22.76},{26.76,22.76}}, color={0,0,127}));
  connect(baseHP_vs_4.Teva, ref_cycle_vs_3.Teva) annotation (Line(points={{-11.6,
          -22.22},{-11.6,-22},{24,-22},{24,-24},{26.76,-24},{26.76,-23.14}},
        color={0,0,127}));
  connect(baseHP_vs_4.HC, ref_cycle_vs_3.HC_map) annotation (Line(points={{-11.6,
          14.5},{-10,13.58},{26.76,13.58}}, color={0,0,127}));
  connect(baseHP_vs_4.Wel, ref_cycle_vs_3.Wel_map) annotation (Line(points={{-12.24,
          5.86},{-10,6.02},{26.76,6.02}}, color={0,0,127}));
  connect(baseHP_vs_4.m_ref, ref_cycle_vs_3.m_ref_map) annotation (Line(points={
          {-11.6,-6.56},{-10,-6.4},{26.76,-6.4}}, color={0,0,127}));
  connect(baseHP_vs_4.CC, ref_cycle_vs_3.CC_map) annotation (Line(points={{-11.6,
          -15.2},{24,-15.2},{24,-14},{26,-14},{26,-14.5},{26.76,-14.5}}, color={
          0,0,127}));
  connect(ref_cycle_vs_3.Wel_ref, Wel_ref) annotation (Line(points={{90.21,8.99},
          {90.21,8},{110,8}}, color={0,0,127}));
  connect(ref_cycle_vs_3.CC_ref, CC_ref) annotation (Line(points={{90.21,-9.37},
          {90.21,-10},{110,-10}}, color={0,0,127}));

  connect(ref_cycle_vs_3.COP, COP) annotation (Line(points={{90.21,-21.79},{90.21,
          -32},{110,-32}}, color={0,0,127}));
  connect(baseHP_vs_4.T_load_out, T_load_out) annotation (Line(points={{-24.4,31.24},
          {-24.4,50},{110,50}}, color={0,0,127}));
  connect(baseHP_vs_4.T_source_out, T_source_out) annotation (Line(points={{-27.6,
          -31.4},{-27.6,-58},{112,-58}}, color={0,0,127}));
  annotation (Icon(graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineThickness=1),
        Bitmap(extent={{-96,-78},{98,98}}, fileName="modelica://HeatPumpModel/../Incons/Immagine 2025-11-14 130229.png"),
        Text(
          extent={{-58,-64},{48,-92}},
          textColor={0,0,0},
          textString="%name
")}));
end HeatPump_vs_2;
