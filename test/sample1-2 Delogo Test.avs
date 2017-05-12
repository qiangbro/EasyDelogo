Import("../delogo-dependences.avsi")
Import("../delogo-core.avsi")

global MeGUI_darx = 16 global MeGUI_dary = 9

ImageSource("sample1.jpg")
ConvertToYV12()

DelogoTest("LITTLE MAESTRA 1440x1080.lgd",1306,950,76,84)