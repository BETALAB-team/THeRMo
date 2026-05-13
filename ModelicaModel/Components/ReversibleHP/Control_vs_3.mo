within HeatPumpModel.Components.ReversibleHP;
model Control_vs_3 "Control System for reversible components"

  //--------------------------------------------------Blocks--------------------------------------------------------------------------------------------------------------------------------------
  Modelica.Blocks.Interfaces.RealInput Tmeas annotation (Placement(transformation(extent={{-116,-8},{-100,8}}), iconTransformation(extent={{-116,-8},{-100,8}})));
  Buildings.Controls.Continuous.LimPID conPID_Heat(
    u_s=Tset,
    controllerType=Modelica.Blocks.Types.SimpleController.PID,
    k=k_heat,
    Ti=Ti_heat,
    Td=Td_heating,
    reset=Buildings.Types.Reset.Parameter,
    y_reset=0) annotation (Placement(transformation(extent={{-20,20},{0,40}})));
  Buildings.Controls.Continuous.LimPID conPID_Cool(
    u_s=Tset,
    controllerType=Modelica.Blocks.Types.SimpleController.PID,
    k=k_cool,
    Ti=Ti_cool,
    Td=Td_cool,
    reverseActing=false,
    reset=Buildings.Types.Reset.Parameter,
    y_reset=0) annotation (Placement(transformation(extent={{-20,-18},{0,-38}})));
  Modelica.Blocks.Interfaces.RealOutput CMP_f "Total compressor frequency"
                                              annotation (Placement(transformation(extent={{100,-32},{120,-12}}), iconTransformation(extent={{100,-32},{120,-12}})));
  Modelica.Blocks.Interfaces.IntegerOutput HP_operative_status annotation (Placement(transformation(extent={{100,10},{120,30}})));

  //-------------------------------------------Parameters------------------------------------------------------------------------------------------------------------------------------------------
  Integer HP_operative_mode "HP opeation mode";
  Integer HP_target "HP target status";
  Real DeltaT_real(unit="K") "Real temperature difference";
  Real Ttrigger(unit = "s") "time trigger";
  Integer last_active_mode( start = 1) "memory of last operative status";
  parameter Real Tset(unit="K") "set point temperature" annotation (Dialog(group="SetUp"));
  parameter Real DeltaTup(unit="K") "upper temperature dead band" annotation (Dialog(group="SetUp"));
  parameter Real DeltaTlow(unit="K") "lower temperature dead band" annotation (Dialog(group="SetUp"));

  parameter Modelica.Blocks.Types.SimpleController controllerType_heat=Modelica.Blocks.Types.SimpleController.PI "Type of controller" annotation (Dialog(group="Heating"));
  parameter Real k_heat=1 "Gain of controller" annotation (Dialog(group="Heating"));
  parameter Modelica.Units.SI.Time Ti_heat=0.5 "Time constant of Integrator block" annotation (Dialog(group="Heating"));
  parameter Modelica.Units.SI.Time Td_heating=0.1 "Time constant of Derivative block" annotation (Dialog(group="Heating"));
  parameter Modelica.Blocks.Types.SimpleController controllerType_cool=Modelica.Blocks.Types.SimpleController.PI "Type of controller" annotation (Dialog(group="Cooling"));
  parameter Real k_cool=1 "Gain of controller" annotation (Dialog(group="Cooling"));
  parameter Modelica.Units.SI.Time Ti_cool=0.5 "Time constant of Integrator block" annotation (Dialog(group="Cooling"));
  parameter Modelica.Units.SI.Time Td_cool=0.1 "Time constant of Derivative block" annotation (Dialog(group="Cooling"));
  parameter Real f_nominal(unit="Hz") "nominal compressor frequency" annotation (Dialog(group="Setup"));
  parameter Real Tdelay( unit = "s") "delay when HP turns ON"
                                                             annotation (Dialog(group="Setup"));

 // =================EQUATION BLOCK===============================================================================================================================================================

equation

  DeltaT_real = Tset - Tmeas;
  HP_operative_status = last_active_mode;
  // Define HP status target
  if DeltaT_real > DeltaTup then
    HP_target= 1;
  elseif DeltaT_real < DeltaTlow then
     HP_target = -1;
  elseif pre(HP_target) == 1 and DeltaT_real > 0 then
     HP_target = 1;
  elseif pre(HP_target) == -1 and DeltaT_real < 0 then
     HP_target = -1;
  else
      HP_target =0;
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

  //Change the status and the real HP functioning mode
  if HP_operative_mode == 1 then
    CMP_f = Buildings.Utilities.Math.Functions.smoothMax(conPID_Heat.y*f_nominal,0,1e-4);
   elseif HP_operative_mode == -1 then
    CMP_f = Buildings.Utilities.Math.Functions.smoothMax(conPID_Cool.y*f_nominal,0,1e-4);
   else
    CMP_f = 0;
  end if;

  // Reset of the PID error
  if HP_operative_mode == 1 then
    conPID_Heat.trigger = true;
    conPID_Cool.trigger = false;
  elseif  HP_operative_mode == -1 then
    conPID_Heat.trigger = false;
    conPID_Cool.trigger = true;
  else
    conPID_Heat.trigger = false;
    conPID_Cool.trigger = false;
  end if;

  connect(Tmeas, conPID_Heat.u_m) annotation (Line(points={{-108,0},{-10,0},{-10,18}}, color={0,0,127}));
  connect(conPID_Cool.u_m, Tmeas) annotation (Line(points={{-10,-16},{-10,0},{-108,0}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={Bitmap(extent={{-80,-84},{80,82}}, fileName="modelica://HeatPumpModel/../Incons/Control.png"), Rectangle(
          extent={{-82,80},{80,-82}},
          lineColor={0,0,0},
          lineThickness=1)}),                                                                                                                                              Diagram(coordinateSystem(
          preserveAspectRatio=false)),
    experiment(
      StopTime=10800,
      Interval=60,
      __Dymola_Algorithm="Radau"));
end Control_vs_3;
