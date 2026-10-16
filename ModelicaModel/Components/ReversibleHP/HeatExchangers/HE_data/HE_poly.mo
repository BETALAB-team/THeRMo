within HeatPumpModel.Components.ReversibleHP.HeatExchangers.HE_data;
record HE_poly
  parameter Real m_coeff_H[6] = fill(1, 6) "Capacità frigorifera";
  parameter Real m_coeff_C[6] = fill(1, 6) "Potenza elettrica";
end HE_poly;
