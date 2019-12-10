function configureAD(channel,gainIndex)
% gainIndex significations :
%   0: +/-5V
%   1: +/-2.5V
%   2: +/-1.25
%   3: +/-0.625V(only Rev.A)
%   4: +/-10V
calllib('AirFlowCtrlDll','configChannel',uint32(channel),uint32(gainIndex));