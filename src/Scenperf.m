function [R_arb, R_kite, f_repl, CapEx, OpEx] = Scenperf(Kite, C, p_DAM, p_sub, Esm, N_years, N_cycles, p_stor, E_size, ICC, OMC)
  % Param Calculate the Wind and market data used in computing production and revenue
  %
  %   Inputs:
  %   - p:   DAM prcie data downloaded from entsoe.
  %   - vwu: ERA5 100m u wind speed.
  %   - vwv: ERA5 100m v wind speed.
  %
  %   Outputs:
  %   - Kite: hourly timeseries AWE power output.
  %   - vw: hourly timeseries wind speed data.
  %   - vol: volatility of DAM price data.



R_arb = sum( p_DAM .* abs(min(C/1e3,0)) - p_DAM .* abs(max(C/1e3,0)),"omitnan");     % arbitrage revenue [EUR]
R_kite = sum((p_DAM + p_sub) .* (Kite/1e3),"omitnan");

f_repl = max( 1/N_years,(sum(abs(C)) + sum(Esm))/(E_size*N_cycles));  % frequency of replacement Battery system [/year]

CapEx =  ICC + p_stor * E_size;
OpEx = OMC + f_repl* p_stor * E_size;

end