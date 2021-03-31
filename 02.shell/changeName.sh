#! /bin/bash
set -e ## 报错打断，防止一直错下去
## 帮助内容
func(){
    echo "Usage:"
    echo "changName.sh [-c conf] [-s string] [-r replace] [-b backup] "
    echo "Description"
    echo "[-c]:conf,    The file name list in one config file, one file per line"
    echo "[-s]:string,  The string in your file name you want to remove"
    echo "[-r]:replace,     The string in your file name you want to add"
    echo "[-b]:backup,  Do you want backup for you original files?"
    exit -1
}
## 是否备份原始文件，如果不写-b默认不备份
backup="no"
## 设置各个参数
while getopts 'h:c:s:r:b' OPT;
do
    case $OPT in
        c) conf="$OPTARG";;
        s) string=`echo "$OPTARG"`;;
        b) backup="yes";;
        r) replace=`echo "$OPTARG"`;;
        h) func;;
        ?) func;;
    esac
done
## 提示你的参数设置
echo "Your setting:"
echo "The strings you want remove:" ${string}
echo "The strings you want to replace the removed strings:" ${replace}
echo "The original file was retained:" ${backup}
while read id
do
    file=$(basename $id) 
    old=`echo $file` ## 这里要提取的是字符，echo你上面文件名赋值的结果就是stirng
    new=`echo $old | gsed "s/$string/${replace}/g"` ## 你改后的文件名 linux的话把gsed改成sed，如果sed中有变量的话需要双引号
    echo "The old filename" "##"$old"##" "has been replaced as" "##"$new"##"
    ## 执行
    if [[ $backup == "yes" ]]; then
        #do not backup
        cp ${file} ${new}; else
        #backup
        mv ${file} ${new}
    fi
done<$conf