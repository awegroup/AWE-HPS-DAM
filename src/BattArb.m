function [Batt,C,f_repl,E,R] = BattArb(w, var, DAM, Psm, Esm, Battmin, Battmax, Size, Type, eff, n, N, DoD) 
    
  % ECO_NPV Calculate the net present value NPV and it is used to compute the
  % internal rate of return IRR
  %
  %   Inputs:
  %   - w:          storage duration window [hrs].
  %   - var:        variance at which to select peaks [-]
  %   - DAM:        Hourly market price timeseries over year [EUR/MWh]
  %   - Psm:        Hourly smoothing required power timeseries over year [W]
  %   - Esm:        Hourly smoothing required capacity timeseries over year [Wh]
  %   - Battmin:    Battery SoC limit lower [Wh] 
  %   - Battmax:    Battery SoC limit upper [Wh] 
  %   - Size:       Battery total capacity  [Wh] 
  %   - Type:       Battery C rate or P/E   [-]
  %   - n:          Battery lifetime [years] 
  %   - N:          Battery lifetime [cycles] 
  %   - DoD:        Hourly smoothing depth of discharge timeseries over year [Wh]



  %   Outputs:
  %   - Batt:       Battery hourly state of charge [Wh].
  %   - C:          Battery hourly charge (+ for charge/- for discharge) [W].
  %   - f_repl:     Replacement frequency of Battery [/year].
  %   - E:          Total Discharged energy  [MWh].
  %   - R:          Total Revenue of DAm arbitrage  [MWh].


Batt       = ones(8760,1);       % set-up
Batt(1,1)  = 0.5*Size;           % [Wh] Initial charge of the battery


for i = 1:length(DAM)-w           % Battery Charge [W] roundtrip efficiency taken into account at discharge

    if      DAM(i) < (1-var)*mean(DAM(i:i+w)) 

            Batt(i+1) = Batt(i) + min((Type*Size - Psm(i)), Battmax - Batt(i) - Esm(i)) ;
    
    elseif  DAM(i) >= (1+var)*mean(DAM(i:i+w))
            
            Batt(i+1) = Batt(i) - min((Type*Size - Psm(i)), Batt(i) - Esm(i) - Battmin) ;
            
    else 
            Batt(i+1) = Batt(i);
         
    end
end


C = (diff(Batt)*eff)/1e3;         % Battery charge[+]/discharge[-] [kW]  
C(8760) = 0;

f_repl = max( 1/n,(sum(abs(C)*1e3) + sum(DoD))/(Size*N));  % frequency of replacement Battery system [/year]

E = sum(abs(min(C,0)))/1e3;      % discharged energy by battery [MWh]
R = sum(DAM.*abs(min(C/1e3,0)) - DAM.*max(C/1e3,0),"omitnan");
