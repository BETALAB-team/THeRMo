within HeatPumpModel.Components;
model Ref_cycle_vs_3 "Refrigerant cycle with Daibiri correlation"

// Define the medium type
  replaceable package Medium = ExternalMedia.Media.CoolPropMedium
        annotation (choices(choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R290",substanceNames = {"R290"}) "R290"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R32",substanceNames = {"R32"})
                                                                                                                                             "R32"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R410A",substanceNames = {"R410A"})
                                                                                                                                                 "R410A")));

//Define Parameters
  Modelica.Blocks.Interfaces.RealInput Tcond(unit="K", displayUnit ="degC")
    "condensing temperature - saturated vapor condenser temperature for zeotropic mixtures"
    annotation (Placement(transformation(extent={{-124,76},{-100,100}}),
        iconTransformation(extent={{-124,76},{-100,100}})));
  Modelica.Blocks.Interfaces.RealInput Teva(unit="K", displayUnit ="degC")
    "evaporating temperature - evaporator inlet for zeotropric mixtures"
    annotation (Placement(transformation(extent={{-124,-94},{-100,-70}}),
        iconTransformation(extent={{-124,-94},{-100,-70}})));
  Modelica.Blocks.Interfaces.RealInput Wel_map(unit = "W") "compressor power"
    annotation (Placement(transformation(extent={{-124,14},{-100,38}}),
        iconTransformation(extent={{-124,14},{-100,38}})));
  Modelica.Blocks.Interfaces.RealInput HC_map(unit = "W") "heating capacity"
    annotation (Placement(transformation(extent={{-124,42},{-100,66}}),
        iconTransformation(extent={{-124,42},{-100,66}})));
  Modelica.Blocks.Interfaces.RealInput CC_map(unit = "W") "cooling capacity"
    annotation (Placement(transformation(extent={{-124,-62},{-100,-38}}),
        iconTransformation(extent={{-124,-62},{-100,-38}})));
  Modelica.Blocks.Interfaces.RealOutput HC_ref( unit = "W")
                                                           "heating capacity calculated with refrigerant cycle"
    annotation (Placement(
        transformation(extent={{102,60},{144,102}}), iconTransformation(extent={{102,60},
            {144,102}})));
  Modelica.Blocks.Interfaces.RealInput m_ref_map(unit="kg/s")
                                                             "refrigerant mass flow rate in standardised conditions"
     annotation (Placement(transformation(extent={{-124,
            -32},{-100,-8}}),  iconTransformation(extent={{-124,-32},{-100,-8}})));
  Modelica.Blocks.Interfaces.RealOutput CC_ref(unit="W")
    "heating capacity calculated with refrigerant cycle" annotation (Placement(
        transformation(extent={{102,-76},{144,-34}}), iconTransformation(extent={{102,-52},
            {144,-10}})));

  Modelica.Blocks.Interfaces.RealOutput Wel_ref(unit="W")
    "heating capacity calculated with refrigerant cycle" annotation (Placement(
        transformation(extent={{102,16},{144,58}}),  iconTransformation(extent={{102,16},
            {144,58}})));


  Modelica.Blocks.Interfaces.RealOutput COP
    "Coeffiicent of performance of the Heat Pump" annotation (Placement(
        transformation(extent={{102,-110},{144,-68}}),iconTransformation(extent={{102,-98},
            {144,-56}})));

 ExternData.XLSFile dataSource(fileName = fileName)
    annotation (Placement(transformation(extent={{-12,-10},{8,10}})));

 parameter String fileName="C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xls"
    "File where polynomials coefficients are stored";

 parameter Real SH( unit = "K") = 10 "superheat";
 parameter Real SBC( unit = "K")= 5 "subcooling";
 parameter Real F = 0.7 "Dabiri Correlation parameter";
 Real SH_map( unit = "K") = scalar(dataSource.getRealArray2D("D2","Polynomials")) "superheat at which the polynomials are  defined";

 //Densities
 Real d1_map( unit = "kg/m3") "suction density at the Standard conditions";
 Real d1( unit = "kg/m3") "suction density ";
 Real d2_vs(unit = "kg/m3") "density of saturated vapour at cmp outlet";

 //Enthalpies
 Real h1_vs(unit = "J/kg") "enthalpy of saturated vapour at cmp inlet";
 Real h1(unit = "J/kg") "enthalpy at cmp inlet";
 Real h2( unit = "J/kg") "enthalpy at condenser inlet";
 Real h2_iso_map( unit = "J/kg") "isoentropic enthalpy at condenser inlet in standard conditions";
 Real h2_iso(  unit = "J/kg") "isoentropic enthalpy at condenser inlet";
 Real h3( unit = "J/kg") "enthalpy at condenser outlet";
 Real h4( unit = "J/kg") "enthalpy at evaporator inlet";

 //Pressures
 Real Pcond(unit="Pa") "condensing pressure - saturated VAPOUR pressure at condenser inlet";
 Real Peva(unit="Pa") "evaporating pressure - saturated LIQUID pressure at evaporator inlet";

 //Entropies
 Real s2_map(  unit = "J/(kg.K)") "specific entropy at cmp outlet in standard conditions";
 Real s2(  unit = "J/(kg.K)") "specific entropy at cmp outlet";

 //Temperatures
 Real T1_vs( unit ="K") "evaporating temperature at saturated vapor conditions";
 Real T1_map( unit = "K") "suction temperature at the standard conditions";
 Real T1(  unit ="K") "suction temperature";
 Real T2(  unit ="K") "temperature at compressor outlet";
 Real T2_vs( unit ="K") "temperature at saturated vapor conditions at condenser inlet";
 Real T3( unit ="K") "temperature at saturated liquid conditions at condenser outlet";
 Real T4( unit ="K") "temperature at the evaporator inlet";

 //Thermodynamic statuses
 Medium.SaturationProperties sat4 "saturation at the inlet of the evaporator";
 Medium.SaturationProperties sat2 "saturation at the inlet of the condenser";
 Medium.SaturationProperties sat3 "saturation at the outlet of the condenser";
 Medium.ThermodynamicState dewState1 "saturated vapor status at the exit of the evaporator";
 Medium.ThermodynamicState dewState2 "saturated vapor status at the inlet of the condenser";
 Medium.ThermodynamicState state2 "thermodynamic status at compressor outlet";

 //Mass flow rate
 Real m_ref( unit = "kg/s") "refrigerant mass flow rate";

  Modelica.Blocks.Interfaces.IntegerInput OnOff annotation (Placement(
        transformation(extent={{-128,-14},{-100,14}}), iconTransformation(
          extent={{-128,-14},{-100,14}})));
equation
  //Calculation of saturation pressures and cmp inlet conditions"
  T4 = Teva "temperature at the evaporator inlet";
  Peva =Medium.saturationPressure(T4) "assumed Peva = P4_ls, deltaP neglected";
  sat4 = Medium.setSat_p(Peva) "saturation conditions at Peva";
  h1_vs = sat4.hv "enthalpy of saturated vapour at pressure Peva";
  dewState1 = Medium.setState_ph(Peva,h1_vs) "dew point at cmp inlet";
  T1_vs = dewState1.T "saturated vapour temperature at compressor inlet";
  T1 = T1_vs + SH "suction temperature";
  T1_map = T1_vs + SH_map "suction temperature in standardised conditions";

  //Enthalpy point 1
  h1 = Medium.specificEnthalpy_pT(Peva,T1) "suction enthaply";

  //Density evaluation - Dabiri correlations
  d1 = Medium.density_pT(Peva,T1) "suction density";
  d1_map = Medium.density_pT(Peva,T1_map) "suction density at standard conditions";

  //Calculation of saturation pressures- dew point 2
  T2_vs = Tcond "saturated vapour temperature at condenser inlet";
  sat2 = Medium.setSat_T(T2_vs) "saturation conditions at condenser vapour inlet - sensible desuperheating neglected";
  d2_vs = sat2.dv "saturated vapour density at condenser inlet";
  dewState2 =Medium.setState_dT(d2_vs, T2_vs) "dew point at condenser inlet";
  Pcond = dewState2.p "assumed Pcond = P2_vs, deltaP neglected";

  //Isoenropic Enthalpy point 2 - Daibiri correlations
  s2_map = Medium.specificEntropy_dT(d1_map,T1_map) "specific entropy s1 = s2  for calculation of isoentropic enthaply";
  s2 = Medium.specificEntropy_dT(d1,T1) "specific entropy s1 = s2  for calculation of isoentropic enthaply";
  h2_iso_map = Medium.specificEnthalpy_ps(Pcond,s2_map);
  h2_iso = Medium.specificEnthalpy_ps(Pcond,s2);

  //Enthalpy point 3 and 4
  sat3 = Medium.setSat_p(Pcond) "saturation condition at condenser outlet";
  T3 = sat3.Tsat - SBC "temperature at the condenser outlet";
  h3 = Medium.specificEnthalpy_pT(Pcond,T3) "entalpy at the condenser outlet";
  h4 = h3 "isoenthalpic lamination";

  //Energy balance
  if OnOff ==1 then
    m_ref = m_ref_map *(1+ F*(d1/d1_map - 1)) "refrigerant mass flow rate calculated at real operative conditions";
    Wel_ref =  Wel_map * m_ref * (h2_iso - h1)/(m_ref_map * (h2_iso_map - h1)) "eletric power calculated at real operative conditions";
    h2 = Wel_ref/m_ref + h1 "enthalpy at compressor outlet";
    state2 = Medium.setState_ph(Pcond,h2) "thermodynamic status at compressor outlet";
    T2 = state2.T "temperature at the compressor outlet";
    HC_ref = m_ref*(h2-h3) "calculation of heating capacity using the refrigerant cycle";
    CC_ref = m_ref*(h1-h4) "calculation of cooling capacity using the refrigerant cycle";
    COP = HC_ref / Wel_ref "Coefficient of performance";
  else
    m_ref = 0 "refrigerant mass flow rate calculated at real operative conditions";
    Wel_ref =  0 "eletric power calculated at real operative conditions";
    h2 = 0 "enthalpy at compressor outlet";
    state2 = Medium.setState_ph(Pcond,h3) "thermodynamic status at compressor outlet- FICTIOUS ONE, calculated because of the necessity of using real thermodynamic variables";
    T2 = 0 "temperature at the compressor outlet";
    HC_ref = 0 "calculation of heating capacity using the refrigerant cycle";
    CC_ref = 0 "calculation of cooling capacity using the refrigerant cycle";
    COP = 0 "Coefficient of performance";
  end if;

  annotation (Icon(graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineThickness=1),
        Bitmap(extent={{-96,-84},{94,126}}, fileName=
              "modelica://HeatPumpModel/../Incons/Immagine 2025-11-14 124316.png"),
        Text(
          extent={{-78,-68},{94,-112}},
          textColor={0,0,0},
          textString="%name
")}));
end Ref_cycle_vs_3;
