within HeatPumpModel.Components.Cooling;
model HeatPump_vs_1_cooling

  HeatPumpModel.Components.Cooling.CMP_poly_vs_8_cooling cMP_poly_vs_8_cooling(fileName=fileName, CMP_type=CMP_type) annotation (Placement(transformation(extent={{-48,-16},{-14,16}})));
  Ref_cycle_vs_9_cooling ref_cycle_vs_9_cooling(
    redeclare package Medium = Medium,
    fileName=fileName,
    SH=SH,
    SBC=SBC,
    F=F,
    PP_eva=PP_eva,
    PP_cond=PP_cond) annotation (Placement(transformation(extent={{30,-14},{60,16}})));
  HeatPumpModel.Components.Cooling.Evaporator_vs_3_cooling EvaCool(
    redeclare package Medium = eva_medium_cool,
    fileName=fileName_eva_cool,
    m_flow_nominal=m_flow_eva_cool_nominal,
    m_ref_nom=m_ref_nom,
    dp_nominal=dp_eva_cool_nominal,
    UA_nom=UA_nom_eva_cool,
    UA_value_eva_cool=UA_value_eva_cool,
    Tau_cost_eva_cool=Tau_cost_eva_cool,
    V_eva_cool=V_eva_cool) annotation (Placement(transformation(extent={{31,48},{57,74}})));
  HeatPumpModel.Components.Cooling.Condenser_vs_2_cooling CondCool(
    redeclare package Medium = cond_medium_cool,
    UA_nom_cond_cool=UA_nom_cond_cool,
    UA_value_cond_cool=UA_value_cond_cool,
    Tau_cost_cond_cool=Tau_cost_cond_cool,
    V_cond_cool=V_cond_cool,
    m_flow_nominal=m_flow_cond_cool_nominal,
    dp_nominal=dp_cond_cool_nominal) annotation (Placement(transformation(extent={{31,-48},{57,-74}})));

  Modelica.Fluid.Interfaces.FluidPort_a Load_in(redeclare package Medium = eva_medium_cool) "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-114,50},{-94,70}}), iconTransformation(extent={{-120,60},{-100,80}})));
  Modelica.Fluid.Interfaces.FluidPort_b Load_out(redeclare package Medium = eva_medium_cool) "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{94,50},{114,70}}), iconTransformation(extent={{100,60},{120,80}})));
  Modelica.Fluid.Interfaces.FluidPort_a Source_in(redeclare package Medium = cond_medium_cool) "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-116,-70},{-96,-50}}), iconTransformation(extent={{-120,-80},{-100,-60}})));
  Modelica.Fluid.Interfaces.FluidPort_b Source_out(redeclare package Medium = cond_medium_cool) "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{94,-70},{114,-50}}), iconTransformation(extent={{100,-80},{120,-60}})));
  Modelica.Blocks.Interfaces.RealInput CMP_f "Compressor frequency / speed " annotation (Placement(transformation(extent={{-114,14},{-102,26}}), iconTransformation(extent={{-114,14},{-102,26}})));
  Modelica.Blocks.Interfaces.IntegerInput OperationMode "operating mode" annotation (Placement(transformation(extent={{-114,-26},{-102,-14}}), iconTransformation(extent={{-114,-26},{-102,-14}})));
  Modelica.Fluid.Sensors.Temperature LET(redeclare package Medium = eva_medium_cool) annotation (Placement(transformation(extent={{-2,38},{14,22}})));
  Modelica.Fluid.Sensors.Temperature SET(redeclare package Medium = cond_medium_cool) annotation (Placement(transformation(extent={{-2,-40},{14,-24}})));
  Heating.Dew_T_calculation DewT(redeclare package Medium = Medium) annotation (Placement(transformation(
        extent={{-9,-9},{9,9}},
        rotation=-90,
        origin={-31,37})));

  //---------------Medium Replaceble Packages-----------------------------------------------------------------------------------------------------------------------------------------------------

  replaceable package Medium = ExternalMedia.Media.CoolPropMedium annotation (choices(
      choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium (mediumName="R290", substanceNames={"R290"}) "R290"),
      choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium (mediumName="R32", substanceNames={"R32"}) "R32"),
      choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium (mediumName="R410A", substanceNames={"R410A"}) "R410A")), Dialog(group="Refrigerant"));
  replaceable package cond_medium_cool = Modelica.Media.Interfaces.PartialMedium annotation (choicesAllMatching=true, Dialog(group="Condenser_cooling"));
  replaceable package eva_medium_cool = Modelica.Media.Interfaces.PartialMedium annotation (choicesAllMatching=true, Dialog(group="Evaporator_cooling"));


  //-------------Input Parameters Refrigerant Cycle------------------------------------------------------------------------------------------------------------------------------------------------

  parameter Real SH(unit="K") = 10 "superheat" annotation (Dialog(group="Refrigerant"));
  parameter Real SBC(unit="K") = 5 "subcooling" annotation (Dialog(group="Refrigerant"));
  parameter Real PP_eva(unit="K") = 2 "Evaporator pinch point" annotation (Dialog(group="Evaporator_cooling"));
  parameter Real PP_cond(unit="K") = 2 "Condenser pinch point" annotation (Dialog(group="Condenser_cooling"));


  //-------------Input Parameters CMP------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String fileName="Select a compressor model" "File path where polynomial coefficients are stored" annotation (choices(
      choice="C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xlsx",
      choice="C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VRJ028-K polynomials.xlsx",
      choice="C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VZH028CH polynomials.xlsx",
      choice="C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Copeland/XHV0181P-9E9-ED3015A polynomials.xlsx"), Dialog(group="CMP"));
  parameter Real F "Dabiri Correlation parameter" annotation (Dialog(group="CMP"));
  parameter String CMP_type="Fixed speed" annotation (choices(
      choice="Fixed speed",
      choice="Variable speed 20 coeff",
      choice="Variable speed 30 coeff"), Dialog(group="CMP"));


  //-------------Input Parameters Condenser Cooling------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String UA_value_cond_cool="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"), Dialog(group="Condenser_cooling"));
  parameter Modelica.Units.SI.Time Tau_cost_cond_cool(displayUnit="min") = 900 "Time Constant" annotation (Dialog(group="Condenser_cooling"));
  parameter Modelica.Units.SI.Volume V_cond_cool "Volume" annotation (Dialog(group="Condenser_cooling"));
  parameter Real UA_nom_cond_cool=1000 "Heat transfer coefficient- area product" annotation (Dialog(group="Condenser_cooling"));
  parameter Modelica.Units.SI.MassFlowRate m_flow_cond_cool_nominal "Nominal mass flow rate" annotation (Dialog(group="Condenser_cooling"));
  parameter Modelica.Units.SI.PressureDifference dp_cond_cool_nominal "Pressure difference" annotation (Dialog(group="Condenser_cooling"));

  //-------------Input Parameters Evaporator Cooling----------------------------------------------------------------------------------------------------------------------------------------------

  parameter Modelica.Units.SI.MassFlowRate m_flow_eva_cool_nominal "Nominal mass flow rate" annotation (Dialog(group="Evaporator_cooling"));
  parameter Modelica.Units.SI.PressureDifference dp_eva_cool_nominal "Pressure difference" annotation (Dialog(group="Evaporator_cooling"));
  parameter Real UA_nom_eva_cool(unit="W/K") = 1000 "Heat transfer/ area product" annotation (Dialog(group="Evaporator_cooling"));
  parameter Real m_ref_nom(unit="kg/s") "Nominal refrigerant mass flow rate [kg/s]" annotation (Dialog(group="Evaporator_cooling"));
  parameter String fileName_eva_cool="C:/Users\benafra10167/Desktop/HE_polynomial/B8T.xlsx" "File path where polynomial coefficients are stored" annotation (choices(
      choice="C:/Users/benafra10167/Desktop/HE_polynomial/B8T.xlsx",
      choice="C:/Users/benafra10167/Desktop/HE_polynomial/B10T.xlsx",
      choice="C:/Users/benafra10167/Desktop/HE_polynomial/B8LAS.xlsx",
      choice="C:/Users/benafra10167/Desktop/HE_polynomial/B16.xlsx",
      choice="C:/Users/benafra10167/Desktop/HE_polynomial/B16_cooling.xlsx"), Dialog(group="Evaporator_cooling"));
  parameter Modelica.Units.SI.Time Tau_cost_eva_cool(displayUnit="min") = 900 "Time Constant of Eva Filter" annotation (Dialog(group="Evaporator_cooling"));
  parameter Modelica.Units.SI.Volume V_eva_cool "Volume" annotation (Dialog(group="Evaporator_cooling"));
  parameter String UA_value_eva_cool="Select how to calculate UA" annotation (choices(choice="Nominal value", choice="Parametric correlation"), Dialog(group="Evaporator_cooling"));


  Modelica.Blocks.Math.Division division annotation (Placement(transformation(extent={{72,30},{86,44}})));
  Modelica.Blocks.Interfaces.RealOutput EER_system "Connector of Real output signal" annotation (Placement(transformation(extent={{100,14},{114,28}}), iconTransformation(extent={{100,14},{114,28}})));
  Modelica.Blocks.Interfaces.RealOutput EER "Coeffiicent of performance of the Heat Pump"
    annotation (Placement(transformation(extent={{100,-30},{114,-16}}), iconTransformation(extent={{100,-30},{114,-16}})));
equation
  connect(ref_cycle_vs_9_cooling.CC_tot, EvaCool.CC_tot) annotation (Line(points={{45.15,17.95},{44,17.95},{44,46.44}}, color={0,0,127}));
  connect(CondCool.HeatFlow, ref_cycle_vs_9_cooling.HC_ref) annotation (Line(points={{43.87,-46.57},{45.15,-44},{45.15,-15.95}}, color={0,0,127}));
  connect(cMP_poly_vs_8_cooling.CC_Wel, ref_cycle_vs_9_cooling.CC_Wel) annotation (Line(points={{-11.62,3.2},{-11.62,4},{28.2,4}}, color={0,0,127}));
  connect(cMP_poly_vs_8_cooling.Mode_Output, ref_cycle_vs_9_cooling.OnOff) annotation (Line(points={{-11.79,-3.36},{-11.79,-2},{28.2,-2}}, color={255,127,0}));
  connect(EvaCool.RefT, ref_cycle_vs_9_cooling.Teva) annotation (Line(points={{29.7,55.8},{-12,55.8},{-12,8},{28.2,8},{28.2,10.3}}, color={0,0,127}));
  connect(Load_in, Load_in) annotation (Line(points={{-104,60},{-104,60}}, color={0,127,255}));
  connect(EvaCool.port_b, Load_out) annotation (Line(points={{57,61},{56,61},{56,60},{104,60}}, color={0,127,255}));
  connect(CondCool.port_a, Source_in) annotation (Line(points={{31,-61},{31.5,-61},{31.5,-60},{-106,-60}}, color={0,127,255}));
  connect(Load_in, EvaCool.port_a) annotation (Line(points={{-104,60},{30,60},{30,61},{31,61}}, color={0,127,255}));
  connect(Source_in, Source_in) annotation (Line(points={{-106,-60},{-106,-60}}, color={0,127,255}));
  connect(CondCool.RefT, cMP_poly_vs_8_cooling.Tcond) annotation (Line(points={{29.7,-54.5},{-31,-54.5},{-31,-18.24}}, color={0,0,127}));
  connect(CondCool.RefT, ref_cycle_vs_9_cooling.Tcond) annotation (Line(points={{29.7,-54.5},{-12,-54.5},{-12,-8},{28.2,-8}}, color={0,0,127}));
  connect(CondCool.port_b, Source_out) annotation (Line(points={{57,-61},{56,-61},{56,-60},{104,-60}}, color={0,127,255}));
  connect(cMP_poly_vs_8_cooling.CMP_f, CMP_f) annotation (Line(points={{-50.21,3.04},{-96,3.04},{-96,20},{-108,20}}, color={0,0,127}));
  connect(cMP_poly_vs_8_cooling.Mode, OperationMode) annotation (Line(points={{-50.21,-3.04},{-96,-3.04},{-96,-20},{-108,-20}}, color={255,127,0}));
  connect(SET.port, Source_in) annotation (Line(points={{6,-40},{6,-60},{-106,-60}}, color={0,127,255}));
  connect(SET.T, ref_cycle_vs_9_cooling.SET) annotation (Line(points={{11.6,-32},{20,-32},{20,-12.5},{28.2,-12.5}}, color={0,0,127}));
  connect(LET.T, ref_cycle_vs_9_cooling.LET) annotation (Line(points={{11.6,30},{20,30},{20,14.5},{28.2,14.5}}, color={0,0,127}));
  connect(LET.port, EvaCool.port_a) annotation (Line(points={{6,38},{6,60},{30,60},{30,61},{31,61}}, color={0,127,255}));
  connect(EvaCool.RefT, DewT.T_eva_in) annotation (Line(points={{29.7,55.8},{-12,55.8},{-12,56},{-31,56},{-31,47.8}}, color={0,0,127}));
  connect(DewT.T_dew, cMP_poly_vs_8_cooling.Teva) annotation (Line(points={{-31,26.38},{-31.17,26.38},{-31.17,18.08}}, color={0,0,127}));
  connect(ref_cycle_vs_9_cooling.Wel_ref, division.u2) annotation (Line(points={{63.45,11.35},{62,11.35},{62,32.8},{70.6,32.8}}, color={0,0,127}));
  connect(EvaCool.CC_secondary, division.u1) annotation (Line(points={{58.3,55.54},{64,55.54},{64,41.2},{70.6,41.2}}, color={0,0,127}));
  connect(division.y, EER_system) annotation (Line(points={{86.7,37},{96,37},{96,21},{107,21}}, color={0,0,127}));
  connect(ref_cycle_vs_9_cooling.EER, EER) annotation (Line(points={{63.45,-8.75},{63.45,-23},{107,-23}}, color={0,0,127}));
  annotation (Icon(graphics={
        Rectangle(
          extent={{-80,80},{80,-80}},
          lineColor={28,108,200},
          lineThickness=1,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Bitmap(extent={{-68,-70},{78,80}}, fileName="modelica://HeatPumpModel/../Incons/HP Cooling.png"),
        Text(
          extent={{-48,-58},{58,-86}},
          textColor={0,0,255},
          textString="HP Cooling Mode
")}));
end HeatPump_vs_1_cooling;
