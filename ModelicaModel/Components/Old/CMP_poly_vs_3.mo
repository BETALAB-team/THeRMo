within HeatPumpModel.Components;
model CMP_poly_vs_3
  "Introduction of the variable speed polynomials"

  //Import data
   ExternData.XLSFile dataSource(fileName=fileName)
    annotation (Placement(transformation(extent={{-12,-12},{8,8}})));

   Modelica.Blocks.Interfaces.RealInput CMP_f(unit="Hz")
    "Compressor frequency / speed " annotation (Placement(transformation(extent={{-142,4},
            {-102,44}}),iconTransformation(extent={{-140,26},{-100,66}})));

   //Fixed speed
   Real cc_coef[10] = vector(dataSource.getRealArray2D("A2","Polynomials",10,1));
   Real el_coef[10] = vector(dataSource.getRealArray2D("B2","Polynomials",10,1));
   Real m_coef[10] = vector(dataSource.getRealArray2D("C2","Polynomials",10,1));

   //Variable speed 30 coefficients
   Real cc_coef_30[30] = vector(dataSource.getRealArray2D("A2","Polynomials_30",30,1));
   Real el_coef_30[30] = vector(dataSource.getRealArray2D("B2","Polynomials_30",30,1));
   Real m_coef_30[30] = vector(dataSource.getRealArray2D("C2","Polynomials_30",30,1));

  //Parameter definition
  Modelica.Blocks.Interfaces.IntegerInput Mode "operating mode" annotation (Placement(transformation(extent={{-142,
            -30},{-102,10}}),
                        iconTransformation(extent={{-142,-30},{-102,10}})));
  Modelica.Blocks.Interfaces.RealInput Tcond(unit="K") "condensing temperaure"  annotation (Placement(transformation(extent={{-140,64},
            {-100,104}}),   iconTransformation(extent={{-140,64},{-100,104}})));
  Modelica.Blocks.Interfaces.RealInput Teva(unit="K") "evaporating temperature"  annotation (Placement(transformation(extent={{-140,
            -86},{-100,-46}}),iconTransformation(extent={{-140,-86},{-100,-46}})));
  Modelica.Blocks.Interfaces.RealOutput Wel(unit="W") "electrical power"  annotation (Placement(transformation(extent={{64,64},
            {84,84}}), iconTransformation(extent={{64,64},{84,84}})));
  Modelica.Blocks.Interfaces.RealOutput CC(start=5, unit="W") "cooling capacity" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={40,-108}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={44,-92})));
  Modelica.Blocks.Interfaces.RealOutput HC(start=10, unit="W") "heating capacity" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={40,104}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={42,104})));
  Modelica.Blocks.Interfaces.RealOutput m_ref(unit="kg/s") "refrigerant mass flow rate"
                                                                                       annotation (Placement(transformation(extent={{64,-48},
            {84,-28}}), iconTransformation(extent={{64,-48},{84,-28}})));
  Modelica.Blocks.Interfaces.IntegerOutput Mode_Output = Mode annotation (Placement(
        transformation(extent={{60,-20},{88,8}}), iconTransformation(extent={{60,
            -20},{88,8}})));
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
    if Mode==1 then
      Wel = el_coef * t_vector_fix;
      CC = -1*cc_coef*t_vector_fix;
      HC = -1*CC + Wel;
      m_ref = (m_coef* t_vector_fix)/3600 "report to kg/s";
    else
      Wel   = 0;
      HC = 0;
      CC = 0;
      m_ref = 0;
    end if;
  elseif CMP_type == "Variable speed 30 coeff" then
    if Mode==1 then
      Wel = el_coef_30 * t_vector_30;
      CC = -1*cc_coef_30*t_vector_30;
      HC = -1*CC + Wel;
      m_ref =(m_coef_30* t_vector_30)/3600 "report to kg/s";
    else
      Wel   = 0;
      HC = 0;
      CC = 0;
      m_ref = 0;
    end if;
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
          extent={{-50,-58},{44,-92}},
          textColor={0,0,0},
          textString="%name
")}),                                                            Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CMP_poly_vs_3;
