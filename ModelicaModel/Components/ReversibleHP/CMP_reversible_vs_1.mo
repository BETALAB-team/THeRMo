within HeatPumpModel.Components.ReversibleHP;
model CMP_reversible_vs_1 "Reversible compressor model"

  //--------------Import data----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   ExternData.XLSXFile dataSource(
                                 fileName=fileName)
    annotation (Placement(transformation(extent={{-12,-12},{8,8}})));

  //------------------Fixed speed poly-------------------------------------------------------------------------------------------------------------------------------------------------------------

   Real cc_coef[10] = vector(dataSource.getRealArray2D("A2","Polynomials",10,1));
   Real el_coef[10] = vector(dataSource.getRealArray2D("B2","Polynomials",10,1));

   //------------------Variable speed 20 coefficients----------------------------------------------------------------------------------------------------------------------------------------------

   Real cc_coef_20[20] = vector(dataSource.getRealArray2D("A2","Polynomials_20",20,1));
   Real el_coef_20[20] = vector(dataSource.getRealArray2D("B2","Polynomials_20",20,1));

   //------------------Variable speed 30 coefficients----------------------------------------------------------------------------------------------------------------------------------------------

   Real cc_coef_30[30] = vector(dataSource.getRealArray2D("A2","Polynomials_30",30,1));
   Real el_coef_30[30] = vector(dataSource.getRealArray2D("B2","Polynomials_30",30,1));

   //------------------Power definition------------------------------------------------------------------------------------------------------------------------------------------------------------

   Real HC( unit = "W") "Heating capacity in standard conditions";

   Real CC(  unit  = "W") "Cooling capacity in standard conditions";
   Real Wel(  unit  = "W") "Electrical power in standard conditions";

   //------------------CMP frequency---------------------------------------------------------------------------------------------------------------------------------------------------------------

   Real CMP_f_rpm = CMP_f * 60 "round per minute compressor frequency, required for Copleand";
   Modelica.Blocks.Interfaces.RealInput CMP_f(unit="Hz")
    "Compressor frequency / speed " annotation (Placement(transformation(extent={{-140,-48},{-100,-8}}),
                        iconTransformation(extent={{-126,-34},{-100,-8}})));

   //------------------Input and output blocks------------------------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Blocks.Interfaces.RealInput Tref_1(unit="K") "condensing temperaure" annotation (Placement(transformation(
        extent={{-14,-14},{14,14}},
        rotation=-90,
        origin={0,114}), iconTransformation(
        extent={{-14,-14},{14,14}},
        rotation=-90,
        origin={0,114})));
  Modelica.Blocks.Interfaces.RealInput Tref_2(unit="K") "evaporating temperature" annotation (Placement(transformation(
        extent={{-13,-13},{13,13}},
        rotation=90,
        origin={1,-113}), iconTransformation(
        extent={{-13,-13},{13,13}},
        rotation=90,
        origin={1,-113})));
  Modelica.Blocks.Interfaces.RealOutput CC_Wel[2](unit="W") = {CC,Wel} "cooling capacity"  annotation (
      Placement(transformation(
        extent={{-11,-11},{11,11}},
        rotation=0,
        origin={115,-19}), iconTransformation(
        extent={{-13,-13},{13,13}},
        rotation=0,
        origin={113,-21})));
  Modelica.Blocks.Interfaces.IntegerInput HP_operative_status annotation (Placement(transformation(extent={{-126,6},{-100,32}}), iconTransformation(extent={{-126,6},{-100,32}})));
  Modelica.Blocks.Interfaces.IntegerOutput HP_operative_status_out annotation (Placement(transformation(extent={{100,6},{126,32}}), iconTransformation(extent={{100,6},{126,32}})));

  //------------------String parameter-------------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter String fileName="Select a compressor model" "File path where polynomial coefficients are stored" annotation(choices(choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Fixed_Speed_Danfoss/HRH054U4 polynomials.xlsx",
                       choice = "C:/Users/benafra10167/Desktop/CMP_polynomial/Variable_Speed_Danfoss/VZH028CH polynomials.xlsx"));
  parameter String CMP_type = "Fixed speed" annotation (choices(choice = "Fixed speed", choice = "Variable speed 20 coeff",choice = "Variable speed 30 coeff"));
  parameter Real minF( unit = "Hz") "minimum compressor frequency";

 //------------------Temperatures-----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Real Tcond_c( unit = "degC") "Condensing temperature in °C";
  Real Teva_c( unit = "degC") "Evaporating temperature in °C";

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


  // =================EQUATION BLOCK===============================================================================================================================================================


public


 //------------------Temperature calculation -----------------------------------------------------------------------------------------------------------------------------------------------------
equation
  if HP_operative_status == 1 then
     Tcond_c = Tref_1 - 273.15;
     Teva_c = Tref_2 - 273.15;
  else
    Tcond_c = Tref_2 - 273.15;
    Teva_c = Tref_1 - 273.15;
  end if;

 //------------------Polynomial output calculation-------------------------------------------------------------------------------------------------------------------------------------------------
 if CMP_f < minF then
     Wel = 0;
     CC = 0;
     HC = CC + Wel;
  else
    if CMP_type == "Fixed speed" then
      Wel = Buildings.Utilities.Math.Functions.smoothMax(el_coef * t_vector_fix,0,1e-5);
      CC = Buildings.Utilities.Math.Functions.smoothMax(cc_coef * t_vector_fix,0,1e-5);
      HC = CC + Wel;

    elseif CMP_type == "Variable speed 20 coeff" then
      Wel = Buildings.Utilities.Math.Functions.smoothMax(el_coef_20 * t_vector_20,0,1e-5);
      CC =  Buildings.Utilities.Math.Functions.smoothMax(cc_coef_20 * t_vector_20,0,1e-5);
      HC = CC + Wel;

    elseif CMP_type == "Variable speed 30 coeff" then
      Wel = Buildings.Utilities.Math.Functions.smoothMax( el_coef_30 * t_vector_30,0,1e-5);
      CC = Buildings.Utilities.Math.Functions.smoothMax(cc_coef_30 * t_vector_30,0,1e-5);
      HC = CC + Wel;

  end if;
 end if;
  connect(HP_operative_status, HP_operative_status_out) annotation (Line(points={{-113,19},{-8,19},{-8,19},{113,19}}, color={255,127,0}));
    annotation (Placement(transformation(extent={{-126,-114},{-86,-74}})),
              Icon(coordinateSystem(preserveAspectRatio=false), graphics={Bitmap(extent={{-90,-96},{94,94}}, fileName="modelica://HeatPumpModel/../Incons/Copia di CMP Heating.png"),
                                                                                                                                                                            Text(
          extent={{-62,-74},{66,-112}},
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
end CMP_reversible_vs_1;
