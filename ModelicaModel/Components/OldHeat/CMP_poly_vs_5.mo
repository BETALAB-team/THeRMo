within HeatPumpModel.Components.OldHeat;
model CMP_poly_vs_5
  "Introduction of condensing and evaporating temperature as output"

  //Import data
   ExternData.XLSFile dataSource(fileName=fileName)
    annotation (Placement(transformation(extent={{-12,-12},{8,8}})));

   Modelica.Blocks.Interfaces.RealInput CMP_f(unit="Hz")
    "Compressor frequency / speed " annotation (Placement(transformation(extent={{-142,4},
            {-102,44}}),iconTransformation(extent={{-94,28},{-68,54}})));

   //Fixed speed
   Real cc_coef[10] = vector(dataSource.getRealArray2D("A2","Polynomials",10,1));
   Real el_coef[10] = vector(dataSource.getRealArray2D("B2","Polynomials",10,1));
   Real m_coef[10] = vector(dataSource.getRealArray2D("C2","Polynomials",10,1));

   //Variable speed 30 coefficients
   Real cc_coef_30[30] = vector(dataSource.getRealArray2D("A2","Polynomials_30",30,1));
   Real el_coef_30[30] = vector(dataSource.getRealArray2D("B2","Polynomials_30",30,1));
   Real m_coef_30[30] = vector(dataSource.getRealArray2D("C2","Polynomials_30",30,1));

  //Parameter definition
  Modelica.Blocks.Interfaces.IntegerInput Mode "operating mode" annotation (Placement(transformation(extent={{-90,-52},
            {-68,-30}}),iconTransformation(extent={{-90,-52},{-68,-30}})));
  Modelica.Blocks.Interfaces.RealInput Tcond(unit="K") "condensing temperaure"  annotation (Placement(transformation(extent={{-20,-20},
            {20,20}},
        rotation=-90,
        origin={0,112}),    iconTransformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={0,112})));
  Modelica.Blocks.Interfaces.RealInput Teva(unit="K") "evaporating temperature"  annotation (Placement(transformation(extent={{-20,-20},
            {20,20}},
        rotation=90,
        origin={0,-100}),     iconTransformation(extent={{-20,-20},{20,20}},
        rotation=90,
        origin={0,-100})));
  Modelica.Blocks.Interfaces.RealOutput Wel(unit="W") "electrical power"  annotation (Placement(transformation(extent={{66,18},
            {90,42}}), iconTransformation(extent={{66,18},{90,42}})));
  Modelica.Blocks.Interfaces.RealOutput CC(start=5, unit="W") "cooling capacity" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={92,-88}),  iconTransformation(
        extent={{-14,-14},{14,14}},
        rotation=0,
        origin={80,-58})));
  Modelica.Blocks.Interfaces.RealOutput HC(start=10, unit="W") "heating capacity" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={80,110}), iconTransformation(
        extent={{-13,-13},{13,13}},
        rotation=0,
        origin={79,59})));
  Modelica.Blocks.Interfaces.RealOutput m_ref(unit="kg/s") "refrigerant mass flow rate"
                                                                                       annotation (Placement(transformation(extent={{66,-40},
            {92,-14}}), iconTransformation(extent={{66,-40},{92,-14}})));
  Modelica.Blocks.Interfaces.IntegerOutput Mode_Output = Mode annotation (Placement(
        transformation(extent={{66,-12},{92,14}}),iconTransformation(extent={{66,-12},
            {92,14}})));
  //String parameter
  parameter String fileName="Select a compressor model"
  "File path where polynomial coefficients are stored"
  annotation(choices(choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xls",
                       choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VZH028CH polynomials.xls"));

  parameter String CMP_type = "Fixed speed"
   annotation (choices(choice = "Fixed speed", choice = "Variable speed 20 coeff",choice = "Variable speed 30 coeff"));

  //Temperatures
  protected Real t_vector_fix[10] = {1,Teva_c,Tcond_c,Teva_c^2,Teva_c*Tcond_c, Tcond_c^2, Teva_c^3, Teva_c^2*Tcond_c, Teva_c*Tcond_c^2, Tcond_c^3} "polynomial equation";
  protected Real t_vector_30[30]= { 1,
                                    Teva_c,
                                    Tcond_c,
                                    Teva_c^2,
                                    Tcond_c^2,
                                    Teva_c*Tcond_c*CMP_f^2,
                                    Teva_c^2*Tcond_c*CMP_f^2,
                                    Teva_c*Tcond_c^2*CMP_f^2,
                                    Teva_c*Tcond_c*CMP_f,
                                    Teva_c^2*Tcond_c*CMP_f,
                                    Teva_c*Tcond_c^2*CMP_f,
                                    Teva_c*Tcond_c,
                                    Teva_c^2*Tcond_c,
                                    Teva_c*Tcond_c^2,
                                    Teva_c^3,
                                    Tcond_c^3,
                                    CMP_f,
                                    Teva_c*CMP_f,
                                    Tcond_c*CMP_f,
                                    Teva_c^2*CMP_f,
                                    Tcond_c^2*CMP_f,
                                    Teva_c^3*CMP_f,
                                    Tcond_c^3*CMP_f,
                                    CMP_f^2,
                                    Teva_c*CMP_f^2,
                                    Tcond_c*CMP_f^2,
                                    Teva_c^2*CMP_f^2,
                                    Tcond_c^2*CMP_f^2,
                                    Teva_c^3*CMP_f^2,
                                    Tcond_c^3*CMP_f^2}
                                     "30 coefficients polynomial equation";

  protected Real Tcond_c = Tcond - 273.15 "conversion to [°C] for polynomial calculations";
  protected Real Teva_c =Teva  - 273.15 "conversion to [°C] for polynomial calculations";

equation
  if CMP_type == "Fixed speed" then
    Wel = smooth(1,noEvent(if Mode==1 then el_coef * t_vector_fix else 0));
    CC = smooth(1,noEvent(if Mode==1 then cc_coef*t_vector_fix else 0));
    HC = CC + Wel;
    m_ref = smooth(1,noEvent(if Mode==1 then (m_coef* t_vector_fix)/3600 else 0)) "report to kg/s";
  elseif CMP_type == "Variable speed 30 coeff" then
    Wel = smooth(1,noEvent(if Mode==1 then el_coef_30 * t_vector_30 else 0));
    CC = smooth(1,noEvent(if Mode==1 then cc_coef_30*t_vector_30 else 0));
    HC = CC + Wel;
    m_ref = smooth(1,noEvent(if Mode==1 then (m_coef_30* t_vector_30)/3600 else 0)) "report to kg/s";
  end if;
    annotation (Placement(transformation(extent={{-126,-114},{-86,-74}})),
              Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-68,92},{62,-80}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Bitmap(extent={{-74,-64},{58,88}}, fileName=
              "modelica://HeatPumpModel/../Incons/Immagine 2025-11-14 115923.png"),
        Text(
          extent={{-50,-50},{44,-84}},
          textColor={0,0,0},
          textString="%name
")}),                                                            Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CMP_poly_vs_5;
