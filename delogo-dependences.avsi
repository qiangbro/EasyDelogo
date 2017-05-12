# EasyDelogo Dependences 1.2

# REQUIREMENTS:
# avisynth+, delogo.dll, FFT3DFilter, MaskTools2, RgTools, logoNR_v0.1.avsi


global __DELOGO_DEPENDENCE_PATH = ScriptDir() + "\dependences"

if (FindStr(VersionString(), "x86_64") != 0) {

    if (!FunctionExists("EraseLOGO")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\delogo_avs+\x64\delogo.dll")
    }
    if (!FunctionExists("FFT3DFilter")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\fft3dfilter_64\fft3dfilter.dll")
    }
    if (!FunctionExists("mt_merge")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\masktools2-v2.2.8\x64\masktools2.dll")
    }
    if (!FunctionExists("RemoveGrain")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\RgTools-0.95\x64\RgTools.dll")
    }

} else {
 
    if (!FunctionExists("EraseLOGO")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\delogo_avs+\x86_ICC\delogo.dll")
    }
    if (!FunctionExists("FFT3DFilter")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\FFT3DFilter-v2.1.1_VitMod\fft3dfilter.dll")
    }
    if (!FunctionExists("mt_merge")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\masktools2-v2.2.8\x86\masktools2.dll")
    }
    if (!FunctionExists("RemoveGrain")) {
        LoadPlugin  (__DELOGO_DEPENDENCE_PATH + "\RgTools-0.95\x86\RgTools.dll")
    }

}

if (!FunctionExists("logoNR")) {
    Import      (__DELOGO_DEPENDENCE_PATH + "\logoNR_v0.1.avsi")
}





