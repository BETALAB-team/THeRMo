within HeatPumpModel.Components.ReversibleHP;
model Control_vs_5 "Control System for reversible components"

  //--------------------------------------------------Blocks--------------------------------------------------------------------------------------------------------------------------------------
  Modelica.Blocks.Interfaces.RealInput Tmeas annotation (Placement(transformation(extent={{-116,-8},{-100,8}}), iconTransformation(extent={{-116,-8},{-100,8}})));
  Buildings.Controls.Continuous.LimPID conPID_Heat(
    u_s=Tset,
    controllerType=Modelica.Blocks.Types.SimpleController.PID,
    k=k_heat,
    Ti=Ti_heat,
    Td=Td_heating,
    reverseActing=reverseActing,
    y_reset=0)
      annotation (Placement(transformation(extent={{-24,14},{-4,34}})));
  Modelica.Blocks.Interfaces.RealOutput CMP_f "Total compressor frequency"
                                              annotation (Placement(transformation(extent={{100,-32},{120,-12}}), iconTransformation(extent={{100,-32},{120,-12}})));
  Modelica.Blocks.Interfaces.IntegerOutput HP_operative_status annotation (Placement(transformation(extent={{100,10},{120,30}})));
  Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=fmin_Low, uHigh=fmin_High)
                                                                   annotation (Placement(transformation(extent={{40,48},{60,68}})));

  Modelica.Blocks.Math.BooleanToInteger booleanToInteger(integerTrue=1) annotation (Placement(transformation(extent={{76,50},{92,66}})));
  Modelica.Blocks.Math.Gain gain(k=f_nominal) annotation (Placement(transformation(extent={{14,26},{24,36}})));
  Modelica.Blocks.Logical.Switch switch annotation (Placement(transformation(extent={{64,-30},{78,-16}})));
  Modelica.Blocks.Math.IntegerToBoolean integerToBoolean annotation (Placement(transformation(extent={{30,-36},{42,-24}})));
  Modelica.Blocks.Sources.IntegerExpression integerExpression(y=abs(HP_operative_mode))
                                                                                   annotation (Placement(transformation(extent={{2,-40},{22,-20}})));
  Modelica.Blocks.Sources.Constant const(k=0) annotation (Placement(transformation(extent={{20,-60},{40,-40}})));
  Modelica.Blocks.Interfaces.BooleanOutput DefOutput  annotation (Placement(transformation(extent={{100,-70},{120,-50}})));

  //-------------------------------------------Parameters------------------------------------------------------------------------------------------------------------------------------------------
  Integer HP_operative_mode "HP opeation mode";
  parameter Boolean reverseActing=true "Set to true for reverse acting, or false for direct acting control action" annotation (Dialog(group="Setup"));
  Integer HP_target "HP target status";
  Real Ttrigger(unit = "s") "time trigger";
  Integer last_active_mode( start = 1) "memory of last operative status";
  parameter Real Tset(unit="K") "set point temperature" annotation (Dialog(group="SetUp"));
  parameter Modelica.Blocks.Types.SimpleController controllerType_heat=Modelica.Blocks.Types.SimpleController.PI "Type of controller" annotation (Dialog(group="Heating"));
  parameter Real k_heat=1 "Gain of controller" annotation (Dialog(group="Heating"));
  parameter Modelica.Units.SI.Time Ti_heat=0.5 "Time constant of Integrator block" annotation (Dialog(group="Heating"));
  parameter Modelica.Units.SI.Time Td_heating=0.1 "Time constant of Derivative block" annotation (Dialog(group="Heating"));
  parameter Real f_nominal(unit="Hz") "nominal compressor frequency" annotation (Dialog(group="Setup"));
  parameter Real Tdelay( unit = "s") "delay when HP turns ON"
                                                             annotation (Dialog(group="Setup"));
  parameter String Operation_Mode  =  "Select an operation mode" annotation (choices(choice = "Heating Mode",choice = "Cooling Mode"), Dialog = "Setup");
  parameter Real fmin_Low( unit = "Hz") "lowest husteresis values" annotation (Dialog(group="Setup"));
  parameter Real fmin_High( unit = "Hz") "highest husteresis values" annotation (Dialog(group="Setup"));
  parameter Real p_def(  unit = "bar") "pressure at which defrost should start" annotation (Dialog(group="Setup"));
  //Real t_equal(unit="s") = 120 "time equalization";
  Modelica.Blocks.Interfaces.RealInput p_eva annotation (Placement(transformation(extent={{-116,-48},{-100,-32}}), iconTransformation(extent={{-116,-68},{-100,-52}})));
  Boolean defrost "true while defrost is active";
  parameter Real t_def(unit="s") = 1200 "duration of the defrost phase" annotation (Dialog(group="Defrost"));
  parameter Real t_lock(unit="s") = 600 "defrost forbidden for this time after start-up and after each defrost" annotation (Dialog(group="Defrost"));
  Real t_start(unit="s", start= -1e9) "time of last defrost start";
  Boolean c_mode = (HP_operative_mode == 1) "compressor on in heating";
  Boolean c_p    = ((p_eva * 1e-5)< p_def)          "pressure below threshold";
  //Boolean c_p = (4 + 2*sin(2*Modelica.Constants.pi*time/3000)) < 3 "TEST: artificial pressure condition";
  Boolean c_lock = (time >= t_lock) and (time >= pre(t_start) + t_def + t_lock) "lock after start-up and after each defrost";
  Boolean startCond = c_mode and c_p and c_lock "all three start conditions together";
 // =================EQUATION BLOCK===============================================================================================================================================================

equation

  if defrost then
    HP_operative_status = -1;
  else
    HP_operative_status = last_active_mode;
  end if;

  if Operation_Mode == "Heating Mode" then
    HP_target = booleanToInteger.y;
  else
    HP_target = - booleanToInteger.y;
  end if;

  //Start counting time for delay
  when change(HP_target) then
    Ttrigger = time;
  end when;

  //Apply the target to the status
  if time >= Tdelay + Ttrigger then
    HP_operative_mode = HP_target;
  else
    HP_operative_mode = pre(HP_operative_mode);
  end if;


  //Evaluation of the last operative status
  when  HP_operative_mode == 1 then
    last_active_mode = 1;
  elsewhen HP_operative_mode == -1 then
    last_active_mode = -1;
  end when;

  //Change compressor frequency when defrosting
  if defrost then
    //CMP_f = f_nominal;
    CMP_f = 0;
  else
    CMP_f = switch.y;
  end if;

  defrost = time < t_start + t_def;
  DefOutput = defrost;

  when sample(0, 10) then
    t_start = if startCond then time else pre(t_start);
  end when;

  connect(Tmeas, conPID_Heat.u_m) annotation (Line(points={{-108,0},{-14,0},{-14,12}}, color={0,0,127}));
  connect(hysteresis.y, booleanToInteger.u) annotation (Line(points={{61,58},{74.4,58}}, color={255,0,255}));
  connect(conPID_Heat.y, gain.u) annotation (Line(points={{-3,24},{6,24},{6,31},{13,31}},          color={0,0,127}));
  connect(gain.y, hysteresis.u) annotation (Line(points={{24.5,31},{28,31},{28,58},{38,58}},                 color={0,0,127}));
  connect(switch.u1, hysteresis.u) annotation (Line(points={{62.6,-17.4},{28,-17.4},{28,58},{38,58}}, color={0,0,127}));
  connect(integerToBoolean.y, switch.u2) annotation (Line(points={{42.6,-30},{52,-30},{52,-23},{62.6,-23}}, color={255,0,255}));
  connect(integerExpression.y, integerToBoolean.u) annotation (Line(points={{23,-30},{28.8,-30}}, color={255,127,0}));
  connect(const.y, switch.u3) annotation (Line(points={{41,-50},{56,-50},{56,-28.6},{62.6,-28.6}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={Bitmap(extent={{-80,-84},{80,82}}, fileName="modelica://HeatPumpModel/../Incons/Control.png"), Rectangle(
          extent={{-82,80},{80,-82}},
          lineColor={0,0,0},
          lineThickness=1)}),                                                                                                                                              Diagram(coordinateSystem(
          preserveAspectRatio=false)),
    experiment(
      StopTime=15000,
      Interval=60,
      __Dymola_Algorithm="Radau"));
end Control_vs_5;
