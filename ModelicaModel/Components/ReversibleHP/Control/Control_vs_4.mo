within HeatPumpModel.Components.ReversibleHP.Control;
model Control_vs_4 "Control System for reversible components"

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
  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(extent={{74,-28},{88,-14}})));
  Modelica.Blocks.Math.IntegerToBoolean integerToBoolean annotation (Placement(transformation(extent={{38,-36},{50,-24}})));
  Modelica.Blocks.Sources.IntegerExpression integerExpression(y=abs(HP_operative_mode))
                                                                                   annotation (Placement(transformation(extent={{12,-40},{32,-20}})));
  Modelica.Blocks.Sources.Constant const(k=0) annotation (Placement(transformation(extent={{26,-86},{46,-66}})));

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
  Modelica.Blocks.Interfaces.RealInput p_eva annotation (Placement(transformation(extent={{-116,-48},{-100,-32}}), iconTransformation(extent={{-116,-68},{-100,-52}})));

 // =================EQUATION BLOCK===============================================================================================================================================================

equation
  HP_operative_status = last_active_mode;

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

  connect(Tmeas, conPID_Heat.u_m) annotation (Line(points={{-108,0},{-14,0},{-14,12}}, color={0,0,127}));
  connect(hysteresis.y, booleanToInteger.u) annotation (Line(points={{61,58},{74.4,58}}, color={255,0,255}));
  connect(conPID_Heat.y, gain.u) annotation (Line(points={{-3,24},{6,24},{6,31},{13,31}},          color={0,0,127}));
  connect(gain.y, hysteresis.u) annotation (Line(points={{24.5,31},{28,31},{28,58},{38,58}},                 color={0,0,127}));
  connect(switch1.y, CMP_f) annotation (Line(points={{88.7,-21},{102,-21},{102,-22},{110,-22}}, color={0,0,127}));
  connect(switch1.u1, hysteresis.u) annotation (Line(points={{72.6,-15.4},{28,-15.4},{28,58},{38,58}}, color={0,0,127}));
  connect(integerToBoolean.y, switch1.u2) annotation (Line(points={{50.6,-30},{60,-30},{60,-21},{72.6,-21}}, color={255,0,255}));
  connect(integerExpression.y, integerToBoolean.u) annotation (Line(points={{33,-30},{36.8,-30}}, color={255,127,0}));
  connect(const.y, switch1.u3) annotation (Line(points={{47,-76},{66,-76},{66,-26.6},{72.6,-26.6}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={Bitmap(extent={{-80,-84},{80,82}}, fileName="modelica://HeatPumpModel/../Incons/Control.png"), Rectangle(
          extent={{-82,80},{80,-82}},
          lineColor={0,0,0},
          lineThickness=1)}),                                                                                                                                              Diagram(coordinateSystem(
          preserveAspectRatio=false)),
    experiment(
      StopTime=15000,
      Interval=60,
      __Dymola_Algorithm="Radau"));
end Control_vs_4;
