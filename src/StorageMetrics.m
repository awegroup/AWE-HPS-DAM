function [LF, VoSA] = StorageMetrics(R,C,Cap,Type)
  %ECO_NPV Calculate the net present value NPV and it is used to compute the
  %internal rate of return IRR
  %
  %   Inputs:
  %   - C:   Battery charge/discharge power series [kW]
  %   - R:   Revenue cash flow [EUR]
  %   - Cap: Capacity of storage system [Wh].
  %   - Type: C rating of storage system [-].
  %    
  %
  %   Outputs:
  %   - Load Factor: number of charge/discharge hours over total hours in
  %   year [%]
  %   - Value of storage arbitrage [kEUR/MW/year]

LF = nnz(C)/length(C);


VoSA = R/(Cap*Type/1e3)/1e3;

end