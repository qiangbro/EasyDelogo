# EasyDelogo Core 1.2

# Delogo����ʵ�ʣ�
#   1. ��EraseLOGOȥ��̨��
#   2. ��logoNR�ֲ�����

# �ص㣺
#   1. �ӿڼ򵥡�
#   2. ���Խ��в��ԣ�����������Ż���΢����
#   3. ���Խ����õ�Ƶ�����������������´ο��ٲ���


# --- Delogo���������÷�˵�� ---
# src ƬԴ
# channel Ƶ��������.lgd��β��logo�����ļ��������ȵ�avs���ڵ��ļ��������������ļ������ڣ��򵽱����ߵ�lgd�ļ���������
# l t r b �����������ꡣ l=����˵ľ��롢t=�����˵ľ��롢r=�������b=����ߡ�������logoscanʰȡ����
# test ���ò���ģʽ
# �͸�EraseLOGO�� int "pos_x", int "pos_y", int "depth", int "yc_y", int "yc_u", int "yc_v",
#                int "start", int "fadein", int "fadeout", int "end", bool "interlaced"  
# �͸�logoNR�� bool "chroma", bool "GPU", int "l", int "t", int "r", int "b", string "nr"


# REQUIREMENTS:
# avisynth+, delogo.dll, logoNR_v0.1.avsi


#
#   ����ѧϰ�о�������Ƿ����ü��ֺ�����Ȩ�档
#
#   mikey@�д廨����Ļ��
#   last modified: 2017.05.12
#

global __DELOGO_DIR = ScriptDir()
global __DELOGO_DATA = StrStrMap_New()


# StrStrMap ���ݽṹͬJava�е�java.util.Map<java.lang.String,java.lang.String>
# ��avisynth�У���string��Ϊ�������壬�ṹ����
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


#ȫ��ע��logo����
function DelogoReg(string channel, string lgd, int l, int t, int r, int b)
{
    if (StrLen(channel)>4 && channel.RightStr(4).LCase()==".lgd") {
        Assert(false, "Sorry, I can not register this Channel: "+ channel)
    }
    evalcode = """lgd=""""+lgd+"""" _l="""+String(l)+" _t="+String(t)+" _r="+String(r)+" _b="+String(b)
    global __DELOGO_DATA = __DELOGO_DATA.StrStrMap_Put(channel, evalcode)
}


#ȥ��logo
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

    #����ʹ��ԭlgd·��������Ҳ����ŵ�__DELOGO_DIR\lgd\��Ѱ�ҡ�
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
        #����չʾ��̨�������ȥ̨�ꡢ����ǰ���Ӱ���Թ��Ա�Ч��
        src_crop = src.Crop(l, t, r, b).Subtitle("src",size=10,font="����",x=2)
        dlg_crop = dlg.Crop(l, t, r, b).Subtitle("dlg",size=10,font="����",x=2)
        denoise_crop = denoise.Crop(l, t, r, b).Subtitle("dlg&denoise",size=10,font="����",x=2)
        
        StackHorizontal(src_crop, dlg_crop, denoise_crop)
        Subtitle(string(l)+" "+string(t)+" "+string(r)+" "+string(b),size=10,font="����",x=2,y=10)
        
        return last
    } else {
        return denoise
    }


}


#�Ա�ȥ��logo֮ǰ֮���Ч��
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
