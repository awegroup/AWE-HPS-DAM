function [DAM, vw, vol] = Pcurve(p, vwu,vwv)
  % Param Calculate the Wind and market data used in computing production and revenue
  %
  %   Inputs:
  %   - p:   DAM prcie data downloaded from entsoe.
  %   - vwu: ERA5 100m u wind speed.
  %   - vwv: ERA5 100m v wind speed.
  %
  %   Outputs:
  %   - DAM: hourly timeseries DAM prcie data.
  %   - vw: hourly timeseries wind speed data.
  %   - vol: volatility of DAM price data.

% Wind and market data used in computing production and revenue

% ENTso-E Day Ahead Market Price hourly