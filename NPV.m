function [NPV, NPVflow] = NPV(r,R,ICC,OMC,N_y)
  %ECO_NPV Calculate the net present value NPV and it is used to compute the
  %internal rate of return IRR
  %
  %   Inputs:
  %   - r:   Discout rate.
  %   - R:   Revenue cash flow .
  %   - ICC: Initial Capital Cost of system.
  %   - OMC: Operational Maintenance Cost system.
  %
  %   Outputs:
  %   - NPV: Updated input structure after processing.

NPVflow = ones(1,N_y);
for t = 1:N_y
    NPVflow(t) =  (R - OMC)/(1+r)^t;
end

NPV = -ICC + sum(NPVflow);
end