within HeatPumpModel.Components.Cooling;
model CMP_poly_vs_8_cooling "Cooling version of compressor component"

  //--------------Import data----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   ExternData.XLSXFile dataSource(fileName=fileName)
    annotation (Placement(transformation(extent={{-12,-12},{8,8}})));

  //------------------Fixed speed poly-------------------------------------------------------------------------------------------------------------------------------------------------------------

   Real cc_coef[10] = vector(dataSource.getRealArray2D("A2","Polynomials",10,1));
   Real el_coef[10] = vector(dataSource.getRealArray2D("B2","Polynomials",10,1));
   Real m_coef[10] = vector(dataSource.getRealArray2D("C2","Polynomials",10,1));

   //------------------Variable speed 20 coefficients----------------------------------------------------------------------------------------------------------------------------------------------

   Real cc_coef_20[20] = vector(dataSource.getRealArray2D("A2","Polynomials_20",20,1));
   Real el_coef_20[20] = vector(dataSource.getRealArray2D("B2","Polynomials_20",20,1));
   Real m_coef_20[20] = vector(dataSource.getRealArray2D("C2","Polynomials_20",20,1));

   //------------------Variable speed 30 coefficients----------------------------------------------------------------------------------------------------------------------------------------------

   Real cc_coef_30[30] = vector(dataSource.getRealArray2D("A2","Polynomials_30",30,1));
   Real el_coef_30[30] = vector(dataSource.getRealArray2D("B2","Polynomials_30",30,1));
   Real m_coef_30[30] = vector(dataSource.getRealArray2D("C2","Polynomials_30",30,1));

   //------------------Power definition------------------------------------------------------------------------------------------------------------------------------------------------------------

   Real HC( unit = "W") "Heating capacity in standard conditions";
   Real CC(  unit  = "W") "Cooling capacity in standard conditions";
   Real Wel(  unit  = "W") "Electrical power in standard conditions";
   Real m_ref( unit = "kg/s") "refrigerant mass flow rate";

   //------------------CMP frequency---------------------------------------------------------------------------------------------------------------------------------------------------------------

   Real CMP_f_rpm = CMP_f * 60 "round per minute compressor frequency, required for Copleand";
   Modelica.Blocks.Interfaces.RealInput CMP_f(unit="Hz")
                                                        "Compressor frequency / speed "
    annotation (Placement(transformation(extent={{-126,6},{-100,32}}),
                        iconTransformation(extent={{-126,6},{-100,32}})));

  //------------------Input and output blocks------------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.IntegerInput Mode "operating mode" annotation (Placement(transformation(extent={{-126,-32},{-100,-6}}),
                        iconTransformation(extent={{-126,-32},{-100,-6}})));
  Modelica.Blocks.Interfaces.RealInput Tcond(unit="K") "condensing temperaure"  annotation (Placement(transformation(extent={{14,-14},
            {-14,14}},
        rotation=-90,
        origin={0,-114}),   iconTransformation(extent={{14,-14},{-14,14}},
        rotation=-90,
        origin={0,-114})));
  Modelica.Blocks.Interfaces.RealInput Teva(unit="K") "evaporating temperature"  annotation (Placement(transformation(extent={{13,-13},
            {-13,13}},
        rotation=90,
        origin={-1,113}),     iconTransformation(extent={{13,-13},{-13,13}},
        rotation=90,
        origin={-1,113})));
  Modelica.Blocks.Interfaces.RealOutput CC_Wel[2](unit="W") = {CC,Wel} "cooling capacity" annotation (
      Placement(transformation(
        extent={{-13,-13},{13,13}},
        rotation=0,
        origin={113,19}),  iconTransformation(
        extent={{-14,-14},{14,14}},
        rotation=0,
        origin={114,20})));
  Modelica.Blocks.Interfaces.IntegerOutput Mode_Output = Mode annotation (Placement(
        transformation(extent={{100,-34},{126,-8}}),
                                                  iconTransformation(extent={{100,-34},{126,-8}})));

  //------------------String parameter-------------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String fileName="Select a compressor model"
                                                       "File path where polynomial coefficients are stored"
  annotation(choices(choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xlsx",
                       choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VZH028CH polynomials.xlsx"));
  parameter String CMP_type = "Fixed speed"
   annotation (choices(choice = "Fixed speed", choice = "Variable speed 20 coeff",choice = "Variable speed 30 coeff"));

  //------------------Temperatures-----------------------------------------------------------------------------------------------------------------------------------------------------------------

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

  // =================EQUATION BLOCK===============================================================================================================================================================

equation

  //------------------Polynomial output calculation------------------------------------------------------------------------------------------------------------------------------------------------

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
              Icon(coordinateSystem(preserveAspectRatio=false), graphics={Bitmap(extent={{-90,-94},{94,96}}, fileName="modelica://HeatPumpModel/../Incons/Compressor.png"), Text(
          extent={{-62,-76},{66,-114}},
          textColor={0,0,255},
          textString="Compressor
")}),                                                            Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StartTime=1728000,
      StopTime=1814400,
      Interval=59.9999616,
      Tolerance=1e-05,
      __Dymola_Algorithm="Radau"));
end CMP_poly_vs_8_cooling;
