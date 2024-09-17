function [DAM, vw, vol] = Param(p, vwu,vwv)
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

p = p{:,"Var2"};                         % DAM price hourly [EUR/MWH]
p = rmmissing(p);
DAM = p;
% ERA5 wind speeds at 100m 2019 at Haringvliet
                        
vw = sqrt(vwu(1,1,:).^2+vwv(1,1,:).^2);    % The wind speed is a combination of the u and v component of the downloaded data
vw = reshape(vw,[],1);                        % Reshaping of the 1x1xN matrix to make it a vector

% Key indicators input data


vol = std(p); 

end