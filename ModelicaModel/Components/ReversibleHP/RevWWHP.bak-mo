within HeatPumpModel.Components.ReversibleHP;
model RevWWHP

  replaceable package LoadMedium =
    Modelica.Media.Interfaces.PartialMedium "Medium in the component"
      annotation (choices(
        choice(redeclare package Medium = Buildings.Media.Air "Moist air"),
        choice(redeclare package Medium = Buildings.Media.Water "Water"),
        choice(redeclare package Medium =
            Buildings.Media.Antifreeze.PropyleneGlycolWater (
              property_T=293.15,
              X_a=0.40)
              "Propylene glycol water, 40% mass fraction"),
              Dialog(group="Fluid")));

  replaceable package SourceMedium =
    Modelica.Media.Interfaces.PartialMedium "Medium in the component"
      annotation (choices(
        choice(redeclare package Medium = Buildings.Media.Air "Moist air"),
        choice(redeclare package Medium = Buildings.Media.Water "Water"),
        choice(redeclare package Medium =
            Buildings.Media.Antifreeze.PropyleneGlycolWater (
              property_T=293.15,
              X_a=0.40)
              "Propylene glycol water, 40% mass fraction"),
              Dialog(group="Fluid")));

  // Heating Mode
  replaceable parameter Real h_load_efficiency = 0.9 "Condenser/Load HEx efficiency"
  annotation(Dialog(group="Heating Mode"));
  parameter Modelica.Units.SI.MassFlowRate h_load_m_flow_nominal "Nominal mass flow rate condenser/load"
  annotation(Dialog(group="Heating Mode"));
  replaceable parameter Real h_source_efficiency = 0.9 "Evaporator/Source HEx efficiency"
  annotation(Dialog(group="Heating Mode"));
  parameter Modelica.Units.SI.MassFlowRate h_source_m_flow_nominal "Nominal mass flow rate evaporator/source"
  annotation(Dialog(group="Heating Mode"));

  // Cooling Mode
  replaceable parameter Real c_load_efficiency = 0.9 "Condenser/Load HEx efficiency"
  annotation(Dialog(group="Cooling Mode"));
  parameter Modelica.Units.SI.MassFlowRate c_load_m_flow_nominal "Nominal mass flow rate condenser/load"
  annotation(Dialog(group="Cooling Mode"));
  replaceable parameter Real c_source_efficiency = 0.9 "Evaporator/Source HEx efficiency"
  annotation(Dialog(group="Cooling Mode"));
  parameter Modelica.Units.SI.MassFlowRate c_source_m_flow_nominal "Nominal mass flow rate evaporator/source"
  annotation(Dialog(group="Cooling Mode"));

  Modelica.Fluid.Interfaces.FluidPort_a LEF
    annotation (Placement(transformation(extent={{-110,90},{-90,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a SEF
    annotation (Placement(transformation(extent={{-110,-110},{-90,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_b LExF
    annotation (Placement(transformation(extent={{90,90},{110,110}})));
  Modelica.Fluid.Interfaces.FluidPort_b SExF
    annotation (Placement(transformation(extent={{90,-110},{110,-90}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val(
    redeclare package Medium = LoadMedium,
    m_flow_nominal=h_load_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0) annotation (Placement(transformation(extent={{-68,66},{-48,86}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val1(
    redeclare package Medium = LoadMedium,
    m_flow_nominal=c_load_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0) annotation (Placement(transformation(extent={{-68,48},{-48,28}})));
  Modelica.Blocks.Math.Max HeatSign
    annotation (Placement(transformation(extent={{-104,6},{-84,26}})));
  Modelica.Blocks.Sources.Constant const(k=0)
    annotation (Placement(transformation(extent={{-128,18},{-120,26}})));
  Modelica.Blocks.Math.Gain gain(k=-1)
    annotation (Placement(transformation(extent={{-126,-20},{-118,-12}})));
  Modelica.Blocks.Sources.Constant const1(k=0)
    annotation (Placement(transformation(extent={{-126,-32},{-118,-24}})));
  Modelica.Blocks.Math.Max CoolSign
    annotation (Placement(transformation(extent={{-104,-32},{-84,-12}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val2(
    redeclare package Medium = SourceMedium,
    m_flow_nominal=h_source_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0)
    annotation (Placement(transformation(extent={{-68,-28},{-48,-48}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val3(
    redeclare package Medium = SourceMedium,
    m_flow_nominal=c_source_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0)
    annotation (Placement(transformation(extent={{-68,-88},{-48,-68}})));
  Modelica.Blocks.Interfaces.RealInput HeatCoolSignal
    annotation (Placement(transformation(extent={{-180,-20},{-140,20}})));
  Modelica.Blocks.Math.RealToInteger realToInteger
    annotation (Placement(transformation(extent={{-10,-68},{0,-58}})));
  Modelica.Blocks.Interfaces.RealOutput HR
    annotation (Placement(transformation(extent={{100,26},{120,46}})));
  Modelica.Blocks.Interfaces.RealOutput HE
    annotation (Placement(transformation(extent={{96,-46},{116,-26}})));
  Modelica.Blocks.Interfaces.RealOutput PEl
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val4(
    redeclare package Medium = SourceMedium,
    m_flow_nominal=c_source_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={92,-78})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val5(
    redeclare package Medium = SourceMedium,
    m_flow_nominal=h_source_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={138,-56})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val6(
    redeclare package Medium = LoadMedium,
    m_flow_nominal=c_load_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0) annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={134,54})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear val7(
    redeclare package Medium = LoadMedium,
    m_flow_nominal=h_load_m_flow_nominal,
    CvData=Buildings.Fluid.Types.CvTypes.OpPoint,
    Kv=1,
    dpValve_nominal=10,
    dpFixed_nominal=0,
    kFixed=0) annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={106,80})));
  HeatPumpTests.Components.BaseHeatPump CoolingModeHP(
    redeclare package cond_medium = SourceMedium,
    cond_m_flow_nominal=c_source_m_flow_nominal,
    cond_efficiency=c_source_efficiency,
    redeclare package ev_medium = LoadMedium,
    ev_m_flow_nominal=c_load_m_flow_nominal,
    ev_efficiency=c_load_efficiency) annotation (Placement(transformation(extent={{10,-54},{30,-74}})));
  HeatPumpTests.Components.BaseHeatPump HeatingModeHP(
    redeclare package cond_medium = LoadMedium,
    cond_m_flow_nominal=h_load_m_flow_nominal,
    cond_efficiency=h_load_efficiency,
    redeclare package ev_medium = SourceMedium,
    ev_m_flow_nominal=h_source_m_flow_nominal,
    ev_efficiency=h_source_efficiency) annotation (Placement(transformation(extent={{4,40},{24,60}})));
  Modelica.Blocks.Math.RealToInteger realToInteger1
    annotation (Placement(transformation(extent={{-18,44},{-8,54}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{78,26},{98,46}})));
  Modelica.Blocks.Math.Add add1
    annotation (Placement(transformation(extent={{78,-10},{98,10}})));
  Modelica.Blocks.Math.Add add2
    annotation (Placement(transformation(extent={{78,-46},{98,-26}})));
equation
  connect(SEF, SEF)
    annotation (Line(points={{-100,-100},{-100,-100}},
                                                     color={0,127,255}));
  connect(SExF, SExF)
    annotation (Line(points={{100,-100},{100,-100}},
                                                   color={0,127,255}));
  connect(CoolSign.y, val1.y)
    annotation (Line(points={{-83,-22},{-58,-22},{-58,26}},
                                                          color={0,0,127}));
  connect(HeatSign.y, val.y) annotation (Line(points={{-83,16},{-82,16},{-82,
          90},{-58,90},{-58,88}},
                                color={0,0,127}));
  connect(const.y, HeatSign.u1)
    annotation (Line(points={{-119.6,22},{-106,22}},
                                                   color={0,0,127}));
  connect(gain.y, CoolSign.u1)
    annotation (Line(points={{-117.6,-16},{-106,-16}},
                                                     color={0,0,127}));
  connect(const1.y, CoolSign.u2)
    annotation (Line(points={{-117.6,-28},{-106,-28}},
                                                     color={0,0,127}));
  connect(LEF, val.port_a) annotation (Line(points={{-100,100},{-78,100},{-78,
          76},{-68,76}},          color={0,127,255}));
  connect(LEF, val1.port_a) annotation (Line(points={{-100,100},{-78,100},{
          -78,76},{-72,76},{-72,38},{-68,38}},
                                  color={0,127,255}));
  connect(HeatSign.y, val2.y) annotation (Line(points={{-83,16},{-76,16},{-76,
          -50},{-58,-50}},color={0,0,127}));
  connect(CoolSign.y, val3.y)
    annotation (Line(points={{-83,-22},{-80,-22},{-80,-62},{-58,-62},{-58,-66}},
                                                           color={0,0,127}));
  connect(SEF, val3.port_a) annotation (Line(points={{-100,-100},{-100,-78},{
          -68,-78}},                               color={0,127,255}));
  connect(SEF, val2.port_a) annotation (Line(points={{-100,-100},{-100,-78},{
          -72,-78},{-72,-38},{-68,-38}},
                               color={0,127,255}));
  connect(HeatCoolSignal, HeatSign.u2) annotation (Line(points={{-160,0},{
          -114,0},{-114,10},{-106,10}},
                                 color={0,0,127}));
  connect(HeatCoolSignal, gain.u) annotation (Line(points={{-160,0},{-132,0},
          {-132,-16},{-126.8,-16}},
                                 color={0,0,127}));
  connect(val5.port_b, SExF) annotation (Line(points={{138,-66},{138,-100},{100,
          -100}},                            color={0,127,255}));
  connect(val4.port_b, SExF) annotation (Line(points={{92,-88},{78,-88},{78,
          -100},{100,-100}},                 color={0,127,255}));
  connect(HeatSign.y, val5.y) annotation (Line(points={{-83,16},{-82,16},{-82,90},
          {-66,90},{-66,96},{-8,96},{-8,82},{30,82},{30,-52},{62,-52},{62,-56},{
          126,-56}},color={0,0,127}));
  connect(CoolSign.y, val4.y) annotation (Line(points={{-83,-22},{-56,-22},{
          -56,-20},{-26,-20},{-26,-48},{-24,-48},{-24,-52},{-26,-52},{-26,-76},
          {-8,-76},{-8,-78},{10,-78},{10,-80},{22,-80},{22,-78},{80,-78}},
                                                               color={0,0,127}));
  connect(val7.port_b, LExF) annotation (Line(points={{106,90},{100,90},{100,
          100}},                          color={0,127,255}));
  connect(val6.port_b, LExF) annotation (Line(points={{134,64},{134,70},{120,
          70},{120,88},{126,88},{126,94},{100,94},{100,100}},
                                          color={0,127,255}));
  connect(HeatSign.y, val7.y) annotation (Line(points={{-83,16},{-82,16},{-82,
          90},{-66,90},{-66,96},{-8,96},{-8,80},{94,80}},
        color={0,0,127}));
  connect(CoolSign.y, val6.y) annotation (Line(points={{-83,-22},{-56,-22},{
          -56,-20},{2,-20},{2,54},{122,54}},
                              color={0,0,127}));
  connect(realToInteger.y, CoolingModeHP.OnOff) annotation (Line(points={{0.5,-63},
          {0.5,-64},{9.4,-64}},      color={255,127,0}));
  connect(CoolSign.y, realToInteger.u) annotation (Line(points={{-83,-22},{
          -56,-22},{-56,-20},{-26,-20},{-26,-63},{-11,-63}}, color={0,0,127}));
  connect(HeatSign.y, realToInteger1.u) annotation (Line(points={{-83,16},{
          -82,16},{-82,90},{-66,90},{-66,96},{-30,96},{-30,49},{-19,49}},
        color={0,0,127}));
  connect(val.port_b, HeatingModeHP.CondEF)
    annotation (Line(points={{-48,76},{8,76},{8,60}}, color={0,127,255}));
  connect(HeatingModeHP.CondExF, val7.port_a)
    annotation (Line(points={{20,60},{20,70},{106,70}}, color={0,127,255}));
  connect(val1.port_b, CoolingModeHP.EvEF) annotation (Line(points={{-48,38},{-24,
          38},{-24,-48},{14,-48},{14,-54}},      color={0,127,255}));
  connect(CoolingModeHP.EvExF, val6.port_a) annotation (Line(points={{26,-54},{26,
          -48},{134,-48},{134,44}},     color={0,127,255}));
  connect(val2.port_b, HeatingModeHP.EvEF) annotation (Line(points={{-48,-38},
          {-44,-38},{-44,24},{8,24},{8,40}}, color={0,127,255}));
  connect(val3.port_b, CoolingModeHP.CondEF) annotation (Line(points={{-48,-78},
          {-26,-78},{-26,-80},{14,-80},{14,-74}},      color={0,127,255}));
  connect(HeatingModeHP.EvExF, val5.port_a) annotation (Line(points={{20,40},{20,
          20},{138,20},{138,-46}},     color={0,127,255}));
  connect(CoolingModeHP.CondExF, val4.port_a) annotation (Line(points={{26,-74},
          {26,-78},{72,-78},{72,-62},{92,-62},{92,-68}},      color={0,127,
          255}));
  connect(HR, add.y)
    annotation (Line(points={{110,36},{99,36}}, color={0,0,127}));
  connect(HeatingModeHP.HR, add.u1) annotation (Line(points={{24.6,53.6},{68,
          53.6},{68,42},{76,42}}, color={0,0,127}));
  connect(PEl, add1.y)
    annotation (Line(points={{110,0},{99,0}}, color={0,0,127}));
  connect(HE, add2.y)
    annotation (Line(points={{106,-36},{99,-36}}, color={0,0,127}));
  connect(CoolingModeHP.PEl, add1.u2) annotation (Line(points={{30.6,-63.8},{74,
          -63.8},{74,-50},{66,-50},{66,-20},{76,-20},{76,-6}},    color={0,0,
          127}));
  connect(HeatingModeHP.PEl, add1.u1) annotation (Line(points={{24.6,49.8},{
          124,49.8},{124,14},{76,14},{76,6}}, color={0,0,127}));
  connect(HeatingModeHP.HE, add2.u1) annotation (Line(points={{24.6,46.4},{66,
          46.4},{66,-14},{78,-14},{78,-22},{76,-22},{76,-30}}, color={0,0,127}));
  connect(realToInteger1.y, HeatingModeHP.OnOff) annotation (Line(points={{
          -7.5,49},{-7.5,50},{3.4,50}}, color={255,127,0}));
  connect(CoolingModeHP.HR, add.u2) annotation (Line(points={{30.6,-67.6},{38,-67.6},
          {38,22},{68,22},{68,30},{76,30}},        color={0,0,127}));
  connect(CoolingModeHP.HE, add2.u2) annotation (Line(points={{30.6,-60.4},{76,-60.4},
          {76,-42}},           color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=604800,
      Interval=60,
      __Dymola_Algorithm="Dassl"));
end RevWWHP;
