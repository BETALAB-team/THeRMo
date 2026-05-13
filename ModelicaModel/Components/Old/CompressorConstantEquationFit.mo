within HeatPumpModel.Components;
model CompressorConstantEquationFit

  //Polynomial coefficients definition

  //parameter Real el_coef[10] = {386.5864,3.235339,-0.7616182,0.1194096,0.08058198,0.215179,0.002509841,-0.00307912,0.00144556,-0.001730154};
  //parameter Real ev_coef[10] = {3252.474,126.4527,-53.45925,1.92338,-1.031104,0.6149533,0.00867232,-0.01493142,0.000188762,-0.00411726};

  parameter Real cc_coef[10] = {23063.53543,1015.56806,-517.1277597,17.53530854,-22.91158901,9.061634778,0.104756711,-0.272989555,0.210613921,-0.074503046} "HRH054U4 Danfoss SH = 10 K SBC = 5 K";
  parameter Real el_coef[10] = {876.1403637,-39.82611698,57.76683426,-0.692542019,1.405959399,-0.322407086,-0.004151195,6.97E-03,-0.012434452,0.008498258} "HRH054U4 Danfoss SH = 10 K SBC = 5 K";
  parameter Real m_coef[10] = {364.3609034,16.87580007,-7.416902114,0.291539796,-0.393057063,0.169437224,0.00190869,-0.004316934,0.004557808,-0.001395934} "HRH054U4 Danfoss SH = 10 K SBC = 5 K";



  //Parameter definition
  Modelica.Blocks.Interfaces.IntegerInput Mode "operating mode" annotation (Placement(transformation(extent={{-126,20},{-86,60}})));
  Modelica.Blocks.Interfaces.RealInput Tcond(unit="K")
                                                      "condensing temperaure"  annotation (Placement(transformation(extent={{-128,-60},{-88,-20}})));
  Modelica.Blocks.Interfaces.RealInput Teva(unit="K")
                                                     "evaporating temperature"  annotation (Placement(transformation(extent={{-128,-104},{-88,-64}})));
  Modelica.Blocks.Interfaces.RealOutput Wel(unit="W")
                                                     "electrical power"  annotation (Placement(transformation(extent={{96,10},{116,30}})));
  Modelica.Blocks.Interfaces.RealOutput CC(start=5, unit="W")
                                                             "cooling capacity" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,-106})));
  Modelica.Blocks.Interfaces.RealOutput HC(start=10, unit="W") "heating capacity" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,104})));
  Modelica.Blocks.Interfaces.RealOutput m_ref(unit="kg/s")
    "refrigerant mass flow rate"                                                        annotation (Placement(transformation(extent={{96,-30},{116,-10}})));
  protected Real t_vector[10] = {1,Teva_c,Tcond_c,Teva_c^2,Teva_c*Tcond_c, Tcond_c^2, Teva_c^3, Teva_c^2*Tcond_c, Teva_c*Tcond_c^2, Tcond_c^3} "polynomial equation";
  protected Real Tcond_c = Tcond - 273.15 "conversion to [°C] for polynomial calculations";
  protected Real Teva_c =Teva  - 273.15 "conversion to [°C] for polynomial calculations";
equation
    if Mode==1 then
    Wel = el_coef * t_vector;
    CC = -1*cc_coef*t_vector;
    HC = -1*CC + Wel;
    m_ref = (m_coef* t_vector)/3600 "report to kg/s";
    else
    Wel   = 0;
    HC = 0;
    CC = 0;
    m_ref = 0;
    end if;
    annotation (Placement(transformation(extent={{-126,-114},{-86,-74}})),
              Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CompressorConstantEquationFit;
