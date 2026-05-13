within HeatPumpModel.Components;
model Ref_cycle_vs_1
  import Modelica.Units.SI;

// Define the medium type
   replaceable package Medium = ExternalMedia.Media.CoolPropMedium(
        mediumName = "R410a",
        substanceNames = {"R410a"})
        annotation (choices(choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R290",substanceNames = {"R290"}) "R290"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R32",substanceNames = {"R32"})
                                                                                                                                             "R32"),
                            choice(redeclare package Medium = ExternalMedia.Media.CoolPropMedium(mediumName = "R410A",substanceNames = {"R410A"})
                                                                                                                                                 "R410A")));

//Define Parameters
  Modelica.Blocks.Interfaces.RealInput Tcond(unit="K")
    "condensing temperature - saturated vapor condenser temperature for zeotropic mixtures"
    annotation (Placement(transformation(extent={{-124,72},{-100,96}}),
        iconTransformation(extent={{-124,72},{-100,96}})));
  Modelica.Blocks.Interfaces.RealInput Teva(unit="K")
    "evaporating temperature - evaporator inlet for zeotropric mixtures"
    annotation (Placement(transformation(extent={{-124,40},{-100,64}}),
        iconTransformation(extent={{-124,40},{-100,64}})));
  Modelica.Blocks.Interfaces.RealInput Wel(unit = "W") "compressor power"
    annotation (Placement(transformation(extent={{-124,8},{-100,32}}),
        iconTransformation(extent={{-124,8},{-100,32}})));
  Modelica.Blocks.Interfaces.RealInput HC(unit = "W") "heating capacity"
    annotation (Placement(transformation(extent={{-124,-26},{-100,-2}}),
        iconTransformation(extent={{-124,-26},{-100,-2}})));
  Modelica.Blocks.Interfaces.RealInput CC(unit = "W") "cooling capacity"
    annotation (Placement(transformation(extent={{-124,-60},{-100,-36}}),
        iconTransformation(extent={{-124,-60},{-100,-36}})));
  Modelica.Blocks.Interfaces.RealOutput HC_ref( unit = "W")
    "heating capacity calculated with refrigerant cycle" annotation (Placement(
        transformation(extent={{102,4},{144,46}}),   iconTransformation(extent={{102,4},
            {144,46}})));

 parameter Modelica.Units.SI.Temperature SH  = 10 "superheat";
 parameter Modelica.Units.SI.Temperature SBC = 5  "subcooling";
 parameter String fluidName;

 ///Enthalpies and densities
 Real h1_vs(unit = "J/kg") "enthalpy of saturated vapour at cmp inlet";
 Real d2_vs(unit = "kg/m3") "density of saturated vapour at cmp outlet";
 Real h1(unit = "J/kg") "enthalpy at cmp inlet";
 Real h2( unit = "J/kg") "enthalpy at condenser inlet";
 Real h3( unit = "J/kg") "enthalpy at condenser outlet";
 Real h4( unit = "J/kg") "enthalpy at evaporator inlet";

 ///Pressures
 Real Pcond(unit="Pa") "condensing pressure - saturated VAPOUR pressure at condenser inlet";
 Real Peva(unit="Pa") "evaporating pressure - saturated LIQUID pressure at evaporator inlet";

 ///Temperatures
 Real T1_vs( unit ="K") "evaporating temperature at saturated vapor conditions";
 Real T1(  unit ="K") "suction temperature";
 Real T2(  unit ="K") "temperature at compressor outlet";
 Real T2_vs( unit ="K") "temperature at saturated vapor conditions at condenser inlet";
 Real T3( unit ="K") "temperature at saturated liquid conditions at condenser outlet";
 Real T4( unit ="K") "temperature at the evaporator inlet";

 ///Thermodynamic statuses
 Medium.SaturationProperties sat4 "saturation at the inlet of the evaporator";
 Medium.SaturationProperties sat2 "saturation at the inlet of the condenser";
 Medium.SaturationProperties sat3 "saturation at the outlet of the condenser";
 Medium.ThermodynamicState dewState1 "saturated vapor status at the exit of the evaporaTor";
 Medium.ThermodynamicState dewState2 "saturated vapor status at the inlet of the condenser";
 Medium.ThermodynamicState state2 "thermodynamic status at compressor outlet";

 ///Mass flow rate
 Real m_ref(  unit ="kg/s") "refigerant mass flow rate";

equation
  ///Calculation of saturation pressures and cmp inlet conditions"
  T4 = Teva "temperature at the evaporator inlet";
  Peva =Medium.saturationPressure(T4) "assumed Peva = P4_ls, deltaP neglected";
  sat4 = Medium.setSat_p(Peva) "saturation conditions at Peva";
  h1_vs = sat4.hv "enthalpy of saturated vapour at pressure Peva";
  dewState1 = Medium.setState_ph(Peva,h1_vs) "dew point at cmp inlet";
  T1_vs = dewState1.T "saturated vapour temperature at compressor inlet";
  T1 = T1_vs + SH "suction temperature";

  ///Enthalpy point 1
  h1 = Medium.specificEnthalpy_pT(Peva,T1) "suction enthaply";

  ///Calculation of saturation pressures- dew point 2
  T2_vs = Tcond "saturated vapour temperature at condenser inlet";
  sat2 = Medium.setSat_T(T2_vs) "saturation conditions at condenser vapour inlet - sensible desuperheating neglected";
  d2_vs = sat2.dv "saturated vapour density at condenser inlet";
  dewState2 =Medium.setState_dT(d2_vs, T2_vs) "dew point at condenser inlet";
  Pcond = dewState2.p "assumed Pcond = P2_vs, deltaP neglected";

  ///Enthalpy point 3 and 4
  sat3 = Medium.setSat_p(Pcond) "saturation condition at condenser outlet";
  T3 = sat3.Tsat - SBC "temperature at the condenser outlet";
  h3 = Medium.specificEnthalpy_pT(Pcond,T3) "entalpy at the condenser outlet";
  h4 = h3 "isoenthalpic lamination";

  ///Energy balance
  m_ref = CC/(h1- h4) "refrigerant mass flow rate";
  h2 = Wel/m_ref + h1 "enthalpy at compressor outlet";
  state2 = Medium.setState_ph(Pcond,h2) "thermodynamic status at compressor outlet";
  T2 = state2.T "temperature at the compressor outlet";
  HC_ref = m_ref*(h2-h3) "calculation of heating capacity using the refrigerant cycle";

  annotation (Icon(graphics={
        Rectangle(
          extent={{-100,100},{98,-72}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineThickness=1),
        Bitmap(extent={{-96,-84},{94,126}}, fileName=
              "modelica://HeatPumpModel/../Incons/Immagine 2025-11-14 124316.png"),
        Text(
          extent={{-86,-42},{86,-86}},
          textColor={0,0,0},
          textString="%name
")}));
end Ref_cycle_vs_1;
