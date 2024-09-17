function [Kite, CF, AEP] = AWEperf(vw, Pcurve, vw_ci, vw_rated)
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




curvefit     = linspace(0,25,26)';   % Wind speed range for curve fit
                                   
Pcurvefit1      = fit(curvefit(vw_ci:vw_rated),Pcurve(vw_ci:vw_rated),'poly5');    % For wind speed between cut-in and rated m/s 
Coeffs     = coeffvalues(Pcurvefit1);

Kite  = zeros(length(vw),1); 
for i = 1:length(vw)

    if vw(i) >= vw_ci && vw(i) <= vw_rated

        Kite(i) = polyval(Coeffs,vw(i));

    elseif vw(i) > vw_rated

        Kite(i) = Pcurve(vw_rated);

    else 

        Kite(i) = Pcurve(1);

    end

end

Kiteexceed = Kite>1e5;
Kite(Kiteexceed) = 1e5;
Kite = Kite/1e3;
CF = sum(Kite)/(100*8760);
AEP = sum(Kite/1e3); 



