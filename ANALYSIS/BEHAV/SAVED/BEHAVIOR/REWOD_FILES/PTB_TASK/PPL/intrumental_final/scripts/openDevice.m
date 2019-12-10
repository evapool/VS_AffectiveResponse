function openDevice()
loadlibrary('AirFlowCtrlDll.dll','AirFlowCtrlDll.h');
calllib('AirFlowCtrlDll','openDevice',0);
