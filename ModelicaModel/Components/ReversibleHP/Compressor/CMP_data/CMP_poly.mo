within HeatPumpModel.Components.ReversibleHP.Compressor.CMP_data;
record CMP_poly
  // Velocità fissa
  parameter Real cc_10[10] = fill(1, 10) "Capacità frigorifera";
  parameter Real el_10[10] = fill(1, 10) "Potenza elettrica";
  // Velocità variabile, 20 coefficienti
  parameter Real cc_20[20] = fill(1, 20);
  parameter Real el_20[20] = fill(1, 20);
  // Velocità variabile, 30 coefficienti
  parameter Real cc_30[30] = fill(1, 30);
  parameter Real el_30[30] = fill(1, 30);
  //Standard value of superheat and subcooling
  parameter Real SH_map = 11.1;
  parameter Real SBC_map = 8.3;
end CMP_poly;
