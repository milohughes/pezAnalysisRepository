
%%% PDCDEV

% Device Code
PDC.DEVTYPE_UNKNOWN                     = hex2dec('00000000');
PDC.DEVTYPE_FCAM_VIRTUAL                = hex2dec('00000001');
PDC.DEVTYPE_FCAM_MAX                    = hex2dec('00000002');
PDC.DEVTYPE_FCAM_APX                    = hex2dec('00000002');
PDC.DEVTYPE_FCAM_NEO                    = hex2dec('00000003');
PDC.DEVTYPE_FCAM_UL512                  = hex2dec('00000003');
PDC.DEVTYPE_FCAM_MAX_II                 = hex2dec('00000004');
PDC.DEVTYPE_FCAM_APX_II                 = hex2dec('00000004');
PDC.DEVTYPE_FCAM_APXRS                  = hex2dec('00000005');
PDC.DEVTYPE_FCAM_MH4                    = hex2dec('00000006');
PDC.DEVTYPE_FCAM_SA1                    = hex2dec('00000007');
PDC.DEVTYPE_FCAM_MC1                    = hex2dec('00000008');
PDC.DEVTYPE_FCAM_SA2                    = hex2dec('00000009');
PDC.DEVTYPE_FCAM_SA3                    = hex2dec('0000000a');
PDC.DEVTYPE_FCAM_CT3                    = hex2dec('0000000a');
PDC.DEVTYPE_FCAM_MC2                    = hex2dec('0000000b');
PDC.DEVTYPE_FCAM_SA5                    = hex2dec('0000000c');
PDC.DEVTYPE_FCAM_BC2                    = hex2dec('0000000d');
PDC.DEVTYPE_FCAM_SA4                    = hex2dec('0000000e');
PDC.DEVTYPE_FCAM_SAX                    = hex2dec('0000000f');
PDC.DEVTYPE_FCAM_PCI2                   = hex2dec('00000101');
PDC.DEVTYPE_FCAM_512PCI                 = hex2dec('00000102');
PDC.DEVTYPE_FCAM_SUSPCI                 = hex2dec('00000103');
PDC.DEVTYPE_FCAM_1024PCI                = hex2dec('00000104');
PDC.DEVTYPE_FCAM_1024PCIE               = hex2dec('00000105');
PDC.DEVTYPE_FCAM_DVR                    = hex2dec('00000200');
PDC.DEVTYPE_IDPEXPRESS                  = hex2dec('00000400');
PDC.DEVTYPE_FDM_PCIE_CL                 = hex2dec('00001000');
PDC.DEVTYPE_FCAM_SP8                    = hex2dec('00010000');
 
% Interface Code
PDC.INTTYPE_VIRTUAL                     = hex2dec('00000001');
PDC.INTTYPE_G_ETHER                     = hex2dec('00000002');
PDC.INTTYPE_IEEE1394                    = hex2dec('00000003');
PDC.INTTYPE_OPTICAL                     = hex2dec('00000004');
PDC.INTTYPE_USB2                        = hex2dec('00000005');
PDC.INTTYPE_PCI                         = hex2dec('00000100');
PDC.INTTYPE_DVR                         = hex2dec('00000200');


%%% PDCVALUE

% General
PDC.MAX_DEVICE                          = 64;		% Maximum connection devices
PDC.MAX_INTERFACE_TYPE                  = 10;		% Maximum interface type
PDC.MAX_DEVICE_TYPE                     = 64;		% Maximum device type
PDC.MAX_CHILD_DEVICE                    = 4;        % Maximum child devices
PDC.MAX_PARTITION                       = 64;		% Maximum partitions
PDC.MAX_LIST_NUMBER                     = 256;		% Maximum list parameters
PDC.MAX_STRING_LENGTH                   = 256;		% Maximum strings
PDC.MAX_LUTLIST_NUMBER                  = 4096;     % Maximum LUT list parameters

% Function On/Off(General)
PDC.FUNCTION_OFF                        = 0;
PDC.FUNCTION_ON                         = 1;

% Function presence
PDC.EXIST_NOTSUPPORTED                  = 0;
PDC.EXIST_SUPPORTED                     = 1;
PDC.EXIST_SENSOR_GAIN                   = 2;
PDC.EXIST_SENSOR_GAMMA                  = 3;
PDC.EXIST_COLORTEMP                     = 4;
PDC.EXIST_DSSHUTTER                     = 5;
PDC.EXIST_LUT                           = 6;
PDC.EXIST_SHADING                       = 7;
PDC.EXIST_II                            = 8;
PDC.EXIST_EDGE_ENHANCE                  = 9;
PDC.EXIST_VIDEO_OUT                     = 10;
PDC.EXIST_SHUTTERLOCK                   = 11;
PDC.EXIST_PARTITIONINC                  = 12;
PDC.EXIST_HEADEXCHANGE                  = 13;
PDC.EXIST_KEYLOCK                       = 14;
PDC.EXIST_IRIG                          = 15;
PDC.EXIST_MCDL                          = 16;
PDC.EXIST_FRAME_ZERO                    = 17;
PDC.EXIST_PIXELGAIN                     = 18;
PDC.EXIST_COLOR_ENHANCE                 = 19;
PDC.EXIST_AUTO_EXPOSURE                 = 20;
PDC.EXIST_DELAY                         = 21;
PDC.EXIST_DOWNLOAD_MODE                 = 22;
PDC.EXIST_VARIABLE_FUNCTION             = 23;
PDC.EXIST_LOWLIGHT_MODE                 = 24;
PDC.EXIST_PROGSWITCH_MODE               = 25;
PDC.EXIST_SHUTTERSPEED_USEC             = 26;
PDC.EXIST_SYNCOUT_TIMES                 = 27;
PDC.EXIST_STORE                         = 28;
PDC.EXIST_ETHER_INFO                    = 29;
PDC.EXIST_IRIG_PHASELOCK                = 30;
PDC.EXIST_HIGH_SPEED_MODE               = 31;
PDC.EXIST_BURST_TRANSFER                = 32;
PDC.EXIST_STEP_SHUTTER                  = 33;
PDC.EXIST_LIVE_RESOLUTION               = 34;
PDC.EXIST_BITDEPTH                      = 35;
PDC.EXIST_FPGA_SETTING                  = 36;
PDC.EXIST_CAMERA_DEF_FILE               = 37;
PDC.EXIST_IMAGE_ADDRESS                 = 38;
PDC.EXIST_SYNC_PRIORITY                 = 39;
PDC.EXIST_ROI                           = 40;
PDC.EXIST_CAMERA_COMMAND                = 41;
PDC.EXIST_VIDEO_SIGNAL                  = 42;
PDC.EXIST_VIDEO_HDSDI                   = 43;
PDC.EXIST_RECORDING_TYPE                = 44;
PDC.EXIST_GHOST_REDUCTION               = 45;
PDC.EXIST_SOFT_COLORTEMP                = 46;
PDC.EXIST_AUTO_PLAY                     = 47;
PDC.EXIST_FACTORY_DEFAULTS              = 48;
PDC.EXIST_STORE_PRESET                  = 49;
PDC.EXIST_SHUTTERSPEED_NSEC             = 50;
PDC.EXIST_INSTRUCTIONSET                = 51;
PDC.EXIST_RESOLUTIONLOCK                = 52;
PDC.EXIST_LED_MODE                      = 53;
PDC.EXIST_LIVE_IRIG                     = 54;
PDC.EXIST_VIDEO_OSD                     = 55;
PDC.EXIST_SENSOR_TEMP                   = 56;
PDC.EXIST_SHADING_OFFSET                = 57;
PDC.EXIST_MEMORY_BLOCK                  = 58;
PDC.EXIST_LIVE_RESOLUTION_SCALE         = 59;
PDC.EXIST_FRAME_ADDRESS                 = 60;
PDC.EXIST_DROP_FRAME                    = 61;
PDC.EXIST_TEST_PATERN                   = 62;
PDC.EXIST_OFFSET_AS                     = 63;
PDC.EXIST_H_BANDING                     = 64;
PDC.EXIST_KEYPAD_COMMAND                = 65;
PDC.EXIST_POLARIZATION                  = 66;
PDC.EXIST_SHADING_TYPE                  = 67;
PDC.EXIST_BLACK_CLIP_LEVEL              = 68;
PDC.EXIST_BITDEPTH2                     = 69;
PDC.EXIST_SUB_PORT                      = 70;
PDC.EXIST_SUB_INTERFACE                 = 71;

% Color / Monochrome
PDC.COLORTYPE_MONO                      = 0;
PDC.COLORTYPE_COLOR                     = 1;

% Status
PDC.STATUS_LIVE                         = hex2dec('00');
PDC.STATUS_PLAYBACK                     = hex2dec('01');
PDC.STATUS_RECREADY                     = hex2dec('02');
PDC.STATUS_ENDLESS                      = hex2dec('04');					
PDC.STATUS_REC                          = hex2dec('08');
PDC.STATUS_SAVE                         = hex2dec('10');
PDC.STATUS_LOAD                         = hex2dec('20');

% Trigger mode
PDC.TRIGGER_START                       = bitshift(hex2dec('00'),24);
PDC.TRIGGER_CENTER                      = bitshift(hex2dec('01'),24);
PDC.TRIGGER_END                         = bitshift(hex2dec('02'),24);
PDC.TRIGGER_RANDOM                      = bitshift(hex2dec('03'),24);
PDC.TRIGGER_MANUAL                      = bitshift(hex2dec('04'),24);
PDC.TRIGGER_RANDOM_RESET                = bitshift(hex2dec('05'),24);
PDC.TRIGGER_RANDOM_CENTER               = bitshift(hex2dec('06'),24);
PDC.TRIGGER_RANDOM_MANUAL               = bitshift(hex2dec('07'),24);
PDC.TRIGGER_TWOSTAGE                    = bitshift(hex2dec('08'),24);
PDC.TRIGGER_TWOSTAGE_HALF               = bitor( bitshift(hex2dec('08'),24), 1 );
PDC.TRIGGER_TWOSTAGE_QUARTER            = bitor( bitshift(hex2dec('08'),24), 2 );
PDC.TRIGGER_TWOSTAGE_ONEEIGHTH          = bitor( bitshift(hex2dec('08'),24), 3 );
PDC.TRIGGER_RESET                       = bitshift(hex2dec('09'),24);

% Sensor Gamma
PDC.SENSOR_GAMMA_1_0                    = 1;
PDC.SENSOR_GAMMA_0_9                    = 2;
PDC.SENSOR_GAMMA_0_8                    = 3;
PDC.SENSOR_GAMMA_0_7                    = 4;
PDC.SENSOR_GAMMA_0_6                    = 5;
PDC.SENSOR_GAMMA_0_5                    = 6;
PDC.SENSOR_GAMMA_0_4                    = 7;

% Sensor Gain
PDC.SENSOR_GAIN_X1                      = 1;
PDC.SENSOR_GAIN_X1_5                    = 2;
PDC.SENSOR_GAIN_X2                      = 3;
PDC.SENSOR_GAIN_X3                      = 4;
PDC.SENSOR_GAIN_X4                      = 5;
PDC.SENSOR_GAIN_X6                      = 6;
PDC.SENSOR_GAIN_X8                      = 7;
PDC.SENSOR_GAIN_X12                     = 8;
PDC.SENSOR_GAIN_X16                     = 9;
PDC.SENSOR_GAIN_X24                     = 10;
PDC.SENSOR_GAIN_X32                     = 11;
PDC.SENSOR_GAIN_X64                     = 12;

% Color Temperature	
PDC.COLORTEMP_5100K                     = 1;
PDC.COLORTEMP_3100K                     = 2;
PDC.COLORTEMP_USER1                     = 3;
PDC.COLORTEMP_USER2                     = 4;
PDC.COLORTEMP_USER3                     = 5;
PDC.COLORTEMP_USER4                     = 6;

% Sync Priority
PDC.SYNCPRIORITY_OFF                    = hex2dec('00');
PDC.SYNCPRIORITY_MASTER                 = hex2dec('01');
PDC.SYNCPRIORITY_SLAVE                  = hex2dec('02');

% External Input Signal
PDC.EXT_IN_NONE                         = hex2dec('01');
PDC.EXT_IN_CAMSYNC_POSI                 = hex2dec('02');
PDC.EXT_IN_CAMSYNC_NEGA                 = hex2dec('03');
PDC.EXT_IN_OTHERSSYNC_POSI              = hex2dec('04');
PDC.EXT_IN_OTHERSSYNC_NEGA              = hex2dec('05');
PDC.EXT_IN_EVENT_POSI                   = hex2dec('06');
PDC.EXT_IN_EVENT_NEGA                   = hex2dec('07');
PDC.EXT_IN_TRIGGER_POSI                 = hex2dec('08');
PDC.EXT_IN_TRIGGER_NEGA                 = hex2dec('09');
PDC.EXT_IN_READY_POSI                   = hex2dec('0A');
PDC.EXT_IN_READY_NEGA                   = hex2dec('0B');

% External Output Signal
PDC.EXT_OUT_SYNC_POSI                   = hex2dec('01');
PDC.EXT_OUT_SYNC_NEGA                   = hex2dec('02');
PDC.EXT_OUT_RECORD_POSI                 = hex2dec('03');
PDC.EXT_OUT_RECORD_NEGA                 = hex2dec('04');
PDC.EXT_OUT_TRIGGER_POSI                = hex2dec('05');
PDC.EXT_OUT_TRIGGER_NEGA                = hex2dec('06');
PDC.EXT_OUT_READY_POSI                  = hex2dec('07');
PDC.EXT_OUT_READY_NEGA                  = hex2dec('08');
PDC.EXT_OUT_IRIG_RESET_POSI             = hex2dec('09');
PDC.EXT_OUT_IRIG_RESET_NEGA             = hex2dec('0A');
PDC.EXT_OUT_TTLIN_THRU_POSI             = hex2dec('0B');
PDC.EXT_OUT_TTLIN_THRU_NEGA             = hex2dec('0C');
PDC.EXT_OUT_EXPOSE_POSI                 = hex2dec('0D');
PDC.EXT_OUT_EXPOSE_NEGA                 = hex2dec('0E');
PDC.EXT_OUT_EXPOSE_H1_POSI              = hex2dec('1D');
PDC.EXT_OUT_EXPOSE_H1_NEGA              = hex2dec('1E');
PDC.EXT_OUT_EXPOSE_H2_POSI              = hex2dec('2D');
PDC.EXT_OUT_EXPOSE_H2_NEGA              = hex2dec('2E');
PDC.EXT_OUT_EXPOSE_H3_POSI              = hex2dec('3D');
PDC.EXT_OUT_EXPOSE_H3_NEGA              = hex2dec('3E');
PDC.EXT_OUT_EXPOSE_H4_POSI              = hex2dec('4D');
PDC.EXT_OUT_EXPOSE_H4_NEGA              = hex2dec('4E');
PDC.EXT_OUT_TRIGGER                     = hex2dec('50');
PDC.EXT_OUT_REC_POS_AND_SYNC_POS        = hex2dec('51');
PDC.EXT_OUT_REC_POS_AND_EXPOSE_POS      = hex2dec('52');
PDC.EXT_OUT_ODD_REC_POS_AND_SYNC_POS    = hex2dec('53');
PDC.EXT_OUT_EVEN_REC_POS_AND_SYNC_POS   = hex2dec('54');

PDC.EXTIO_MAX_PORT                      = 4;

% Dualslope Shutter
PDC.DSSHUTTER_OFF                       = hex2dec('01');
PDC.DSSHUTTER_MODE1                     = hex2dec('02');
PDC.DSSHUTTER_MODE2                         = hex2dec('03');
PDC.DSSHUTTER_MODE3                     = hex2dec('04');
PDC.DSSHUTTER_VALUE_STEP5               = hex2dec('11');

% LUT
PDC.LUT_DEFAULT1                        = 1;
PDC.LUT_DEFAULT2                        = 2;
PDC.LUT_DEFAULT3                        = 3;
PDC.LUT_DEFAULT4                        = 4;
PDC.LUT_DEFAULT5                        = 5;
PDC.LUT_DEFAULT6                        = 6;
PDC.LUT_DEFAULT7                        = 7;
PDC.LUT_DEFAULT8                        = 8;
PDC.LUT_DEFAULT9                        = 9;
PDC.LUT_DEFAULT10                       = 10;
PDC.LUT_USER1                           = 11;
PDC.LUT_USER2                           = 12;
PDC.LUT_USER3                           = 13;
PDC.LUT_USER4                           = 14;

% Shading
PDC.SHADING_OFF                         = 1;
PDC.SHADING_ON                          = 2;
PDC.SHADING_SAVE                        = 3;
PDC.SHADING_LOAD                        = 4;
PDC.SHADING_UPDATE                      = 5;
PDC.SHADING_SAVE_FILE                   = 6;
PDC.SHADING_LOAD_FILE                   = 7;

% Shading type
PDC.SHADING_TYPE_NORMAL                 = 0;
PDC.SHADING_TYPE_FINE                   = 1;

% Pixel Gain
PDC.PIXELGAIN_OFF                       = 0;
PDC.PIXELGAIN_NORMAL                    = 1;
PDC.PIXELGAIN_SOFT                      = 2;
PDC.PIXELGAIN_FLAT                      = 3;
PDC.PIXELGAIN_SAVE                      = 4;	% Reserve
PDC.PIXELGAIN_LOAD                      = 5;	% Reserve
PDC.PIXELGAIN_SAVE_FILE                 = 6;
PDC.PIXELGAIN_LOAD_FILE                 = 7;
PDC.PIXELGAIN_NORMAL_64CH               = 8;

% Color Plane
PDC.COLOR_PLANE_R                       = 1;
PDC.COLOR_PLANE_G                       = 2;
PDC.COLOR_PLANE_B                       = 3;

% I.I. Power
PDC.II_POWER_OFF                        = 1;
PDC.II_POWER_ON                         = 2;
PDC.II_POWER_ON_LOAD                    = 3;

% I.I. Gate Select
PDC.II_GATEMODE_OFF                     = 1;
PDC.II_GATEMODE_CONTINUOUS              = 2;
PDC.II_GATEMODE_EXTERNAL                = 3;
PDC.II_GATEMODE_GATING                  = 4;
PDC.II_GATEMODE_DELAY                   = 5;

% Edge Enhancement
PDC.EDGE_ENHANCE_OFF                    = 1;
PDC.EDGE_ENHANCE_MODE1                  = 2;
PDC.EDGE_ENHANCE_MODE2                  = 3;
PDC.EDGE_ENHANCE_MODE3                  = 4;

% Video Output
PDC.VIDEO_OUT_VGA                       = hex2dec('0001');
PDC.VIDEO_OUT_NTSC                      = hex2dec('0002');
PDC.VIDEO_OUT_PAL                       = hex2dec('0003');

% Video Output Signal
PDC.VIDEO_SIGNAL_VBS                    = 0;
PDC.VIDEO_SIGNAL_HDSDI                  = 1;

% HD-SDI Mode
PDC.VIDEO_HDSDI_1080_60I                = 0;
PDC.VIDEO_HDSDI_1080_59_94I             = 1;
PDC.VIDEO_HDSDI_1080_50I                = 2;
PDC.VIDEO_HDSDI_1080_30P                = 3;
PDC.VIDEO_HDSDI_1080_29_97P             = 4;
PDC.VIDEO_HDSDI_1080_25P                = 5;
PDC.VIDEO_HDSDI_1080_24P                = 6;
PDC.VIDEO_HDSDI_1080_23_98P             = 7;
PDC.VIDEO_HDSDI_1080_24SF               = 8;
PDC.VIDEO_HDSDI_1080_23_98SF            = 9;
PDC.VIDEO_HDSDI_720_60P                 = 10;
PDC.VIDEO_HDSDI_720_59_94P              = 11;
PDC.VIDEO_HDSDI_720_50P                 = 12;

% Shutter Mode
PDC.SHUTTERLOCK_MODE1                   = 0;
PDC.SHUTTERLOCK_MODE2                   = 1;

% Resolution Mode
PDC.RESOLUTIONLOCK_MODE1                = 0;
PDC.RESOLUTIONLOCK_MODE2                = 1;

% Partition Mode
PDC.PARTITIONINC_MODE1                  = 0;
PDC.PARTITIONINC_MODE2                  = 1;

% 8bit select
PDC.EIGHTBITSEL_10UPPER                     = 2;
PDC.EIGHTBITSEL_10MIDDLE                    = 1;
PDC.EIGHTBITSEL_10LOWER                     = 0;
PDC.EIGHTBITSEL_12UPPER                     = 4;
PDC.EIGHTBITSEL_12MIDDLE_U                  = 3;
PDC.EIGHTBITSEL_12MIDDLE                    = 2;
PDC.EIGHTBITSEL_12MIDDLE_L                  = 1;
PDC.EIGHTBITSEL_12LOWER                     = 0;
PDC.EIGHTBITSEL_16UPPER                     = 8;
PDC.EIGHTBITSEL_8NORMAL                     = 0;

% Color date tranfer interleave
PDC.COLORDATA_NOCOLOR                   = 0;
PDC.COLORDATA_INTERLEAVE_BGR            = 1;
PDC.COLORDATA_INTERLEAVE_RGB            = 2;

% Gigabit-Ether I/F Parameter
PDC.GETHER_CONNECT_NORMAL               = 1;
PDC.GETHER_CONNECT_LOWSPEED             = 0;
PDC.GETHER_PACKETSIZE_DEFAULT           = 0;
PDC.GETHER_PACKETSIZE_LOWSPEED          = 722;
PDC.GETHER_TIMEOUT_DEFAULT              = 5000;

% Detect mode
PDC.DETECT_NORMAL                       = 0;
PDC.DETECT_AUTO                         = 1;

% Variable pattern num
PDC.VARIABLE_NUM                        = 20;

% Variable Free Position
PDC.VARIABLE_FREE_CENTER_ONLY           = hex2dec('00');
PDC.VARIABLE_FREE_X                     = hex2dec('01');
PDC.VARIABLE_FREE_Y                     = hex2dec('10');

% Signal Delay
PDC.DELAY_TRIGGER_IN                    = 1;
PDC.DELAY_VSYNC_IN                      = 2;
PDC.DELAY_GENERAL_IN                    = 3;
PDC.DELAY_TRIGGER_OUT_WIDTH             = 4;
PDC.DELAY_VSYNC_OUT                     = 5;
PDC.DELAY_VSYNC_OUT_WIDTH               = 6;
PDC.DELAY_EXPOSE                        = 7;

% Download mode
PDC.DOWNLOAD_MODE_VIDEO_ON              = 0;	% Reserve
PDC.DOWNLOAD_MODE_VIDEO_OFF             = 1;	% Reserve
PDC.DOWNLOAD_MODE_PLAYBACK_ON           = 0;
PDC.DOWNLOAD_MODE_PLAYBACK_OFF          = 1;
PDC.DOWNLOAD_MODE_LIVE_ON               = 2;

% Camera mode
PDC.CAM_MODE_DEFAULT                    = 0;
PDC.CAM_MODE_VARIABLE                   = 1;
PDC.CAM_MODE_EXTERNAL                   = 2;

% Programmable Switch mode
PDC.PROGSWITCH_NONE                     = 0;
PDC.PROGSWITCH_RECORDRATE_SEL           = 1;
PDC.PROGSWITCH_RESOLUTION_SEL           = 2;
PDC.PROGSWITCH_SHUTTER_SEL              = 3;
PDC.PROGSWITCH_TRIGGER_MODE_SEL         = 4;
PDC.PROGSWITCH_HEAD_SEL                 = 5;
PDC.PROGSWITCH_FIT                      = 6;
PDC.PROGSWITCH_STATUS                   = 7;
PDC.PROGSWITCH_LIVE                     = 8;
PDC.PROGSWITCH_RECREADY                 = 9;
PDC.PROGSWITCH_REC                      = 10;
PDC.PROGSWITCH_LOWLIGHT                 = 11;
PDC.PROGSWITCH_CALIBRATE                = 12;
PDC.PROGSWITCH_OFF                      = 13;
PDC.PROGSWITCH_OSD                      = 14;

PDC.PROGSWITCH_MAX_NUM                  = 4;

% Color Bayer Convert mode
PDC.BAYERCONVERT_MODE1                  = 0;
PDC.BAYERCONVERT_MODE2                  = 1;
PDC.BAYERCONVERT_MODE3                  = 2;
PDC.BAYERCONVERT_MODE4                  = 3;

% Sync Out Times
PDC.SYNCOUT_TIMES_X1                    = 1;
PDC.SYNCOUT_TIMES_X2                    = 2;
PDC.SYNCOUT_TIMES_X4                    = 4;
PDC.SYNCOUT_TIMES_X6                    = 6;
PDC.SYNCOUT_TIMES_X8                    = 8;
PDC.SYNCOUT_TIMES_X10                   = 10;
PDC.SYNCOUT_TIMES_X20                   = 20;
PDC.SYNCOUT_TIMES_X30                   = 30;
PDC.SYNCOUT_TIMES_X0_5                  = 101;

% Store Preset
PDC.STORE_PRESET_1                      = 1;
PDC.STORE_PRESET_2                      = 2;
PDC.STORE_PRESET_3                      = 3;
PDC.STORE_PRESET_4                      = 4;

% Color Enhancement
PDC.COLOR_ENHANCE_OFF                   = 0;
PDC.COLOR_ENHANCE_X0_5                  = 1;
PDC.COLOR_ENHANCE_X1                    = 2;
PDC.COLOR_ENHANCE_X1_5                  = 3;
PDC.COLOR_ENHANCE_X2                    = 4;

% Ethernet
PDC.ETHER_INFO_IP_ADDRESS               = 0;
PDC.ETHER_INFO_NETMASK                  = 1;
PDC.ETHER_INFO_GATEWAY                  = 2;
PDC.ETHER_INFO_DHCP                     = 3;

% Head Type
PDC.HEADTYPE_MONO                       = 0;
PDC.HEADTYPE_COLOR                      = 1;
PDC.HEADTYPE_II                         = 2;
PDC.HEADTYPE_UNKNOWN                    = hex2dec('FF');

% Auto Play
PDC.AUTOPLAY_OFF                        = 0;
PDC.AUTOPLAY_MEMORY_MODE                = 1;
PDC.AUTOPLAY_ON                         = 2;

% CameraLink
PDC.CAM_STATUS_DEFAULT                  = 0;
PDC.CAM_STATUS_POW_CAB_NOT_CONNECT      = 1;
PDC.CAM_STATUS_CAM_NOT_CONNECT          = 2;
PDC.CAM_STATUS_CL_CONNECT               = 3;
PDC.CAM_STATUS_POCL_CONNECT             = 4;

% Live resolution
PDC.LIVE_RESO_FULL                      = 0;
PDC.LIVE_RESO_HALF                      = 1;
PDC.LIVE_RESO_3                         = 2;
PDC.LIVE_RESO_QUARTER                   = 3;
PDC.LIVE_RESO_5                         = 4;
PDC.LIVE_RESO_6                         = 5;
PDC.LIVE_RESO_7                         = 6;
PDC.LIVE_RESO_DQUARTER                  = 7;

% Baudrate
PDC.BAUDRATE_38400                      = 0;
PDC.BAUDRATE_19200                      = 1;
PDC.BAUDRATE_9600                       = 2;

% AVI Compress dialog
PDC.COMPRESS_DIALOG_HIDE                = 0;
PDC.COMPRESS_DIALOG_SHOW                = 1;

% Recording type
PDC.RECORDING_TYPE_READY_AND_TRIG       = 0;
PDC.RECORDING_TYPE_DIRECT_TRIG          = 1;
PDC.RECORDING_TYPE_DIRECT_START         = 2;

% MCDL Data Mode
PDC.MCDL_DATA_MODE1                     = 0;
PDC.MCDL_DATA_MODE2                     = 1;

% Display Mode with drawing function
PDC.DISPLAY_RESO_FULL                   = 0;
PDC.DISPLAY_RESO_HALF                   = 1;
PDC.DISPLAY_RESO_QUARTER                = 2;

% High Speed Mode
PDC.HIGHSPEED_MODE_NORMAL               = 0;
PDC.HIGHSPEED_MODE_HIGH                 = 1;
PDC.HIGHSPEED_MODE_SUPERHIGH            = 2;

% High Speed Mode List
PDC.HIGHSPEED_NORMAL_150K               = hex2dec('00009600');
PDC.HIGHSPEED_HIGH_675K                 = hex2dec('0002A301');
PDC.HIGHSPEED_SUPERHIGH_775K            = hex2dec('00030702');
PDC.HIGHSPEED_SUPERHIGH_1000K           = hex2dec('0003E802');
PDC.HIGHSPEED_SUPERHIGH_1300K           = hex2dec('00051402');

% Instruction Set
PDC.INSTSET_NONE                        = hex2dec('80000000');
PDC.INSTSET_AUTO                        = hex2dec('40000000');
PDC.INSTSET_MMX                         = hex2dec('00000001');
PDC.INSTSET_SSE2                        = hex2dec('00000002');

PDC.INSTSET_DEFAULT                     = PDC.INSTSET_NONE;	% The initial state of device

% Bayer Alignment
PDC.BAYER_ALIGNMENT_RGGB                = 0;
PDC.BAYER_ALIGNMENT_BGGR                = 1;
PDC.BAYER_ALIGNMENT_GRBG                = 2;
PDC.BAYER_ALIGNMENT_GBRG                = 3;

% Polarization Pattern	*/
PDC.POLARIZATION_PATTERN_1              = 1;
PDC.POLARIZATION_PATTERN_2              = 2;
PDC.POLARIZATION_PATTERN_3              = 3;
PDC.POLARIZATION_PATTERN_4              = 4;

% Degree of Polarizer
PDC.POLARIZER_DEGREE_0                  = 1;
PDC.POLARIZER_DEGREE_45                 = 2;
PDC.POLARIZER_DEGREE_90                 = 3;
PDC.POLARIZER_DEGREE_135                = 4;

% Colormap Index
PDC.POLARIZATION_COLORMAP_180           = 1;
PDC.POLARIZATION_COLORMAP_90            = 2;
PDC.POLARIZATION_COLORMAP_45            = 4;
PDC.POLARIZATION_COLORMAP_30            = 6;

% RESOLUTION_MODE
PDC.RESOLUTION_STANDARD_MODE            = 0;
PDC.RESOLUTION_VALIABLE_MODE            = 1;

% Bit Depth Mode of MRAW File
PDC.MRAW_BITDEPTH_8                     = 0;
PDC.MRAW_BITDEPTH_10                    = 1;
PDC.MRAW_BITDEPTH_12                    = 2;
PDC.MRAW_BITDEPTH_16                    = 3;

% Bit Depth Mode of RAW File
PDC.RAW_BITDEPTH_8                      = 0;
PDC.RAW_BITDEPTH_16                     = 1;

% FrameNumber
PDC.ILLEGAL_FRAME_NUMBER                = hex2dec('FFFFFFFF');     % 0xFFFFFFFFL

% KEYPAD COMMAND
PDC.KEYPAD_COMMAND_FRAMERATE_UP         = 0;
PDC.KEYPAD_COMMAND_FRAMERATE_DOWN       = 1;
PDC.KEYPAD_COMMAND_RESOLUTION_UP        = 2;
PDC.KEYPAD_COMMAND_RESOLUTION_DOWN      = 3;
PDC.KEYPAD_COMMAND_SHUTTER_UP           = 4;
PDC.KEYPAD_COMMAND_SHUTTER_DOWN         = 5;
PDC.KEYPAD_COMMAND_TRIGGER_UP           = 6;
PDC.KEYPAD_COMMAND_TRIGGER_DOWN         = 7;
PDC.KEYPAD_COMMAND_LIVE_MEM             = 8;
PDC.KEYPAD_COMMAND_PLAYBACK_FR          = 9;
PDC.KEYPAD_COMMAND_PLAYBACK_REV         = 10;
PDC.KEYPAD_COMMAND_PLAYBACK_PLAY        = 11;
PDC.KEYPAD_COMMAND_PLAYBACK_FF          = 12;
PDC.KEYPAD_COMMAND_PLAYBACK_PAUSE       = 13;
PDC.KEYPAD_COMMAND_PLAYBACK_STOP        = 14;
PDC.KEYPAD_COMMAND_SEGMENT_START        = 15;
PDC.KEYPAD_COMMAND_SEGMENT_END          = 16;
PDC.KEYPAD_COMMAND_SEGMENT_ON_OFF       = 17;
PDC.KEYPAD_COMMAND_REC_READY            = 18;
PDC.KEYPAD_COMMAND_REC                  = 19;
PDC.KEYPAD_COMMAND_STORE                = 20;
PDC.KEYPAD_COMMAND_MENU                 = 21;
PDC.KEYPAD_COMMAND_ENTER                = 22;
PDC.KEYPAD_COMMAND_ZOOM                 = 23;
PDC.KEYPAD_COMMAND_FIT_SAMESIZE         = 24;
PDC.KEYPAD_COMMAND_ARROW_UP             = 25;
PDC.KEYPAD_COMMAND_ARROW_DOWN           = 26;
PDC.KEYPAD_COMMAND_ARROW_LEFT           = 27;
PDC.KEYPAD_COMMAND_ARROW_RIGHT          = 28;
PDC.KEYPAD_COMMAND_BACK                 = 29;
PDC.KEYPAD_COMMAND_SCROLL               = 30;
PDC.KEYPAD_COMMAND_CALIBRATE            = 31;
PDC.KEYPAD_COMMAND_STATUS               = 32;
PDC.KEYPAD_COMMAND_PRESET1              = 33;
PDC.KEYPAD_COMMAND_PRESET2              = 34;
PDC.KEYPAD_COMMAND_PRESET3              = 35;
PDC.KEYPAD_COMMAND_PRESET4              = 36;
PDC.KEYPAD_COMMAND_FUNCTION             = 37;
PDC.KEYPAD_COMMAND_LOWLIGHT             = 38;

% FPGA CONFIG STATUS
PDC.FPGA_CONFIG_BUFFER_FILE_LOADING     = 0;
PDC.FPGA_CONFIG_ERASING                 = 1;
PDC.FPGA_CONFIG_PROGRAMMING             = 2;
PDC.FPGA_CONFIG_VERIFYING               = 3;

% REGISTER_SETTING_TYPE
PDC.REGISTER_SETTING_MAIN               = 0;
PDC.REGISTER_SETTING_SUB                = 1;
PDC.REGISTER_SETTING_HEAD1              = 2;
PDC.REGISTER_SETTING_HEAD2              = 3;

% RECORD BIT SELECT
PDC.RECBITSEL_8_12UPPER                 = hex2dec('00010000');
PDC.RECBITSEL_8_12MIDDLE_U              = hex2dec('00010001');
PDC.RECBITSEL_8_12MIDDLE                = hex2dec('00010002');
PDC.RECBITSEL_8_12MIDDLE_L              = hex2dec('00010003');
PDC.RECBITSEL_8_12LOWER                 = hex2dec('00010004');


%%% Others

% Flag Code
PDC.FALSE                                   = 0;
PDC.TRUE                                    = 1;

% Ret Code
PDC.FAILED                              = 0;
PDC.SUCCEEDED                           = 1;

















