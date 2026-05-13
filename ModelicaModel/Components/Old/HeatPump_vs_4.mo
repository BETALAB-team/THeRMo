within HeatPumpModel.Components;
model HeatPump_vs_4
  "HP with corrected ref cycle and variable compressor speed. Controller is settable between P,PI and PID. Smooth functiong for transition to OFF status."
  BaseHP_vs_6 baseHP_vs_6(
    redeclare package cond_medium = cond_medium,
    efficiency_cond=efficiency_cond,
    m_flow_cond_nominal=m_flow_cond_nominal,
    dp__cond_nominal=dp__cond_nominal,
    redeclare package eva_medium = eva_medium,
    efficiency_eva=efficiency_eva,
    m_flow_eva_nominal=m_flow_eva_nominal,
    dp__eva_nominal=dp__eva_nominal,
    fileName=fileName,
    redeclare package Medium = Medium annotation (Dialog(goup="Refrigerant")),
    CMP_type=CMP_type)
    annotation (Placement(transformation(extent={{-38,-14},{10,28}})));
  Ref_cycle_vs_4 ref_cycle_vs_4(
    fileName=fileName,
    SH=SH,
    SBC=SBC,
    redeclare package Medium = Medium,
    F=F) annotation (Placement(transformation(extent={{40,-16},{84,28}})));
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
  parameter String fileName="Select a compressor model"
  "File path where polynomial coefficients are stored"
  annotation(choices(choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xls",
                       choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VRJ028-K polynomials.xls",
                        choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VZH028CH polynomials.xls"),Dialog(group="CMP"));

  parameter Real SH "superheat" annotation (Dialog(group="Refrigerant"));
  parameter Real SBC "subcooling" annotation (Dialog(group="Refrigerant"));
  Modelica.Blocks.Interfaces.RealOutput HC_ref
    "heating capacity calculated with refrigerant cycle" annotation (Placement(
        transformation(extent={{100,32},{120,52}}), iconTransformation(extent={{100,32},
            {120,52}})));
  Modelica.Blocks.Interfaces.RealOutput CC_ref
    "heating capacity calculated with refrigerant cycle" annotation (Placement(
        transformation(extent={{100,-16},{120,4}}),   iconTransformation(extent={{100,-16},
            {120,4}})));
  Modelica.Fluid.Interfaces.FluidPort_a Load_in( redeclare package Medium =
        cond_medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-80,100},{-60,120}}),
        iconTransformation(extent={{-80,100},{-60,120}})));
  Modelica.Fluid.Interfaces.FluidPort_b Load_out( redeclare package Medium =
        cond_medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{62,100},{82,120}}),
        iconTransformation(extent={{62,100},{82,120}})));
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
    annotation (Placement(transformation(extent={{100,6},{120,26}}),
        iconTransformation(extent={{100,6},{120,26}})));
  Modelica.Blocks.Interfaces.RealOutput COP "Coefficient of performance"
    annotation (Placement(transformation(extent={{100,-38},{120,-18}}),
        iconTransformation(extent={{100,-38},{120,-18}})));
  Modelica.Blocks.Interfaces.RealOutput T_load_out( unit = "K", displayUnit = "degC") "Medium temperature"
    annotation (Placement(transformation(extent={{100,54},{120,74}}),
        iconTransformation(extent={{100,54},{120,74}})));
  Modelica.Blocks.Interfaces.RealOutput T_source_out(  unit = "K", displayUnit = "degC") "Medium temperature"
    annotation (Placement(transformation(extent={{100,-68},{120,-48}}),
        iconTransformation(extent={{100,-68},{120,-48}})));
  parameter String CMP_type="Fixed speed" annotation (choices(choice = "Fixed speed", choice = "Variable speed 20 coeff",choice = "Variable speed 30 coeff"),Dialog(group="CMP"));
  Buildings.Controls.Continuous.LimPID conPID(
    controllerType=controllerType,
    k=k,
    Ti=Ti,
    Td=Td,
    yMax=yMax,
    yMin=yMin)
    annotation (Placement(transformation(extent={{-84,22},{-64,2}})));
  Modelica.Blocks.Interfaces.RealInput T_load_set_point
    "Connector of setpoint input signal" annotation (Placement(transformation(
          extent={{-136,0},{-110,26}}),  iconTransformation(extent={{-136,0},{
            -110,26}})));
  parameter Modelica.Blocks.Types.SimpleController controllerType=Modelica.Blocks.Types.SimpleController.PID
    "Type of controller" annotation (Dialog(group="Controller"));
  parameter Real k=1 "Gain of controller"
    annotation (Dialog(group="Controller"));
  parameter Modelica.Units.SI.Time Ti=0.5 "Time constant of Integrator block"
    annotation (Dialog(group="Controller"));
  parameter Modelica.Units.SI.Time Td=0.1 "Time constant of Derivative block"
    annotation (Dialog(group="Controller"));
  parameter Real yMax=1 "Upper limit of output"
    annotation (Dialog(group="Controller"));
  parameter Real yMin=0 "Lower limit of output"
    annotation (Dialog(group="Controller"));
  Modelica.Blocks.Interfaces.RealInput T_measured
    "Connector of measurement input signal" annotation (Placement(
        transformation(extent={{-140,26},{-110,56}}), iconTransformation(extent
          ={{-140,26},{-110,56}})));
equation
  connect(ref_cycle_vs_4.HC_ref, HC_ref) annotation (Line(points={{62.22,33.06},
          {62.22,42},{110,42}}, color={0,0,127}));
  connect(baseHP_vs_6.Load_in, Load_in) annotation (Line(points={{-20.24,30.1},
          {-20.24,96},{-70,96},{-70,110}}, color={0,127,255}));
  connect(baseHP_vs_6.Load_out, Load_out) annotation (Line(points={{-6.8,30.1},
          {-6.8,96},{72,96},{72,110}}, color={0,127,255}));
  connect(Load_in, Load_in)
    annotation (Line(points={{-70,110},{-70,110}}, color={0,127,255}));
  connect(baseHP_vs_6.Source_in, Source_in) annotation (Line(points={{-18.8,-16.52},
          {-18.8,-96},{-70,-96},{-70,-110}}, color={0,127,255}));
  connect(baseHP_vs_6.Source_out, Source_out) annotation (Line(points={{-4.4,-16.52},
          {-4.4,-96},{70,-96},{70,-110}}, color={0,127,255}));
  connect(Source_out, Source_out)
    annotation (Line(points={{70,-110},{70,-110}}, color={0,127,255}));
  connect(Load_out, Load_out)
    annotation (Line(points={{72,110},{72,110}}, color={0,127,255}));
  connect(CC_ref, CC_ref)
    annotation (Line(points={{110,-6},{110,-6}},   color={0,0,127}));
  connect(baseHP_vs_6.Tcond, ref_cycle_vs_4.Tcond) annotation (Line(points={{14.8,
          23.8},{14,23.8},{14,24},{26,24},{26,25.8},{37.36,25.8}},        color
        ={0,0,127}));
  connect(baseHP_vs_6.HC, ref_cycle_vs_4.HC_map) annotation (Line(points={{14.8,
          17.5},{22,17.5},{22,19.64},{37.36,19.64}}, color={0,0,127}));
  connect(baseHP_vs_6.Wel, ref_cycle_vs_4.Wel_map) annotation (Line(points={{14.32,
          12.04},{22,12.04},{22,12.16},{37.36,12.16}},       color={0,0,127}));
  connect(baseHP_vs_6.m_ref, ref_cycle_vs_4.m_ref_map) annotation (Line(points={{14.8,
          1.12},{22,1.12},{22,-0.6},{37.36,-0.6}},      color={0,0,127}));
  connect(ref_cycle_vs_4.Wel_ref, Wel_ref) annotation (Line(points={{89.06,
          14.14},{104,14.14},{104,16},{110,16}}, color={0,0,127}));
  connect(ref_cycle_vs_4.CC_ref, CC_ref) annotation (Line(points={{62.22,-21.06},
          {92,-6},{110,-6}}, color={0,0,127}));

  connect(ref_cycle_vs_4.COP, COP) annotation (Line(points={{89.06,-0.38},{90,
          -0.38},{90,-28},{110,-28}},  color={0,0,127}));
  connect(baseHP_vs_6.T_load_out, T_load_out)
    annotation (Line(points={{5.2,30.52},{5.2,64},{110,64}}, color={0,0,127}));
  connect(baseHP_vs_6.T_source_out, T_source_out) annotation (Line(points={{2.8,
          -18.2},{2.8,-58},{110,-58}}, color={0,0,127}));
  connect(baseHP_vs_6.Teva, ref_cycle_vs_4.Teva) annotation (Line(points={{14.8,
          -11.06},{20,-11.06},{20,-13.36},{37.36,-13.36}}, color={0,0,127}));
  connect(baseHP_vs_6.CC, ref_cycle_vs_4.CC_map) annotation (Line(points={{14.8,
          -5.6},{22,-5.6},{22,-6.32},{37.36,-6.32}},
                                               color={0,0,127}));
  connect(conPID.u_s, T_load_set_point)
    annotation (Line(points={{-86,12},{-106,12},{-106,13},{-123,13}},
                                                           color={0,0,127}));
  connect(baseHP_vs_6.Mode_Output, ref_cycle_vs_4.OnOff) annotation (Line(
        points={{12.88,7},{28,7},{28,6},{37.36,6}}, color={255,127,0}));
  connect(conPID.u_m, T_measured)
    annotation (Line(points={{-74,24},{-74,41},{-125,41}}, color={0,0,127}));
  connect(conPID.y, baseHP_vs_6.CMP_frequency1) annotation (Line(points={{-63,
          12},{-52,12},{-52,8.68},{-44.72,8.68}}, color={0,0,127}));
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
end HeatPump_vs_4;
