
// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the AIRFLOWCTRLDLL_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// AIRFLOWCTRLDLL_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.
#ifdef AIRFLOWCTRLDLL_EXPORTS
#define AIRFLOWCTRLDLL_API __declspec(dllexport)
#else
#define AIRFLOWCTRLDLL_API __declspec(dllimport)
#endif

#define OP_NONE			0
#define OP_SQUAREWAVE	1
#define OP_RAMP			2
#define OP_LISSA		3
#define OP_PULSE		4
#define OP_WAVEFORM		5
#define OP_HR_FOLLOW	6
/*
AIRFLOWCTRLDLL_API int fnAirFlowCtrlDll(void);
*/
AIRFLOWCTRLDLL_API int openDevice(int devNum);
AIRFLOWCTRLDLL_API double readAD();
AIRFLOWCTRLDLL_API unsigned long setAirFlow(int channel,float value);
AIRFLOWCTRLDLL_API int closeDevice();
AIRFLOWCTRLDLL_API void setPeriod(int period);
AIRFLOWCTRLDLL_API void start(int);
AIRFLOWCTRLDLL_API void stop();
AIRFLOWCTRLDLL_API void setLissaParam(float,float,float,float,float,float);
AIRFLOWCTRLDLL_API void setVoltageBounds(float vMin,float vMax);
AIRFLOWCTRLDLL_API void setULimit(float uLimit);
AIRFLOWCTRLDLL_API void playWaveForm();
AIRFLOWCTRLDLL_API void setWaveForm(double* ptr,long size,long triggerPosition,long period);
AIRFLOWCTRLDLL_API int detectPulse();
AIRFLOWCTRLDLL_API double mean();
AIRFLOWCTRLDLL_API double sdev();
AIRFLOWCTRLDLL_API void setSdevFactor(double sdevFactor);
AIRFLOWCTRLDLL_API int sendPulses(unsigned int in_pulsesToSend,double in_sdevFactor);
AIRFLOWCTRLDLL_API void stopPulses();
AIRFLOWCTRLDLL_API void setParPortParams(unsigned int baseAddress, unsigned int bits);
AIRFLOWCTRLDLL_API void configChannel(unsigned int channel, unsigned int rengeInd);

