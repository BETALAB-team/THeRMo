within HeatPumpModel.Components.Heating;
model CMP_poly_vs_8 "Added softStart directly on starter filter"

  //Import data
   ExternData.XLSXFile dataSource(
                                 fileName=fileName)
    annotation (Placement(transformation(extent={{-12,-12},{8,8}})));

   Modelica.Blocks.Interfaces.RealInput CMP_f(unit="Hz")
    "Compressor frequency / speed " annotation (Placement(transformation(extent={{-142,4},
            {-102,44}}),iconTransformation(extent={{-94,28},{-68,54}})));

   //First order filter
   //Fixed speed
   Real cc_coef[10] = vector(dataSource.getRealArray2D("A2","Polynomials",10,1));
   Real el_coef[10] = vector(dataSource.getRealArray2D("B2","Polynomials",10,1));
   Real m_coef[10] = vector(dataSource.getRealArray2D("C2","Polynomials",10,1));

   //Variable speed 20 coefficients
   Real cc_coef_20[20] = vector(dataSource.getRealArray2D("A2","Polynomials_20",20,1));
   Real el_coef_20[20] = vector(dataSource.getRealArray2D("B2","Polynomials_20",20,1));
   Real m_coef_20[20] = vector(dataSource.getRealArray2D("C2","Polynomials_20",20,1));

   //Variable speed 30 coefficients
   Real cc_coef_30[30] = vector(dataSource.getRealArray2D("A2","Polynomials_30",30,1));
   Real el_coef_30[30] = vector(dataSource.getRealArray2D("B2","Polynomials_30",30,1));
   Real m_coef_30[30] = vector(dataSource.getRealArray2D("C2","Polynomials_30",30,1));

   //Power
   Real HC( unit = "W") "Heating capacity in standard conditions";
   Real m_ref( unit " kg/s") "refrigerant mass flow rate";

   //CMP_f in rmp (required in Copeland Compressors)
   Real CMP_f_rpm = CMP_f * 60 "round per minute compressor frequency, required for Copleand";

  //Parameter definition
  Modelica.Blocks.Interfaces.IntegerInput Mode "operating mode" annotation (Placement(transformation(extent={{-94,-54},
            {-68,-28}}),iconTransformation(extent={{-94,-54},{-68,-28}})));
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
  Modelica.Blocks.Interfaces.RealOutput Wel(unit="W") "electrical power"  annotation (Placement(transformation(extent={{62,14},
            {90,42}}), iconTransformation(extent={{62,14},{90,42}})));
  Modelica.Blocks.Interfaces.RealOutput CC(unit="W") "cooling capacity" annotation (
      Placement(transformation(
        extent={{-13,-13},{13,13}},
        rotation=0,
        origin={113,-27}), iconTransformation(
        extent={{-14,-14},{14,14}},
        rotation=0,
        origin={76,-30})));
  Modelica.Blocks.Interfaces.IntegerOutput Mode_Output = Mode annotation (Placement(
        transformation(extent={{62,-14},{88,12}}),iconTransformation(extent={{62,-14},
            {88,12}})));

  //String parameter
  parameter String fileName="Select a compressor model"
  "File path where polynomial coefficients are stored"
  annotation(choices(choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xlsx",
                       choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VZH028CH polynomials.xlsx"));

  parameter String CMP_type = "Fixed speed"
   annotation (choices(choice = "Fixed speed", choice = "Variable speed 20 coeff",choice = "Variable speed 30 coeff"));

  //Temperatures
  protected Real t_vector_fix[10] = {1,Teva_c,Tcond_c,Teva_c^2,Teva_c*Tcond_c, Tcond_c^2, Teva_c^3, Teva_c^2*Tcond_c, Teva_c*Tcond_c^2, Tcond_c^3} "polynomial equation";
  protected Real t_vector_20[20] = {1,
                                    Teva_c,
                                    Tcond_c,
                                    CMP_f_rpm,
                                    Teva_c * Tcond_c,
                                    Teva_c * CMP_f_rpm,
                                    Tcond_c * CMP_f_rpm,
                                    Teva_c^2,
                                    Tcond_c^2,
                                    CMP_f_rpm^2,
                                    Teva_c * Tcond_c * CMP_f_rpm,
                                    Teva_c^2 * Tcond_c,
                                    Teva_c^2 * CMP_f_rpm,
                                    Teva_c^3,
                                    Teva_c * Tcond_c^2,
                                    Tcond_c^2 * CMP_f_rpm,
                                    Tcond_c^3,
                                    Teva_c * CMP_f_rpm^2,
                                    Tcond_c * CMP_f_rpm^2,
                                    CMP_f_rpm^3}
                                    "20 coefficients polynomials";
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
    Wel = Buildings.Utilities.Math.Functions.smoothMax(el_coef * t_vector_fix,0,1e-5);
    CC = Buildings.Utilities.Math.Functions.smoothMax(cc_coef * t_vector_fix,0,1e-5);
    HC = CC + Wel;
    m_ref = Buildings.Utilities.Math.Functions.smoothMax((m_coef* t_vector_fix)/3600,0,1e-5) "report to kg/s";
  elseif CMP_type == "Variable speed 20 coeff" then
    Wel = Buildings.Utilities.Math.Functions.smoothMax(el_coef_20 * t_vector_20,0,1e-5);
    CC =  Buildings.Utilities.Math.Functions.smoothMax(cc_coef_20 * t_vector_20,0,1e-5);
    HC = CC + Wel;
    m_ref =  Buildings.Utilities.Math.Functions.smoothMax((m_coef_20* t_vector_20)/3600,0,1e-5) "report to kg/s";
  elseif CMP_type == "Variable speed 30 coeff" then
    Wel = Buildings.Utilities.Math.Functions.smoothMax( el_coef_30 * t_vector_30,0,1e-5);
    CC = Buildings.Utilities.Math.Functions.smoothMax(cc_coef_30 * t_vector_30,0,1e-5);
    HC = CC + Wel;
    m_ref = Buildings.Utilities.Math.Functions.smoothMax((m_coef_30* t_vector_30)/3600,0,1e-5) "report to kg/s";
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
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StartTime=1728000,
      StopTime=1814400,
      Interval=59.9999616,
      Tolerance=1e-05,
      __Dymola_Algorithm="Radau"));
end CMP_poly_vs_8;
