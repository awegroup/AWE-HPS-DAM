function [P_sm, E_sm, E_res, E_batt_req, E_UC_req] = AWEsm(vw, Kite, Esm, t_cyc, P_e, Pcurve)
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




E_res = ones(8760,1);       % set-up
E_sm = ones(8760,1);  

for i = 1:length(vw)                         % Smoothing intermediate storage needed per hour [Wh]
  for U = 1:length(Esm)

      if U <= vw(i) && vw(i) < U+1

          E_res(i) = Esm(U);            % smoothing capacity [Wh]

          E_sm(i) =  Esm(U)/(t_cyc(U)/3600);  % smoothing depth of discharge per hour [Wh]
      
      end
  end
end

E_UC_req = (1.1*(max(Esm)));
E_batt_req = round(max(abs(P_e-max(Kite))),0); 

E_sm(isnan(E_sm))=0;

P_sm  = zeros(length(vw),1);                    % [kW]
for i = 1:length(vw)
  for U = 1:length(Pcurve)

      if U <= vw(i) && vw(i) < U+1

          P_sm(i) = (E_batt_req/max(Kite))*Pcurve(U)/1e3; 
      
      end
  end
end




end