within HeatPumpModel.Components.Heating;
model HeatPump_vs_10_test
  "Deleted control on frrquency of compressors because the esperimental one is used for the model validation"
  OldHeat.Ref_cycle_vs_8 ref_cycle_vs_8(
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
    annotation (Placement(transformation(extent={{110,12},{130,32}}),
        iconTransformation(extent={{110,12},{130,32}})));
  Modelica.Blocks.Interfaces.RealOutput COP "Coefficient of performance"
    annotation (Placement(transformation(extent={{110,-22},{130,-2}}),
        iconTransformation(extent={{110,-22},{130,-2}})));
  parameter String CMP_type="Fixed speed" annotation (choices(choice = "Fixed speed", choice = "Variable speed 20 coeff",choice = "Variable speed 30 coeff"),Dialog(group="CMP"));
  Heating.CMP_poly_vs_8 CMP_8(fileName=fileName, CMP_type=CMP_type)
    annotation (Placement(transformation(extent={{-40,-18},{0,12}})));
  Heating.Condenser_vs_3 Condenser(
    redeclare package Medium = cond_medium,
    m_flow_nominal=m_flow_cond_nominal,
    dp_nominal=dp__cond_nominal,
    m_ref_nom=m_ref_nom,
    UA_nom=UA_nom,
    fileName=fileName_cond,
    UA_value_cond=UA_value_cond,
    Tau_cost_cond=Tau_cost_cond,
    V=V_cond) annotation (Placement(transformation(extent={{34,54},{64,84}})));
  Heating.Evaporator_vs_2 Evaporator(
    redeclare package Medium = eva_medium,
    m_flow_nominal=m_flow_eva_nominal,
    dp_nominal=dp__eva_nominal,
    UA_nom=UA_eva,
    UA_value_eva=UA_value_eva,
    Tau_cost_eva=Tau_cost_eva,
    V=V_eva) annotation (Placement(transformation(extent={{24,-56},{54,-86}})));
  Heating.Dew_T_calculation DewT(redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{2,-64},{-14,-48}})));

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
             choice = "C:/Users/benafra10167/Desktop/HE_polynomial/B10T.xlsx",
             choice = "C:/Users/benafra10167/Desktop/HE_polynomial/B8LAS.xlsx"),Dialog(group="Condenser"));
  parameter Real m_ref_nom "Nominal refrigerant mass flow rate [kg/s]"
    annotation (Dialog(group="Condenser"));
  parameter Real UA_nom "Nominal UA value"
    annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.Time Tau_cost_cond( displayUnit="min") =900 "Time Constant of Cond Filter"
    annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.Time Tau_cost_eva( displayUnit="min") =900 "Time Constant of Eva Filter"
    annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.Volume V_eva=Evaporator.m_flow_nominal*Evaporator.tau
      /Evaporator.rho_default "Volume" annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.Volume V_cond= Condenser.m_flow_nominal*Condenser.tau/
      Condenser.rho_default "Volume"
    annotation (Dialog(group="Condenser"));
  Modelica.Blocks.Math.Division division
    annotation (Placement(transformation(extent={{80,34},{94,48}})));
  Modelica.Blocks.Interfaces.RealOutput COP_system "Coefficient of performance"
    annotation (Placement(transformation(extent={{106,32},{126,52}}),
        iconTransformation(extent={{110,-52},{130,-32}})));
  Modelica.Blocks.Sources.IntegerConstant integerConstant(k=1)
    annotation (Placement(transformation(extent={{-72,-14},{-62,-4}})));
  Modelica.Blocks.Interfaces.RealInput CMP_f1
    "Compressor frequency / speed " annotation (Placement(transformation(extent
          ={{-130,-14},{-102,14}}), iconTransformation(extent={{-130,-14},{-102,
            14}})));
  parameter String UA_value_cond="Select how to calculate UA"
    annotation (choices(choice = "Nominal value", choice = "Parametric correlation"),Dialog(group="Condenser"));
  parameter String UA_value_eva="Select how to calculate UA"
    annotation (choices(choice = "Nominal value", choice = "Parametric correlation"),Dialog(group="Evaporator"));
equation
  connect(Load_in, Load_in)
    annotation (Line(points={{-70,110},{-70,110}}, color={0,127,255}));
  connect(Source_out, Source_out)
    annotation (Line(points={{70,-110},{70,-110}}, color={0,127,255}));
  connect(Load_out, Load_out)
    annotation (Line(points={{72,110},{72,110}}, color={0,127,255}));
  connect(ref_cycle_vs_8.Wel_ref, Wel_ref) annotation (Line(points={{61.91,8.73},
          {100,8.73},{100,22},{120,22}}, color={0,0,127}));

  connect(ref_cycle_vs_8.COP, COP) annotation (Line(points={{61.91,-14.05},{100,
          -14.05},{100,-14},{108,-14},{108,-12},{120,-12}}, color={0,0,127}));
  connect(ref_cycle_vs_8.HC_ref, Condenser.HeatFlow) annotation (Line(points={{41.17,
          17.91},{45.4,17.91},{45.4,52.2}},   color={0,0,127}));
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
  connect(Condenser.RefT,CMP_8. Tcond) annotation (Line(points={{32.5,63},{-20,
          63},{-20,13.8}},   color={0,0,127}));
  connect(Condenser.RefT, ref_cycle_vs_8.Tcond) annotation (Line(points={{32.5,63},
          {-10,63},{-10,14},{21.96,14},{21.96,12.3}},         color={0,0,127}));
  connect(COP, COP)
    annotation (Line(points={{120,-12},{120,-12}}, color={0,0,127}));
  connect(DewT.T_dew,CMP_8. Teva) annotation (Line(points={{-15.44,-56},{-20,
          -56},{-20,-18}},      color={0,0,127}));
  connect(ref_cycle_vs_8.CC_ref, gain.u) annotation (Line(points={{41.17,-23.91},
          {34,-23.91},{34,-33.2}}, color={0,0,127}));
  connect(Evaporator.RefT, DewT.T_eva_in) annotation (Line(points={{22.5,-63.5},
          {22.5,-56},{3.6,-56}},  color={0,0,127}));
  connect(gain.y, Evaporator.HeatFlow)
    annotation (Line(points={{34,-42.4},{33.45,-42.4},{33.45,-54.95}},
                                                     color={0,0,127}));
  connect(DewT.T_dew, ref_cycle_vs_8.Teva) annotation (Line(points={{-15.44,-56},
          {-20,-56},{-20,-22},{-8,-22},{-8,-17.96},{21.96,-17.96}}, color={0,0,
          127}));
  connect(CMP_8.Mode_Output, ref_cycle_vs_8.OnOff) annotation (Line(points={{-5,
          -3.15},{-2,-3},{21.96,-3}}, color={255,127,0}));
  connect(CMP_8.Wel, ref_cycle_vs_8.Wel_map) annotation (Line(points={{-4.8,1.2},
          {-2,1.76},{21.96,1.76}}, color={0,0,127}));
  connect(CMP_8.CC, ref_cycle_vs_8.CC_map) annotation (Line(points={{-4.8,-7.5},
          {-2,-8.1},{21.96,-8.1}}, color={0,0,127}));
  connect(ref_cycle_vs_8.M_ref, Condenser.m_ref) annotation (Line(points={{
          54.26,17.74},{54.85,20},{54.85,52.35}}, color={0,0,127}));
  connect(Condenser.HC_secondary, division.u1) annotation (Line(points={{65.5,
          62.7},{72,62.7},{72,45.2},{78.6,45.2}}, color={0,0,127}));
  connect(ref_cycle_vs_8.Wel_ref, division.u2) annotation (Line(points={{61.91,
          8.73},{72,8.73},{72,36.8},{78.6,36.8}}, color={0,0,127}));
  connect(division.y, COP_system)
    annotation (Line(points={{94.7,41},{96,42},{116,42}}, color={0,0,127}));
  connect(integerConstant.y, CMP_8.Mode) annotation (Line(points={{-61.5,-9},{
          -36.2,-9},{-36.2,-9.15}}, color={255,127,0}));
  connect(CMP_8.CMP_f, CMP_f1) annotation (Line(points={{-36.2,3.15},{-100,3.15},
          {-100,0},{-116,0}}, color={0,0,127}));
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
      StartTime=425100,
      StopTime=436320,
      Interval=60,
      __Dymola_Algorithm="Radau"));
end HeatPump_vs_10_test;
