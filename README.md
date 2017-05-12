# EasyDelogo

EasyDelogo Kit 核心模块 — Core。

至于这东西是做什么用的，嗯，实质就是先EraseLOGO然后logoNR一条龙。

仅供学习研究，请勿非法滥用及侵害他人权益。

mikey@有村花纯字幕组


# 用例及代码示例：
导入

    Import("EasyDelogo\delogo-dependences.avsi")
    Import("EasyDelogo\delogo-core.avsi")

CASE1：使用lgd文件去除logo

    Delogo("Fuji 1440x1080.lgd", 1292,56,-76,-928)
    
CASE2：测试去台标区域的效果，以便更好地优化lgd文件以及参数

    DelogoTest("Fuji 1440x1080.lgd", 1292,56,-76,-928)

CASE3：先注册logo数据，之后轻松部署

在脚本最前面使用DelogoReg函数进行注册：

    DelogoReg("CX", "Fuji 1440x1080.lgd", 1292,56,-76,-928)
    
此后你的脚本中只需这样写：

    Delogo("CX")



# REQUIREMENTS
avisynth+, delogo.dll, FFT3DFilter, MaskTools2, RgTools, logoNR_v0.1.avsi
