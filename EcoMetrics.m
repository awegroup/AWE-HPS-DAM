function [LCoE, LRoE, LPoE, NPV1] = EcoMetrics(r,R,E,ICC,OMC,N_y)
  %ECO_NPV Calculate the net present value NPV and it is used to compute the
  %internal rate of return IRR
  %
  %   Inputs:
  %   - r:   Discout rate.
  %   - R:   Revenue cash flow .
  %   - ICC: Initial Capital Cost of system.
  %   - OMC: Operational Maintenance Cost system.
  %   - E:   Energy produced by system 
  %
  %   Outputs:
  %   - NPV: Updated input structure after processing.

LCoE_num = ones(25,1);
LCoE_den = ones(25,1);

for t = 1:N_y
      LCoE_num(t)    = OMC/(1+r)^t;                              % numerator LCoE [EUR]
      LCoE_den(t)    = E/(1+r)^t;
end

LCoE = (ICC + sum(LCoE_num))/sum(LCoE_den);

LRoE_num = ones(25,1);
LRoE_den = ones(25,1);

for t = 1:N_y
      LRoE_num(t)    = R/(1+r)^t;                              % numerator LCoE [EUR]
      LRoE_den(t)    = E/(1+r)^t;
end

LRoE = sum(LRoE_num)/sum(LRoE_den);

LPoE = LRoE - LCoE;

NPV1 = LPoE * sum(LCoE_den);

end