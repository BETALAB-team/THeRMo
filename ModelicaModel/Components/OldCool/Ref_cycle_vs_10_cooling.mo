within HeatPumpModel.Components.OldCool;
model Ref_cycle_vs_10_cooling "Cooling refrigerant model"

  // -------------Define the medium type----------------------------------------------------------------------------------------------------------------------------------------------------------

  replaceable package Medium = ExternalMedia.Media.CoolPropMedium annotation (choices(
      choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium (mediumName="R290", substanceNames={"R290"}) "R290"),
      choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium (mediumName="R32", substanceNames={"R32"}) "R32"),
      choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium (mediumName="R410A", substanceNames={"R410A"}) "R410A")));

  //--------------Define Inputs-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.RealInput Tcond(unit="K", displayUnit="degC") "condensing temperature - saturated vapor condenser temperature for zeotropic mixtures"
    annotation (Placement(transformation(extent={{-124,-72},{-100,-48}}), iconTransformation(extent={{-124,-72},{-100,-48}})));
  Modelica.Blocks.Interfaces.RealInput Teva(unit="K", displayUnit="degC") "evaporating temperature (dew point)"
    annotation (Placement(transformation(extent={{-124,50},{-100,74}}), iconTransformation(extent={{-124,50},{-100,74}})));
  Modelica.Blocks.Interfaces.RealInput CC_Wel[2]( unit="W") "Cooling capacity and Wel in standardised conditions"
    annotation (Placement(transformation(extent={{-124,8},{-100,32}}),    iconTransformation(extent={{-124,8},{-100,32}})));
  Modelica.Blocks.Interfaces.RealOutput Wel_ref(unit="W") "Electric Power calculated with refrigerant cycle"
    annotation (Placement(transformation(extent={{102,48},{144,90}}), iconTransformation(extent={{102,48},{144,90}})));
  Modelica.Blocks.Interfaces.RealOutput EER "Coeffiicent of performance of the Heat Pump"
    annotation (Placement(transformation(extent={{102,-110},{144,-68}}), iconTransformation(extent={{102,-86},{144,-44}})));
  ExternData.XLSXFile dataSource(fileName=fileName) annotation (Placement(transformation(extent={{-12,-10},{8,10}})));
  Modelica.Blocks.Interfaces.IntegerInput OnOff annotation (Placement(transformation(extent={{-124,-32},{-100,-8}}), iconTransformation(extent={{-124,-32},{-100,-8}})));
  Modelica.Blocks.Interfaces.RealInput SET(unit="K", displayUnit="degC") "evaporating temperature (dew point)"
    annotation (Placement(transformation(extent={{-124,-94},{-100,-70}}), iconTransformation(extent={{-124,-102},{-100,-78}})));
  Modelica.Blocks.Interfaces.RealInput LET(unit="K", displayUnit="degC") "evaporating temperature (dew point)"
    annotation (Placement(transformation(extent={{-124,80},{-100,104}}), iconTransformation(extent={{-124,78},{-100,102}})));
  parameter String fileName="C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xls" "File where polynomials coefficients are stored";

  //--------------HE parameters-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter Real SH(unit="K") = 10 "superheat";
  parameter Real SBC(unit="K") = 5 "subcooling";
  parameter Real F=1 "Dabiri Correlation parameter";
  parameter Real PP_eva(unit="K") = 2 "Evaporator pinch point";
  parameter Real PP_cond(unit="K") = 2 "Condenser pinch point";
  Real SH_map(unit="K") = scalar(dataSource.getRealArray2D("D2", "Polynomials")) "superheat at which the polynomials are  defined";
  Real SBC_map(unit="K") = scalar(dataSource.getRealArray2D("E2", "Polynomials")) "subcooling at which the polynomials are  defined";
  Real SH_real(unit="K") "superheat calculated considering the pinch point";

  //--------------Refrigerant Densities------------------------------------------------------------------------------------------------------------------------------------------------------------

  Real d1_map(unit="kg/m3") "suction density at the Standard conditions";
  Real d1(unit="kg/m3") "suction density ";
  Real d1_vs(unit="kg/m3") "density of saturated vapour at cmp inlet ";
  Real d2_vs(unit="kg/m3") "density of saturated vapour at cmp outlet";

  //--------------Refrigerant Enthalpies-----------------------------------------------------------------------------------------------------------------------------------------------------------

  Real h1_vs(unit="J/kg") "enthalpy of saturated vapour at cmp inlet";
  Real h1_map(unit="J/kg") "enthalpy of vapour at cmp inlet in standard conditions";
  Real h1(unit="J/kg") "enthalpy at cmp inlet";
  Real h2(unit="J/kg") "enthalpy at condenser inlet";
  Real h2_unb(unit="J/kg") "unbonded enthalpy at condenser inlet";
  Real h2_iso_map(unit="J/kg") "isoentropic enthalpy at condenser inlet in standard conditions";
  Real h2_iso(unit="J/kg") "isoentropic enthalpy at condenser inlet";
  Real h2_max(unit="J/kg") "max enthalpy at cmp discharge";
  Real hcond_vs(unit="J/kg") "saturated vapor enthalpy at condenser";
  Real hcond_ls(unit="J/kg") "saturated liquid enthalpy at condenser ";
  Real h3(unit="J/kg") "enthalpy at condenser outlet";
  Real h4(unit="J/kg") "enthalpy at evaporator inlet";
  Real h4_map(unit="J/kg") "enthalpy at evaporator inlet in standard conditions";
  Real Deltah_cond "enthalpy exchanged for condensation in the condenser";
  Real Deltah_eva "enthalpy exchanged for condensation in the evaporator";

  //--------------Refrigerant Pressures------------------------------------------------------------------------------------------------------------------------------------------------------------

  Real Pcond(unit="Pa") "condensing pressure - saturated VAPOUR pressure at condenser inlet";
  Real Peva(unit="Pa") "evaporating pressure - saturated LIQUID pressure at evaporator inlet";

  //--------------Refrigerant Entropies------------------------------------------------------------------------------------------------------------------------------------------------------------

  Real s2_map(unit="J/(kg.K)") "specific entropy at cmp outlet in standard conditions";
  Real s2(unit="J/(kg.K)") "specific entropy at cmp outlet";

  //--------------Refrigerant Temperatures---------------------------------------------------------------------------------------------------------------------------------------------------------

  Real T1_vs(unit="K") "evaporating temperature at saturated vapor conditions";
  Real T1_map(unit="K") "suction temperature at the standard conditions";
  Real T1(unit="K") "suction temperature";
  Real T2(unit="K") "temperature at compressor outlet";
  Real T2_vs(unit="K") "temperature at saturated vapor conditions at condenser inlet";
  Real T3(unit="K") "temperature at saturated liquid conditions at condenser outlet";
  Real T3_map(unit="K") "temperature at saturated liquid conditions at condenser outlet in standard conditions";
  Real T4(unit="K") "temperature at the evaporator inlet";

  //--------------Refrigerant Status---------------------------------------------------------------------------------------------------------------------------------------------------------------

  Medium.SaturationProperties sat1 "saturation at the inlet of the evaporator";
  Medium.SaturationProperties sat2 "unbonded saturation at the inlet of the condenser";
  Medium.SaturationProperties sat3 "saturation at the outlet of the condenser";
  Medium.ThermodynamicState dewState1 "saturated vapor status at the exit of the evaporator";
  Medium.ThermodynamicState dewState2 "saturated vapor status at the inlet of the condenser";

  //--------------Refrigerant Power and Mass------------------------------------------------------------------------------------------------------------------------------------------------------

  Real m_ref(unit="kg/s") "refrigerant mass flow rate";
  Real Wel_ref_unb(unit="W") "unbonded refrigerant power";
  Real Wel_map( unit="W") "refrigerant power in standard conditions";
  Real m_ref_map(unit="kg/s") "refrigerant mass flow rate in standardised conditions";
  Real Ratio "ratio between Wel_unb and refrigerant mass to verify T2 increase";
  Real CC_ref(unit="W") "Cooling capacity";
  Real CC_map(unit="W") "Cooling capacity in standard conditions";

  //--------------Refrigerant Ouput and blocks-----------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.RealOutput CC_tot[3]={CC_ref,m_ref,Teva} "CC refrigerant and refrigerant mass flow rate" annotation (Placement(transformation(
        extent={{-13,-13},{13,13}},
        rotation=90,
        origin={1,113}),  iconTransformation(
        extent={{-13,-13},{13,13}},
        rotation=90,
        origin={1,113})));
  Modelica.Blocks.Interfaces.RealOutput HC_ref annotation (Placement(transformation(
        extent={{-13,-13},{13,13}},
        rotation=-90,
        origin={1,-113}),  iconTransformation(
        extent={{-13,-13},{13,13}},
        rotation=-90,
        origin={1,-113})));
  Modelica.Blocks.Routing.DeMultiplex2 deMultiplex2 annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-70,20})));

 // =================EQUATION BLOCK===============================================================================================================================================================

equation

  //--------------Calculation of saturation pressures and cmp inlet conditions---------------------------------------------------------------------------------------------------------------------

  T1_vs = Teva "temperature at the evaporator inlet";
  T1 = Buildings.Utilities.Math.Functions.smoothMax(
    T1_vs + 1e-4,
    Buildings.Utilities.Math.Functions.smoothMin(
      T1_vs + SH,
      LET - PP_eva,
      1e-5),
    1e-5) "suction temperature";
  SH_real = T1 - T1_vs;
  T1_map = T1_vs + SH_map "suction temperature in standardised conditions";
  sat1 = Medium.setSat_T(T1_vs) "saturation conditions at Teva";
  h1_vs = sat1.hv "enthalpy of saturated vapour at pressure Peva";
  d1_vs = sat1.dv "saturated vapour density at condenser inlet";
  dewState1 = Medium.setState_dT(d1_vs, T1_vs) "dew point at compressor outlet";
  Peva = dewState1.p "assumed Peva = P1_vs, deltaP neglected";

  //--------------Calculation of Enthalpy point 1--------------------------------------------------------------------------------------------------------------------------------------------------

  h1 = Medium.specificEnthalpy_pT(Peva, T1) "suction enthaply";
  h1_map = Medium.specificEnthalpy_pT(Peva, T1_map) "suction enthaply in standardised conditions";

  //--------------Calculation of Densisties point 1-- Daibiri correlations-------------------------------------------------------------------------------------------------------------------------

  d1 = Medium.density_pT(Peva, T1) "suction density";
  d1_map = Medium.density_pT(Peva, T1_map) "suction density at standard conditions";

  //--------------Calculation of saturation pressures- dew point 2--------------------------------------------------------------------------------------------------------------------------------

  T2_vs = Tcond "saturated vapour temperature at condenser inlet";
  sat2 = Medium.setSat_T(T2_vs) "saturation conditions at condenser vapour inlet - sensible desuperheating neglected";
  d2_vs = sat2.dv "saturated vapour density at condenser inlet";
  dewState2 = Medium.setState_dT(d2_vs, T2_vs) "dew point at condenser inlet";
  Pcond = dewState2.p "assumed Pcond = P2_vs, deltaP neglected";

  //--------------Isoenropic Enthalpy point 2 - Daibiri correlations------------------------------------------------------------------------------------------------------------------------------

  s2_map = Medium.specificEntropy_dT(d1_map, T1_map) "specific entropy s1 = s2  for calculation of isoentropic enthaply";
  s2 = Medium.specificEntropy_dT(d1, T1) "specific entropy s1 = s2  for calculation of isoentropic enthaply";
  h2_iso_map = Medium.specificEnthalpy_ps(Pcond, s2_map);
  h2_iso = Medium.specificEnthalpy_ps(Pcond, s2);

  //--------------Calculations points 3 and 4 ----------------------------------------------------------------------------------------------------------------------------------------------------

  sat3 = Medium.setSat_p(Pcond) "saturation condition at condenser outlet";
  T3 = Buildings.Utilities.Math.Functions.smoothMin(
    sat3.Tsat - 1E-4,
    Buildings.Utilities.Math.Functions.smoothMax(
      sat3.Tsat - SBC,
      SET + PP_cond,
      1e-5),
    1e-5) "temperature at the condenser outlet";
  T3_map = sat3.Tsat - SBC_map "temperature at the condenser outlet in standard conditions";
  h3 = Medium.specificEnthalpy_pT(Pcond, T3) "enthalpy at the condenser outlet";
  h4_map = Medium.specificEnthalpy_pT(Pcond, T3_map) "enthalpy at the evaporator inelt in standardised condtions (h3_map = h4_map)";
  h4 = h3 "isoenthalpic lamination";
  T4 = Medium.temperature_ph(Peva, h4) "enthalpy at the condenser outlet";

  //-------------- Calculation of m_ref_map -------------------------------------------------------------------------------------------------------------------------------------------------------

  CC_map = deMultiplex2.y1[1];
  m_ref_map = CC_map/(h1_map - h4_map);

 //-------------- Calculation of max T2 temperature------------------------------------------------------------------------------------------------------------------------------------------------

  Wel_map = deMultiplex2.y2[1];
  m_ref = m_ref_map*(1 + F*(d1/d1_map - 1));
  Wel_ref_unb = Wel_map*m_ref*(h2_iso - h1)/(Buildings.Utilities.Math.Functions.smoothMax(m_ref_map, 1e-4, 1e-5)*(h2_iso_map - h1_map));
  h2_unb = Buildings.Utilities.Math.Functions.smoothMax(
    Wel_ref_unb/max(m_ref, 1e-4) + h1,
    h1,
    1e-5) "enthalpy at compressor outlet without upper limitation";
  h2_max = Medium.specificEnthalpy_pT(
    Pcond,
    150 + 273.15,
    1) "maximum enthalpy allowed at the outlet of the compressor";
  h2 = Buildings.Utilities.Math.Functions.smoothMin(h2_unb, h2_max, 1e-5) "real entalpy at the condenser outlet";
  T2 = Medium.temperature_ph(Pcond, h2);

 //-------------- Calculation of Energy Balances--------------------------------------------------------------------------------------------------------------------------------------------------

  Wel_ref = Buildings.Utilities.Math.Functions.smoothMax(
    m_ref*(h2 - h1),
    1e-4,
    1e-5) "calculation of cmp power using the refrigerant cycle";
  HC_ref = Buildings.Utilities.Math.Functions.smoothMax(
    m_ref*(h2 - h3),
    1e-4,
    1e-5) "calculation of heating capacity using the refrigerant cycle";
  CC_ref = Buildings.Utilities.Math.Functions.smoothMax(
    m_ref*(h1 - h4),
    1e-4,
    1e-5) "calculation of cooling  capacity using the refrigerant cycle";
  EER = Buildings.Utilities.Math.Functions.smoothMax(
    CC_ref/Wel_ref,
    1e-4,
    1e-5) "calculation of energy efficency ratio";

  //-------------- Calculation of percentage of heat exchanged in condensation and evaporation-----------------------------------------------------------------------------------------------------

  hcond_vs = sat2.hv;
  hcond_ls = sat2.hl;
  Deltah_cond = (hcond_vs - hcond_ls)/(h2 - h3) " quantity of heat transferred due to phase change";
  Deltah_eva = (h1_vs - h4)/(h1 - h4);
  Ratio = Wel_ref_unb/max(m_ref, 1e-4);
  connect(CC_Wel, deMultiplex2.u) annotation (Line(points={{-112,20},{-77.2,20}}, color={0,0,127}));
  annotation (
    Icon(graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineThickness=1),
        Bitmap(extent={{-96,-100},{94,110}},fileName="modelica://HeatPumpModel/../Incons/Immagine 2025-11-14 124316.png"),
        Text(
          extent={{-84,-88},{88,-132}},
          textColor={0,0,255},
          textString="Ref Cycle

")}),
    Icon(graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineThickness=1),
        Bitmap(extent={{-96,-74},{94,98}}, fileName="modelica://HeatPumpModel/../Incons/Immagine 2025-11-14 124316.png"),
        Text(
          extent={{-54,-66},{46,-84}},
          textColor={0,0,0},
          textString="%name
")}),
    experiment(
      StopTime=1,
      Tolerance=1e-05,
      __Dymola_Algorithm="Dassl"));
end Ref_cycle_vs_10_cooling;
