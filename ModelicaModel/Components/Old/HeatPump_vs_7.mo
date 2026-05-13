within HeatPumpModel.Components;
model HeatPump_vs_7
  "Modified Ref cycle and CMP to adapt to Copeland 20 coefficients polynomials"
  Ref_cycle_vs_7 ref_cycle_vs_7(
    fileName=fileName,
    SH=SH,
    SBC=SBC,
    redeclare package Medium = Medium,
    F=F) annotation (Placement(transformation(extent={{24,-20},{58,14}})));
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
  parameter Modelica.Units.SI.MassFlowRate m_flow_cond_nominal
    "Nominal mass flow rate" annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.PressureDifference dp__cond_nominal
    "Pressure difference" annotation (Dialog(group="Condenser"));
  replaceable package eva_medium = Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true,Dialog(group="Evaporator"));

  parameter Modelica.Units.SI.MassFlowRate m_flow_eva_nominal
    "Nominal mass flow rate" annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.PressureDifference dp__eva_nominal
    "Pressure difference" annotation (Dialog(group="Evaporator"));
  parameter String fileName="Select a compressor model"
  "File path where polynomial coefficients are stored"
  annotation(choices(choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xlsx",
                     choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VRJ028-K polynomials.xlsx",
                     choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VZH028CH polynomials.xlsx",
                     choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Copeland/XHV0181P-9E9-ED3015A polynomials.xlsx"),Dialog(group="CMP"));

  parameter Real SH "superheat" annotation (Dialog(group="Refrigerant"));
  parameter Real SBC "subcooling" annotation (Dialog(group="Refrigerant"));
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
    annotation (Placement(transformation(extent={{106,6},{126,26}}),
        iconTransformation(extent={{106,6},{126,26}})));
  Modelica.Blocks.Interfaces.RealOutput COP "Coefficient of performance"
    annotation (Placement(transformation(extent={{108,-32},{128,-12}}),
        iconTransformation(extent={{108,-32},{128,-12}})));
  parameter String CMP_type="Fixed speed" annotation (choices(choice = "Fixed speed", choice = "Variable speed 20 coeff",choice = "Variable speed 30 coeff"),Dialog(group="CMP"));
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
  CMP_poly_vs_6 CMP_6(fileName=fileName, CMP_type=CMP_type)
    annotation (Placement(transformation(extent={{-40,-18},{0,12}})));
  Condenser_variable_UA        Condenser(
    redeclare package Medium = cond_medium,
    m_flow_nominal=m_flow_cond_nominal,
    dp_nominal=dp__cond_nominal,
    fileName = fileName_cond)          annotation (Placement(transformation(extent={{34,54},{64,84}})));
  EvaporatorCondenserFixedTempFlow_UA_nom
                                Evaporator(
    redeclare package Medium = eva_medium,
    m_flow_nominal=m_flow_eva_nominal,
    dp_nominal=dp__eva_nominal,
    UA_nom=UA_eva)
    annotation (Placement(transformation(extent={{24,-56},{54,-86}})));
  OnOff_vs_4 onOff_vs_4_1(
    f_nominal=f_nominal)
    annotation (Placement(transformation(extent={{-70,-16},{-42,12}})));
  Modelica.Blocks.Interfaces.RealInput T
    "Connector of measurement input signal" annotation (Placement(
        transformation(extent={{-138,6},{-114,30}}),  iconTransformation(extent={{-138,6},
            {-114,30}})));
  Modelica.Blocks.Interfaces.RealInput T_setpoint
    "Connector of setpoint input signal" annotation (Placement(transformation(
          extent={{-138,-30},{-114,-6}}), iconTransformation(extent={{-138,-30},
            {-114,-6}})));
  Dew_T_calculation DewT( redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{2,-64},{-14,-48}})));
  Buildings.Controls.Continuous.LimPID conPID(
    controllerType=controllerType,
    k=k,
    Ti=Ti,
    Td=Td,
    yMax=yMax,
    yMin=yMin,
    y_reset=15)
    annotation (Placement(transformation(extent={{-94,8},{-74,-12}})));

  Modelica.Blocks.Math.Gain gain(k=-1) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=-90,
        origin={34,-38})));

  parameter Real UA_eva=1000 "Heat transfer/ area product"
    annotation (Dialog(group="Evaporator"));
  parameter Real f_nominal "nominal compressor frequency"
    annotation (Dialog(group="CMP"));
  parameter String fileName_cond ="C:/Users\benafra10167/Desktop/HE_polynomial/B8T.xlsx"
    "File path where polynomial coefficients are stored"
  annotation(choices(choice = "C:/Users/benafra10167/Desktop/HE_polynomial/B8T.xlsx",
             choice = "C:/Users/benafra10167/Desktop/HE_polynomial/B10T.xlsx"),Dialog(group="Condenser"));
equation
  connect(Load_in, Load_in)
    annotation (Line(points={{-70,110},{-70,110}}, color={0,127,255}));
  connect(Source_out, Source_out)
    annotation (Line(points={{70,-110},{70,-110}}, color={0,127,255}));
  connect(Load_out, Load_out)
    annotation (Line(points={{72,110},{72,110}}, color={0,127,255}));
  connect(ref_cycle_vs_7.Wel_ref, Wel_ref) annotation (Line(points={{61.91,8.73},
          {100,8.73},{100,16},{116,16}}, color={0,0,127}));

  connect(ref_cycle_vs_7.COP, COP) annotation (Line(points={{61.91,-14.05},{100,
          -14.05},{100,-20},{108,-20},{108,-22},{118,-22}}, color={0,0,127}));
  connect(ref_cycle_vs_7.HC_ref, Condenser.HeatFlow) annotation (Line(points={{41.17,
          17.91},{43,17.91},{43,52.2}}, color={0,0,127}));
  connect(Load_in, Condenser.port_a)
    annotation (Line(points={{-70,110},{-70,69},{34,69}}, color={0,127,255}));
  connect(Condenser.port_b, Load_out)
    annotation (Line(points={{64,69},{72,69},{72,110}}, color={0,127,255}));
  connect(Evaporator.port_a, Source_in) annotation (Line(points={{24,-71},{24,
          -70},{-70,-70},{-70,-110}},
                                 color={0,127,255}));
  connect(Evaporator.port_b, Source_out) annotation (Line(points={{54,-71},{54,
          -70},{70,-70},{70,-110}},
                               color={0,127,255}));
  connect(Condenser.RefT,CMP_6. Tcond) annotation (Line(points={{65.5,64.5},{-20,
          64.5},{-20,13.8}}, color={0,0,127}));
  connect(Condenser.RefT, ref_cycle_vs_7.Tcond) annotation (Line(points={{65.5,64.5},
          {-10,64.5},{-10,12},{21.96,12},{21.96,12.3}}, color={0,0,127}));
  connect(COP, COP)
    annotation (Line(points={{118,-22},{118,-22}}, color={0,0,127}));
  connect(DewT.T_dew,CMP_6. Teva) annotation (Line(points={{-15.44,-56},{-20,
          -56},{-20,-18}},      color={0,0,127}));
  connect(onOff_vs_4_1.Output,CMP_6. CMP_f) annotation (Line(points={{-43.4,
          1.36},{-40,1.36},{-40,3.15},{-36.2,3.15}},
                                               color={0,0,127}));
  connect(onOff_vs_4_1.OnOff,CMP_6. Mode) annotation (Line(points={{-43.4,-6.2},
          {-43.4,-6},{-40,-6},{-40,-9.15},{-35.8,-9.15}}, color={255,127,0}));
  connect(conPID.y,onOff_vs_4_1. CMP_frequency)
    annotation (Line(points={{-73,-2},{-68.88,-2}}, color={0,0,127}));
  connect(T, conPID.u_m)
    annotation (Line(points={{-126,18},{-84,18},{-84,10}}, color={0,0,127}));
  connect(T_setpoint, conPID.u_s) annotation (Line(points={{-126,-18},{-106,-18},
          {-106,-2},{-96,-2}}, color={0,0,127}));
  connect(ref_cycle_vs_7.CC_ref, gain.u) annotation (Line(points={{41.17,-23.91},
          {34,-23.91},{34,-33.2}}, color={0,0,127}));
  connect(Evaporator.RefT, DewT.T_eva_in) annotation (Line(points={{55.5,-63.2},
          {55.5,-56},{3.6,-56}},  color={0,0,127}));
  connect(gain.y, Evaporator.HeatFlow)
    annotation (Line(points={{34,-42.4},{33.45,-42.4},{33.45,-54.95}},
                                                     color={0,0,127}));
  connect(DewT.T_dew, ref_cycle_vs_7.Teva) annotation (Line(points={{-15.44,-56},
          {-20,-56},{-20,-26},{12,-26},{12,-17.96},{21.96,-17.96}}, color={0,0,127}));
  connect(CMP_6.Mode_Output, ref_cycle_vs_7.OnOff) annotation (Line(points={{-5,
          -3.15},{-2,-3},{21.96,-3}}, color={255,127,0}));
  connect(CMP_6.Wel, ref_cycle_vs_7.Wel_map) annotation (Line(points={{-4.8,1.2},
          {-2,1.76},{21.96,1.76}}, color={0,0,127}));
  connect(CMP_6.CC, ref_cycle_vs_7.CC_map) annotation (Line(points={{-4.8,-7.5},
          {-2,-8.1},{21.96,-8.1}}, color={0,0,127}));
  connect(ref_cycle_vs_7.M_ref, Condenser.m_ref) annotation (Line(points={{54.26,
          17.74},{54.85,20},{54.85,52.35}}, color={0,0,127}));
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
")}), experiment(
      StartTime=1728000,
      StopTime=1814400,
      Interval=59.9999616,
      __Dymola_Algorithm="Radau"));
end HeatPump_vs_7;
