within HeatPumpModel.Components.ReversibleHP;
model Control_vs_1 "Control System of Valves and compressor"

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
  Modelica.Blocks.Interfaces.RealOutput CMP_f_H annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,110}),                                                                                          iconTransformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,110})));
  Modelica.Blocks.Interfaces.RealOutput CMP_f_C annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,-110}),                                                                                           iconTransformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,-110})));
  Modelica.Blocks.Interfaces.RealOutput CMP_f "Total compressor frequency"
                                              annotation (Placement(transformation(extent={{100,-10},{120,10}}),  iconTransformation(extent={{100,-10},{120,10}})));
  Modelica.Blocks.Interfaces.RealOutput Load_Control_H annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,110}),                                                                                               iconTransformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,110})));
  Modelica.Blocks.Interfaces.RealOutput Source_Control_C annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-50,-110}),                                                                                                  iconTransformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-50,-110})));
  Modelica.Blocks.Interfaces.RealOutput Source_Control_H annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={50,110}),                                                                                                  iconTransformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={50,110})));
  Modelica.Blocks.Interfaces.RealOutput Load_Control_C annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={52,-110}),                                                                                                 iconTransformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={52,-110})));

  //-------------------------------------------Parameters------------------------------------------------------------------------------------------------------------------------------------------
  Integer HP_operative_mode "HP opeation mode";
  Real DeltaT_real(unit="K") "Real temperature difference";
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
//   Integer last_active_mode( start = 1) "memory of last operative status";
//   Boolean lock(start = false) "lock for stopping frequency";
equation

//   when HP_operative_mode == 1 then
//     last_active_mode = 1;
//   elsewhen HP_operative_mode == -1 then
//     last_active_mode = -1;
//   end when;
//
//   when HP_operative_mode == 1 or HP_operative_mode == -1  then
//     lock = false;
//   elsewhen HP_operative_mode == 0 and CMP_f <=1E-4 then
//      lock = true;
//   end when;

  DeltaT_real = Tset - Tmeas;

  if DeltaT_real > DeltaTup then
    HP_operative_mode= 1;
  elseif DeltaT_real < DeltaTlow then
     HP_operative_mode = -1;
  elseif pre(HP_operative_mode) == 1 and DeltaT_real > 0 then
     HP_operative_mode = 1;
  elseif pre(HP_operative_mode) == -1 and DeltaT_real < 0 then
     HP_operative_mode = -1;
  else
      HP_operative_mode =0;
  end if;

  if HP_operative_mode == 1 then
    CMP_f_H = Buildings.Utilities.Math.Functions.smoothMax(conPID_Heat.y*f_nominal,0,1e-4);
    CMP_f = CMP_f_H;
    CMP_f_C = 0;
    Load_Control_H = Buildings.Utilities.Math.Functions.smoothMax(1,0,1e-4);
    Source_Control_H = Buildings.Utilities.Math.Functions.smoothMax(1,0,1e-4);
    Load_Control_C = 0;
    Source_Control_C = 0;
  elseif HP_operative_mode == -1 then
    CMP_f_H = 0;
    CMP_f = CMP_f_C;
    CMP_f_C = Buildings.Utilities.Math.Functions.smoothMax(conPID_Cool.y*f_nominal,0,1e-4);
    Load_Control_H = 0;
    Source_Control_H = 0;
    Load_Control_C = Buildings.Utilities.Math.Functions.smoothMax(1,0,1e-4);
    Source_Control_C = Buildings.Utilities.Math.Functions.smoothMax(1,0,1e-4);
  else
//     if last_active_mode ==1 then
//       if lock == false then
//         CMP_f_H = Buildings.Utilities.Math.Functions.smoothMax(conPID_Heat.y*f_nominal,0,1e-4);
//       else
//         CMP_f = 0;
//       end if;
//       CMP_f_C = 0;
//       CMP_f = CMP_f_H;
//       Load_Control_H = 1;
//       Source_Control_H = 1;
//       Load_Control_C = 1;
//       Source_Control_C = 1;
//     else
//       if lock == false then
//         CMP_f_C = Buildings.Utilities.Math.Functions.smoothMax(conPID_Cool.y*f_nominal,0,1e-4);
//       else
//         CMP_f_C = 0;
//       end if;
      CMP_f_C = 0;
      CMP_f_H = 0;
      CMP_f = CMP_f_C;
      Load_Control_H = 1;
      Source_Control_H = 1;
      Load_Control_C = 1;
      Source_Control_C = 1;
//    end if;
  end if;

  if DeltaT_real > DeltaTup then
    conPID_Heat.trigger = true;
    conPID_Cool.trigger = false;
  elseif DeltaT_real < DeltaTlow then
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
          preserveAspectRatio=false)));
end Control_vs_1;
