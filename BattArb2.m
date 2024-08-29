function [Batt,C,f_repl,E,R] = BattArb2(w, var, DAM, Psm, Esm, Battmin, Battmax, Size, Type, eff, n, N, DoD) 
    
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


    for win = 0:length(DAM)/w - w
          for  i = win*w + (1:w)

                if      DAM(i) < (1-var)*mean(DAM(win*w+1:win*w+w)) 

                         Batt(i+1) = Batt(i) + min((Type*Size - Psm(i)), Battmax - Batt(i) - Esm(i)) ;
    
                elseif  DAM(i) >= (1+var)*mean(DAM(win*w+1:win*w+w)) 
            
                        Batt(i+1) = Batt(i) - min((Type*Size - Psm(i)), Batt(i) - Esm(i) - Battmin) ;
            
                else 
                        Batt(i+1) = Batt(i);

                end
          end
    end  



BattC = diff(Batt)/1e3;         % Battery charge[+]/discharge[-] [kW]  
BattC(8760) = 0;

Charge     = abs(max(BattC,0));              % Hourly battery charge power [kW]
disCharge  = abs(min(BattC,0))*eff;  % Hourly battery discharge power [kW], roundtrip efficiency taken at discharge

C = Charge - disCharge;

f_repl = max( 1/n,(sum(abs(C)*1e3) + sum(DoD))/(Size*N));  % frequency of replacement Battery system [/year]

E = sum(abs(min(C,0)))/1e3;                             % discharged energy by battery [MWh]
R = sum( DAM.* disCharge/1e3 - DAM.* Charge/1e3,"omitnan");     % arbitrage revenue [EUR]

