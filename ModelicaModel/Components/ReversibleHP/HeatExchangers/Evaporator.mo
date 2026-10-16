within HeatPumpModel.Components.ReversibleHP.HeatExchangers;
model Evaporator
//--------------------------------------------------------------------------------------------------------------
  import HeatPumpModel.Components.ReversibleHP.HeatExchangers.Types.SecondaryType;
  parameter SecondaryType secType = SecondaryType.AirWater "Type of HP"
    annotation (Evaluate = true, Dialog(group = "HP type"));

  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    annotation (
      Dialog(group = "HP type"),
      choices(
        choice(redeclare package Medium = Buildings.Media.Air "Air"),
        choice(redeclare package Medium = Buildings.Media.Antifreeze.PropyleneGlycolWater (property_T=293.15, X_a=0.3)
                                                                                                                      "Propylene glycol mixture")));
  // ------------Common parameter----------------------------------------------------------------------------------------------------------------------------------------------------------------

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal "Portata massica nominale del secondario"
    annotation (Dialog(group = "Common data"));
  parameter Modelica.Units.SI.PressureDifference dp_nominal(displayUnit = "Pa") = 0
    annotation (Dialog(group = "Common data"));
  parameter Modelica.Units.SI.Volume V "Volum" annotation (Dialog(group = "Common data"));
  parameter Real UA_nom_heat(unit = "W/K") "Nominal UA heating mode" annotation (Dialog(group = "Common data"));
  parameter Real UA_nom_cool(unit = "W/K") "Nominal UA cooling mode" annotation (Dialog(group = "Common data"));
  parameter Real m_f_nom_heat(unit = "kg/s") "nominal heating mass flow rate" annotation (Dialog(group = "Common data"));
  parameter Real m_f_nom_cool(unit = "kg/s") "nominal cooling mass flow rate" annotation (Dialog(group = "Common data"));
  parameter Real K_UA "Optimization parameter" annotation (Dialog(group = "Common data"));
  parameter Modelica.Units.SI.Time Tau_cost(displayUnit = "s") "Time constant"
    annotation (Dialog(group = "Common data"));
  parameter String UA_value = "Nominal value" "UA calculation method"
    annotation (Dialog(group = "Common data"),
                choices(choice = "Nominal value", choice = "Parametric correlation"));

  // ------------Air-to-water parameters----------------------------------------------------------------------------------------------------------------------------------------------------

  parameter Real k_ice = 0 "ice forminng factor"
    annotation (Dialog(group = "Air-to-water", enable = secType == SecondaryType.AirWater));

  // ------------Water-to-water parameters----------------------------------------------------------------------------------------------------------------------------------------------------

  parameter Real m_ref_nom_heat(unit = "kg/s") = 1 "Heating nominal refrigerant mass flow rate"
    annotation (Dialog(group = "Water-to-water", enable = secType == SecondaryType.WaterWater));
  parameter Real m_ref_nom_cool(unit = "kg/s") = 1 "Cooling nominal refrigerant mass flow rate"
    annotation (Dialog(group = "Water-to-water", enable = secType == SecondaryType.WaterWater));
  parameter HeatPumpModel.Components.ReversibleHP.HeatExchangers.HE_data.HE_poly HE_data
    "Water-to-water polynomial coefficients"
    annotation (Dialog(group = "Water-to-water", enable = secType == SecondaryType.WaterWater));

  // ------------Interfaccia unica verso il sistema----------------------------------------------------------------------------------------------------------------------------------------

  Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium = Medium)
    "Entering fluid"
    annotation (Placement(transformation(extent = {{-110, -10}, {-90, 10}}), iconTransformation(extent = {{-110, -10}, {-90, 10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(redeclare package Medium = Medium)
    "Exiting fluid"
    annotation (Placement(transformation(extent = {{90, -10}, {110, 10}}), iconTransformation(extent = {{90, -10}, {110, 10}})));

  Modelica.Blocks.Interfaces.RealInput HE_input[2](each unit = "W")
    "[1] Heatflow, [2] mass flow"
    annotation (Placement(transformation(extent = {{-12, -12}, {12, 12}}, rotation = 90, origin = {0, -112}),
                iconTransformation(extent = {{-12, -12}, {12, 12}}, rotation = 90, origin = {0, -112})));
  Modelica.Blocks.Interfaces.IntegerInput HP_operative_status "+1 Heating, -1 cooling"
    annotation (Placement(transformation(extent = {{-122, 68}, {-100, 90}}), iconTransformation(extent = {{-122, 68}, {-100, 90}})));

  Modelica.Blocks.Interfaces.BooleanInput DefInput if secType == SecondaryType.AirWater
    "Defrost input"
    annotation (Placement(transformation(extent = {{-116, 32}, {-100, 48}}), iconTransformation(extent = {{-116, 32}, {-100, 48}})));

  Modelica.Blocks.Interfaces.RealOutput RefT(unit = "K") "Refrigerant temperature"
    annotation (Placement(transformation(extent = {{-100, -50}, {-120, -30}}), iconTransformation(extent = {{-100, -50}, {-120, -30}})));
  Modelica.Blocks.Interfaces.RealOutput Pow_secondary(unit = "W")
    "Heat flow calulcated at the secondary side"
    annotation (Placement(transformation(extent = {{100, -52}, {120, -32}}), iconTransformation(extent = {{100, -52}, {120, -32}})));

  // ------------Two secondary fluid models----------------------------------------------------------------------------------------------------------------------------

  FinCoil_EVA air(
    redeclare package Medium = Medium,
    m_flow_nominal = m_flow_nominal,
    dp_nominal = dp_nominal,
    V = V,
    UA_nom_heat = UA_nom_heat,
    UA_nom_cool = UA_nom_cool,
    m_f_nom_heat = m_f_nom_heat,
    m_f_nom_cool = m_f_nom_cool,
    K_UA = K_UA,
    Tau_cost_FC = Tau_cost,
    UA_value_FC = UA_value,
    k_ice = k_ice) if secType == SecondaryType.AirWater "Ait-to-water";

  PlateHE_EVA wat(
    redeclare package Medium = Medium,
    m_flow_nominal = m_flow_nominal,
    dp_nominal = dp_nominal,
    V = V,
    UA_nom_heat = UA_nom_heat,
    UA_nom_cool = UA_nom_cool,
    m_f_nom_heat = m_f_nom_heat,
    m_f_nom_cool = m_f_nom_cool,
    m_ref_nom_heat = m_ref_nom_heat,
    m_ref_nom_cool = m_ref_nom_cool,
    K_UA = K_UA,
    Tau_cost_PHE = Tau_cost,
    UA_value_PHE = UA_value,
    HE_data = HE_data) if secType == SecondaryType.WaterWater "Water-to-water";

  // =================EQUATION BLOCK===============================================================================================================================================================

equation

  // Control of the model
  assert(secType == SecondaryType.WaterWater or Medium.nXi > 0,
    "secType = AirWater requires a Medium with humidity");

  // ------------Secondary fluid----------------------------------------------------------------------------------------------------------------------------------------------------------------
  connect(port_a, air.port_a);
  connect(air.port_b, port_b);
  connect(port_a, wat.port_a);
  connect(wat.port_b, port_b);

  // ------------Input signal---------------------------------------------------------------------------------------------------------------------------------------------------------
  connect(HE_input[1], air.HE_input);
  connect(HE_input, wat.HE_input);
  connect(HP_operative_status, air.HP_operative_status);
  connect(HP_operative_status, wat.HP_operative_status);
  connect(DefInput, air.DefInput);

  // ------------Output singal----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  connect(air.RefT, RefT);
  connect(wat.RefT_filter, RefT);
  connect(wat.Pow_secondary, Pow_secondary);

  connect(air.Pow_secondary, Pow_secondary);     // richiede l'uscita Pow_secondary dentro FinCoil

  annotation (defaultComponentName = "eva",
    Icon(graphics = {
      Text(extent = {{-150, 140}, {150, 110}}, textString = "%name", lineColor = {0, 0, 255}),
        Rectangle(
          extent={{-70,60},{70,-60}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-101,5},{100,-4}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,-4},{100,5}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid)}),
    Documentation(info = "<html>
<p>
Wrapper che sceglie il modello dell'evaporatore in base a <code>secType</code>:
aria-acqua (<code>FinCoil_vs_2</code>, con defrost) o acqua-acqua (<code>PlateHE_vs_2</code>).
Una sola variante è attiva; l'altra e le sue connect vengono rimosse in fase di traduzione.
</p>
<p>
Nel modello di sistema usare lo stesso parametro <code>secType</code> per rendere condizionali
la sorgente del segnale di defrost e la sua connect verso <code>DefInput</code>.
</p>
</html>"));
end Evaporator;
