# EasyDelogo Core 1.2

# Delogo函数实质：
#   1. 用EraseLOGO去除台标
#   2. 用logoNR局部降噪

# 特点：
#   1. 接口简单。
#   2. 可以进行测试，方便参数的优化和微调。
#   3. 可以将常用的频道数据整理起来，下次快速部署。


# --- Delogo函数参数用法说明 ---
# src 片源
# channel 频道名或以.lgd结尾的logo样本文件名。会先到avs所在的文件夹中搜索，若文件不存在，则到本工具的lgd文件夹中搜索
# l t r b 降噪区域坐标。 l=至左端的距离、t=至顶端的距离、r=区域宽、b=区域高。可以用logoscan拾取坐标
# test 启用测试模式
# 送给EraseLOGO： int "pos_x", int "pos_y", int "depth", int "yc_y", int "yc_u", int "yc_v",
#                int "start", int "fadein", int "fadeout", int "end", bool "interlaced"  
# 送给logoNR： bool "chroma", bool "GPU", int "l", int "t", int "r", int "b", string "nr"


# REQUIREMENTS:
# avisynth+, delogo.dll, logoNR_v0.1.avsi


#
#   仅供学习研究，请勿非法滥用及侵害他人权益。
#
#   mikey@有村花纯字幕组
#   last modified: 2017.05.12
#

global __DELOGO_DIR = ScriptDir()
global __DELOGO_DATA = StrStrMap_New()


# StrStrMap 数据结构同Java中的java.util.Map<java.lang.String,java.lang.String>
# 在avisynth中，用string作为数据载体，结构如下
# ([[key1]])-->([[value1]])([[key2]])-->([[value2]])

function StrStrMap_New() {
    return ""
}

function StrStrMap_Put(string map, string key, string value) {
    Assert(key.FindStr("([[")==0 && key.FindStr("]])")==0, "Don't push strange thing into StrStrMap.")
    return "([["+key+"]])-->([["+value+"]])" + map
}

function StrStrMap_Get(string map, string key) {

    search_key = "([["+key+"]])-->([["
    find_str = map.FindStr(search_key)
    
    if (find_str == 0 ) { return undefined }
    
    skipLeft = find_str-1 + search_key.StrLen()
    skipLeftStr = map.RightStr(map.StrLen() - skipLeft)
    
    find_str2 = skipLeftStr.FindStr("]])")
    Assert(find_str2 > 0 , "internal error. ]]) not found in map data.")
    
    content_len = find_str2-1
    content = skipLeftStr.LeftStr(content_len)
    
    return content
}


#全局注册logo数据
function DelogoReg(string channel, string lgd, int l, int t, int r, int b)
{
    if (StrLen(channel)>4 && channel.RightStr(4).LCase()==".lgd") {
        Assert(false, "Sorry, I can not register this Channel: "+ channel)
    }
    evalcode = """lgd=""""+lgd+"""" _l="""+String(l)+" _t="+String(t)+" _r="+String(r)+" _b="+String(b)
    global __DELOGO_DATA = __DELOGO_DATA.StrStrMap_Put(channel, evalcode)
}


#去除logo
function Delogo(clip src,
\   string channel, int "l", int "t", int "r", int "b",
\   int "pos_x", int "pos_y", int "depth", int "yc_y", int "yc_u", int "yc_v",
\   int "start", int "fadein", int "fadeout", int "end", bool "interlaced",
\   bool "chroma", bool "GPU", string "nr",
\   bool "test")
{

    lgd="" ch=""
    
    if (StrLen(channel)>4 && channel.RightStr(4).LCase()==".lgd") { lgd = channel }
    else { ch=channel }

    if(ch != "") {

        evalcode = __DELOGO_DATA.StrStrMap_Get(ch)
        Assert(Defined(evalcode), "Unknown Channal : " + ch)
        
        Eval(evalcode)
        
        l = Default(l, _l)
        t = Default(t, _t)
        r = Default(r, _r)
        b = Default(b, _b)
        
    }

    #优先使用原lgd路径，如果找不到才到__DELOGO_DIR\lgd\中寻找。
    lgd_path = Exist(lgd) ? lgd : __DELOGO_DIR + "\lgd\" + lgd
    
    Assert(Exist(lgd_path), "lgd file not exists!?")

    l = Default(l, 0)
    t = Default(t, 0)
    r = Default(r, 0)
    b = Default(b, 0)

    dlg = EraseLOGO(src, lgd_path, pos_x=pos_x,pos_y=pos_y,depth=depth,yc_y=yc_y,yc_u=yc_u,yc_v=yc_v,
    \                   start=start,fadein=fadein,fadeout=fadeout,end=end,interlaced=interlaced)

    denoise = logoNR(dlg, src, l=l,t=t,r=r,b=b,nr=nr,chroma=chroma, GPU=Default(GPU, false))


    if (Default(test, false)) {
        #并排展示出台标区域的去台标、降噪前后的影像，以供对比效果
        src_crop = src.Crop(l, t, r, b).Subtitle("src",size=10,font="宋体",x=2)
        dlg_crop = dlg.Crop(l, t, r, b).Subtitle("dlg",size=10,font="宋体",x=2)
        denoise_crop = denoise.Crop(l, t, r, b).Subtitle("dlg&denoise",size=10,font="宋体",x=2)
        
        StackHorizontal(src_crop, dlg_crop, denoise_crop)
        Subtitle(string(l)+" "+string(t)+" "+string(r)+" "+string(b),size=10,font="宋体",x=2,y=10)
        
        return last
    } else {
        return denoise
    }


}


#对比去除logo之前之后的效果
function DelogoTest(clip src,
\   string channel, int "l", int "t", int "r", int "b",
\   int "pos_x", int "pos_y", int "depth", int "yc_y", int "yc_u", int "yc_v",
\   int "start", int "fadein", int "fadeout", int "end", bool "interlaced",
\   bool "chroma", bool "GPU", string "nr")
{

    Delogo(src,
\   channel, l=l,t=t,r=r,b=b, 
\   pos_x=pos_x,pos_y=pos_y,depth=depth,yc_y=yc_y,yc_u=yc_u,yc_v=yc_v,
\   start=start,fadein=fadein,fadeout=fadeout,end=end,interlaced=interlaced,
\   chroma=chroma, GPU=GPU, nr=nr,
\   test=true)

}

