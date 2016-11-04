#!/bin/sh

# 设置 开发，或者发布的根证书全名
Code_Sign_Identity="iPhone Distribution: App Channel Limited"
profile_name="AppChannel In-house 2016"
Configuration="Release"
SDK="iphoneos"

current_path=`pwd`
echo $current_path

xcworkspace_path=`find . -maxdepth 1 -name '*.xcworkspace'`
echo "find '*.xcworkspace' file path ==> $xcworkspace_path"

if [ ! -n "$xcworkspace_path" ]
then echo "find no '*.xcworkspace' file."
else xcworkspace_filename=`basename $xcworkspace_path .xcworkspace`
echo "get '*.xcworkspace' file name ==> $xcworkspace_filename"
fi

if [ ! -n "$xcworkspace_filename" ]
then echo "cannot get '*.xcworkspace' file name."
else
#find ~/Library/Developer/Xcode/DerivedData -name "${xcworkspace_filename}.appex" | xargs -I % find % -type f -maxdepth 1 | xargs rm
#archive project
xctool -workspace $xcworkspace_path -scheme $xcworkspace_filename -configuration ${Configuration} clean
echo "start archiving"
now_date=`date +%Y%m%d_%H%M%S`
#echo $now_date
target_filepath="./build/"${xcworkspace_filename}_${now_date}".xcarchive archive"
target_filepurepath="./build/"${xcworkspace_filename}_${now_date}".xcarchive"
#xcodebuild -workspace $xcworkspace_path -scheme $xcworkspace_filename -configuration $Configuration -sdk $SDK CODE_SIGN_IDENTITY="$Code_Sign_Identity" -archivePath build/"${xcworkspace_filename}_${now_date}".xcarchive archive
xctool -workspace $xcworkspace_path -scheme $xcworkspace_filename -configuration ${Configuration} archive -archivePath build/"${xcworkspace_filename}_${now_date}".xcarchive
fi

if [ ! -f $target_filepath ]
then echo "archive target path ==> $target_filepath has no file exist"
echo "script interrupted"
else echo "find target archive file in target path ==> $target_filepath"

while true
do

read -t 60 -p "to generate the .ipa file frome archive directory? [Y/N] " answerAction

case $answerAction in
Y|y)
    echo "ready to generate ipa file"
    read -p "input message to remark the ipa file, the message will add to the end of filename with format <xcworkspace_filename>_<now_date>_<your_message>.ipa: " your_message
    if [ ! -n "$your_message" ]
    then xcodebuild  -exportArchive -exportFormat IPA -archivePath $target_filepath -exportPath ./build/"${xcworkspace_filename}_${now_date}".ipa -exportProvisioningProfile "${profile_name}"
#    then /usr/bin/xcrun -sdk $SDK PackageApplication -v "${target_filepurepath}/Products/Applications/${xcworkspace_filename}.app" -o ${xcworkspace_filename}.ipa
    break
    else xcodebuild  -exportArchive -exportFormat IPA -archivePath $target_filepath -exportPath ./build/"${xcworkspace_filename}_${now_date}_${your_message}".ipa -exportProvisioningProfile "${profile_name}"
#    else /usr/bin/xcrun -sdk $SDK PackageApplication -v "${target_filepurepath}/Products/Applications/${xcworkspace_filename}.app" -o ./build/"${xcworkspace_filename}_${now_date}_${your_message}".ipa
    break
    fi
    ;;
N|n)
    echo "script complete"
    break
    ;;
"")
    echo "time out, defaultly generate ipa"
    xcodebuild  -exportArchive -exportFormat IPA -archivePath $target_filepath -exportPath ./build/"${xcworkspace_filename}_${now_date}".ipa -exportProvisioningProfile "${profile_name}"
#    /usr/bin/xcrun -sdk $SDK PackageApplication -v "${target_filepurepath}/Products/Applications/${xcworkspace_filename}.app" -o ./build/"${xcworkspace_filename}_${now_date}".ipa
    break
    ;;
*)
    echo "error choice"
    ;;
esac

done

fi









