function inp = eco_system_inputs_example_HPP

  global eco_settings

  eco_settings.input_cost_file  = 'eco_cost_inputs_GG_fixed'; % eco_cost_inputs_GG_fixed || eco_cost_inputs_FG || eco_cost_inputs_GG_soft || set the input file
  eco_settings.input_model_file = 'code'; % code || eco_system_inputs_GG_fixed_example || eco_system_inputs_FG_example || eco_system_inputs_GG_soft_example || set the input file
  eco_settings.power            = 'GG';  % FG || GG 
  eco_settings.wing             = 'fixed';  % fixed || soft
  
  %% Common parameters
  % Wind conditions
  atm.k = 2;
  atm.A = 8;
  
  % Business related quantities
  inp.business.N_y     = 25; % project years
  inp.business.r_d     = 0.08; % cost of debt
  inp.business.r_e     = 0.12; % cost of equity
  inp.business.TaxRate = 0.25; % Tax rate (25%)
  inp.business.DtoE    = 70/30; % Debt-Equity-ratio
  
  %% Topology specific parameters
  switch eco_settings.input_model_file
      case 'code'
  
          switch eco_settings.power
              case 'FG'
                  
                  % Wind resources
                  inp.atm.wind_range = [3:1/3:10, 15, 20]; % m/s
                  inp.atm.gw         = atm.k/atm.A *(inp.atm.wind_range/atm.A).^(atm.k-1).*exp(-(inp.atm.wind_range/atm.A).^atm.k); % - Wind distribution
                                  
                  % Kite
                    inp.kite.structure.m            = processedOutputs.m_k; % kg
                    inp.kite.structure.A            = inputs.S; % m^2
                    inp.kite.structure.f_repl       = 0; % /year
                    inp.kite.obGen.P                = 1e3; % W
                    inp.kite.obBatt.E               = 1; % kWh
                  
                  % Tether
                  inp.tether.d      = 1.6 *1e-3 * inp.kite.structure.b; % m
                  inp.tether.L      = 100; % m
                  inp.tether.rho    = 970; % kg/m^3
                  inp.tether.f_repl = -1; 
                  
                  % System
                  inp.system.F_t       = inp.tether.d^2/4*pi* [0.124572136342289,0.151797436838344,0.181460994246145,0.214172304028360,0.250094485666586,0.289217262316979,0.331480668302760,0.376825094990467,0.425204519064134,0.476587107759039,0.530951609064390,0.588284030406247,0.648575480469101,0.711819900342773,0.667172308938198,0.538286443708873,0.479418546822401,0.440125256353379,0.410771458547833,0.387467590011167,0.368260306087034,0.352050875661555,0.3,0.25]*1e9; % N
                  inp.system.P_e_rated = 100e3; % W
                  inp.system.P_e_avg   = inp.system.P_e_rated * [0.0514836036930580,0.0740924523303653,0.101398515897930,0.133916653105838,0.172155839837058,0.216618610982057,0.267802451082606,0.326201238110832,0.392306298442283,0.466607150752925,0.549592018061346,0.641748164098206,0.743562144341504,0.855519973731538,0.978107215387062,0.999997934928179,0.999999974273665,0.999999480541176,0.999999330603523,0.999999355894903,0.999999280365251,0.999996057827535, 1,1]; % W
                  inp.system.lambda    = 7; % wing speed ratio
                  inp.system.R0        = 5*inp.kite.structure.b; % turbing radius
                  
                  % Ground station
                  inp.gStation.ultracap.E_rated = inp.kite.structure.m * 9.81*inp.kite.structure.b*5/3.6e6; % kWh
                  inp.gStation.ultracap.f_repl  = -1;
                  inp.gStation.batt.E_rated     = inp.system.P_e_rated/1e3; % kWh
                  inp.gStation.batt.f_repl      = -1; % /year
                  
              case  'GG' 
                  switch eco_settings.wing
                      case 'fixed'
                          
                           atm.k = 2;
                           atm.A = 8;     
                          
                            % Wind resources
                            inp.atm.wind_range = processedOutputs.vw_100m_operRange; % m/s
                            inp.atm.gw         = atm.k/atm.A *(inp.atm.wind_range/atm.A).^(atm.k-1).*exp(-(inp.atm.wind_range/atm.A).^atm.k); % Wind distribution
  
                            % Kite
                            inp.kite.structure.m            = processedOutputs.m_k; % kg
                            inp.kite.structure.A            = inputs.S; % m^2
                            inp.kite.structure.f_repl       = 0; % /year
                            inp.kite.obGen.P                = 1e3; % W
                            inp.kite.obBatt.E               = 1; % kWh
  
                            % Tether
                            inp.tether.d      = processedOutputs.Dia_te; % m
                            inp.tether.L      = max(processedOutputs.l_t_max); %m
                            inp.tether.rho    = inputs.Te_matDensity; % kg/m^3
                            inp.tether.f_repl = -1; % /year
  
                            % System
                            inp.system.F_t       = mean(processedOutputs.Ft,2)'; % N
                            inp.system.P_m_peak  = max(processedOutputs.P_m_o); % W
                            inp.system.P_e_avg   = processedOutputs.P_e_avg; % W
                            inp.system.P_e_rated = inputs.P_ratedElec; % W
                            inp.system.Dt_cycle  = processedOutputs.tCycle; % s
  
                            % Ground station
                            inp.gStation.ultracap.E_rated = 1.1*max(processedOutputs.storageExchange)/1e3; % kWh % 10% oversizing safety factor; % kWh
                            inp.gStation.ultracap.E_ex    = processedOutputs.storageExchange; % kWh
                            inp.gStation.ultracap.f_repl  = -1; % /year                          
                            inp.gStation.hydAccum.E_rated = inp.gStation.ultracap.E_rated ;  % kWh
                            inp.gStation.hydAccum.E_ex    = inp.gStation.ultracap.E_ex; % kWh
                            inp.gStation.hydAccum.f_repl  = -1; % /year
                            inp.gStation.hydMotor.f_repl  = 0; % /year
                            inp.gStation.pumpMotor.f_repl = 0; % /year
                          
                      case 'soft'
                          
                          % Wind resources
                          inp.atm.wind_range = [4,5,6,7,8,9,10,11,12,13,14,16,18,20,22];
                          inp.atm.gw         = atm.k/atm.A *(inp.atm.wind_range/atm.A).^(atm.k-1).*exp(-(inp.atm.wind_range/atm.A).^atm.k); % Wind distributio
                          
                          % Kite
                          inp.kite.structure.m           = 4e2;
                          inp.kite.structure.A           = 15;
                          inp.kite.structure.f_repl      = -1;
                          inp.kite.obGen.P               = 1e3; % W
                          inp.kite.obBatt.E              = 0; % kWh
                          
                          % Tether
                          inp.tether.d      = 2e-2;
                          inp.tether.L      = 300;
                          inp.tether.rho    = 1e3;
                          inp.tether.f_repl = -1;
                          
                          % System
                          inp.system.F_t       = [19581.5974490300,30589.4427976802,43855.1311512270,58322.4490072310,69451.8065536476,68432.4018007148,69371.4628861828,69478.8976127206,69485.8563217407,69497.1308164078,69482.9452160423,69481.7762790974,69481.0428798217,62833.9833242605,51867.1740101547];
                          inp.system.P_m_peak  = 200e3;
                          inp.system.P_e_avg   = 3/4*[21496.0471473482,41246.4942079856,69966.0193058485,108887.503260755,156932.246230542,198576.031463368,198565.375606173,198114.942308234,197641.383532483,197199.181237688,196755.860610617,195920.800890573,195135.252500918,174603.698597567,143719.204086628];
                          inp.system.P_e_rated = max(inp.system.P_e_avg);
                          inp.system.Dt_cycle  = 60; % s
                          
                          % Ground station
                          inp.gStation.ultracap.E_rated = 1.1*inp.system.P_e_rated * 25/3600/1e3; % kWh
                          inp.gStation.ultracap.E_ex    = inp.gStation.ultracap.E_rated/2; % kWh
                          inp.gStation.ultracap.f_repl  = -1;    
                          inp.gStation.batt.E_rated     = inp.system.P_e_rated/1e3; % kWh
                          inp.gStation.batt.E_ex        = inp.gStation.ultracap.E_rated/2; % kWh
                          inp.gStation.batt.f_repl      = -1; % /year
                          inp.gStation.hydAccum.E_rated = inp.gStation.ultracap.E_rated ;  % kWh
                          inp.gStation.hydAccum.E_ex    = inp.gStation.ultracap.E_ex; % kWh
                          inp.gStation.hydAccum.f_repl  = 0.1;
                          inp.gStation.hydMotor.f_repl  = 0.083;
                          inp.gStation.pumpMotor.f_repl =  0.125;
                          
                  end             
          end        
      otherwise
          inp = eco_import_model(inp); 
          inp.atm.gw  = atm.k/atm.A *(inp.atm.wind_range/atm.A).^(atm.k-1).*exp(-(inp.atm.wind_range/atm.A).^atm.k); % Wind distribution

  end
end