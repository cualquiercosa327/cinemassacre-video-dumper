#!/bin/bash


# Cinemassacre Video Dumper v0.8
# esc0rtd3w 2014 / crackacademy.com


#-------------------------------------------------------------
# Version History

# v0.8
# - Removed the pause commands for .m4v links that were used for debugging.

# v0.7
# - Fixed Player.php links.
# - Added support for VOD links.
# - Added VOD to the list of hooks.

# v0.6
# --------
# - Increased default terminal screen size.
# - Added option to open cinemassacre.com website on navbar. Uses firefox as default browser.
# - Added support for gametrailers.com.

# v0.5
# --------
# - Changed default save name to match video name in URL.

# v0.4
# --------
# - Added support for blip.tv links.
# - Added support for player.php redirects.

# v0.3
# --------
# - Video ID's are now automatically parsed no matter the length of the number.
# - Temporarily using JWPlayer as the default hook for direct linking. Will change to auto soon.

# v0.2
# --------
# - Changed the default video name to be capture-$videoID when no name is entered to save.
# -------------------------------------------------------------


#-------------------------------------------------------------

# TO DO LIST

# - Add help and switches for terminal

# - Get length of filename to verify it matches when downloaded

# - Auto add name to default capture file

# - Pull child URL's from a parent page

# - Add navigation to exit and return to main menu

# - Add documentation when ran with --help

# - Allow the 1st argument to be appended to terminal string and avoid menu
#   Example: ./cinemassacre-video-dumper "http://cinemassacre.com/2013/09/06/avgn-tiger-electronic/"
#   The above example would download the Tiger Electronic video using default settings

# - Allow additional arguments to be interpreted, such as save file name
#   Example: ./cinemassacre-video-dumper "http://cinemassacre.com/2013/09/06/avgn-tiger-electronic/" "AVGN 113 - Tiger Electronic Games.mp4"


# Links currently not working
# http://cinemassacre.com/2011/05/31/tmnt-tuesday-top-20-turtle-flubs/

#-------------------------------------------------------------



# Find main playlist in script example:
# http://206.217.201.108/Cinemassacre/smil:Cinemassacre-24611.smil/playlist.m3u8


# Direct MP4 Links
# http://player.screenwavemedia.com/play/jwplayer/Cinemassacre-24611.mp4
# http://player.screenwavemedia.com/play/jwplayer/Cinemassacre-24611_high.mp4


# HTML source hook
# div class="videoarea"





resizeWindow()
{

printf '\033[8;33;88t'

}


setWindowTitle(){

title='echo -ne "\033]0;Cinemassacre Video Dumper v0.8 / esc0rtd3w 2014 / crackacademy.com\007"'

$title


#case $TERM in
#    xterm*)
#        PS1="\[\033]0;\u@\h: \w\007\]bash\\$ "
#        ;;
#    *)
#        PS1="bash\\$ "
#        ;;
#esac

}


setVariables(){

# Default adjustable hook
hook="0"

# Other hooks that can be used
hookEmbed="http://player.screenwavemedia.com/play/embed.php?id="
hookPlayer="http://player.screenwavemedia.com/play/player.php?id=Cinemassacre-"
hookPlayer2="http://player.screenwavemedia.com/play/Cinemassacre-"
hookPlaylist="/Cinemassacre/smil:Cinemassacre-"
hookJWPlayer="http://player.screenwavemedia.com/play/jwplayer/Cinemassacre-"

hookVOD="http://video2.screenwavemedia.com/vod/Cinemassacre-"


# New hook example: <div class="videoarea"><iframe src="http://blip.tv/play/AYH5pQIA.x?p=1"
hookBlipTV="http://blip.tv/play/"


# Child hook for Blip.tv
# This is pulled from the HTML source after following the blip.tv/play/ redirect
# Example: data-blipsd="http://blip.tv/file/get/Cinemassacre-015ChronologicallyConfused525.m4v"
hookBlipTV2="http://blip.tv/file/get/Cinemassacre-"

# Another Blip.tv hook
# Sample: http://j16.video2.blip.tv/10130007978101/Cinemassacre-Top20TurtleFlubs873.m4v?ir=43177&sr=3637
hookBlipTV3="/Cinemassacre-"


# Old Blip.tv Hook
# Example ID following hash symbol: AYH5pQIA
#hookBlipTV="http://a.blip.tv/api.swf#"

# Youtube Example: //www.youtube.com/embed/U7jWweLS47Y
hookYoutube="//www.youtube.com/embed/"

# Used for "EMBED" mode, can also be watched, just fills viewing area in browser
hookYoutube2="http://www.youtube.com/embed/"

# Used for normal "WATCHING" mode
hookYoutube3="http://www.youtube.com/watch?v="


# GameTrailers.com Hooks
hookGameTrailers="http://www.gametrailers.com/videos/"

# http://media.mtvnservices.com/fb/mgid:arc:video:gametrailers.com:db2b0e67-9546-421b-b57d-227c7f23c8ac.swf
hookGameTrailers2="http://media.mtvnservices.com/fb/mgid:arc:video:gametrailers.com:"

# http://media.mtvnservices.com/player/prime/mediaplayerprime.2.5.7.swf?uri=mgid:arc:video:gametrailers.com:db2b0e67-9546-421b-b57d-227c7f23c8ac&type=normal&ref=None&geo=US&group=entertainment&network=None&device=Other&CONFIG_URL=http%3a%2f%2fmedia.mtvnservices.com%2fpmt%2fe1%2fplayers%2fmgid%3aarc%3avideo%3agametrailers.com%3a%2fcontext11%2fconfig.xml%3furi%3dmgid%3aarc%3avideo%3agametrailers.com%3adb2b0e67-9546-421b-b57d-227c7f23c8ac%26type%3dnormal%26ref%3dNone%26geo%3dUS%26group%3dentertainment%26network%3dNone%26device%3dOther
hookGameTrailers3="http://media.mtvnservices.com/player/prime/mediaplayerprime.2.5.7.swf?uri=mgid:arc:video:gametrailers.com:"


ext="mp4"
extBlipTV="m4v"
extPlayer="mp4"
extYoutube=""
extGameTrailers="swf"

# This is for high quality setting. Variable can be BLANKED for normal quality
highToggle="_high"

}



banner(){

setWindowTitle

clear
echo "---------------------------------------------------------------------------------------"
echo "Cinemassacre Video Dumper v0.8 / esc0rtd3w 2014 / crackacademy.com"
echo "---------------------------------------------------------------------------------------"
#echo ""

#echo "                   ZDND"                                                                             
#echo "               -MNNDNND8OD"                                                                      
#echo "             DNNtZNNDZDD8OD"                                                                         
#echo "           7NNNNNNN08O-D8DD"                                                                         
#echo "           NNNNDN7IO-tDDDZN"   -I          -                                                         
#echo "           NDN7tNNNDDD888NtItDtItIItt--I-DN"                                                         
#echo "           NNNNNNNNDD8DNZMMD --N7       tDN    7   I-  NO  -  0"                                     
#echo "           INNN7Nt8DDNNDZO88ZZNZZ88OOONNDOO88ZOZZZZMOZDDZMZDDOZOOD00ZZZZOD7OMOOO80078Z"            
#echo "            NNNDN Cinemassacre Video Dumper v0.6 / esc0rtd3w 2013 / crackacademy.com ZZ"             
#echo "            I   DDNNNNND8ODNZOOOMOZZ88ZOMND8ZM8MOM88OOOZ8OZZZZZZ0ZMOM0D00NOZOONOM07ZZZN8"            
#echo "           ---D7DNDDDODOtODMIZOZMZNZZNZZMND8DOODZMOMOZMZNOZMZ00ODO008Z80ZMZM0ZMOO0708ZD7"            
#echo "            7    D-DN8NDDI0ZZMNOMOMD8MOOOMDDD8D88888OONOOONZZ8OMZD007N0NM70D70NO8077000D"            
#echo "                 88O0Z7DNNNNDDNZDN -M88NDNDOOZO07Z0ZZ8D8DNDDO8OZD8D8DD8OO0OOO8D8ZZ7088"              
#echo "                      D78D t   I-D      INI"                                 -                       
#echo "                      DD7Dt    I                                           Z  -M Z NDDD"             
#echo "                      DD7DZ                                                O - O O MZ D"             
#echo "                      Ot-tO"                                                                         
#echo "                     O-8NND"                                                                         
#echo "                       O8Dt" 

}


betaHeader(){

echo "************************************************"
echo "*     HIDDEN MENU / CURRENTLY IN TESTING       *"
echo "************************************************"
echo ""

}


navbar(){

echo "---------------------------------------------------------------------------------------"
echo "(H) Change Hook  | (E) Change Extension  | (W) Open Main Webpage  | (X) Exit"
echo "---------------------------------------------------------------------------------------"
echo ""

}


setDefaults(){


url=""
hook="$hookEmbed"
highToggle="_high"
ext="mp4"

}



doWork(){

cleanTemp

setVariables

setDefaults

getURL


}



getURL(){

banner
navbar

echo ""
echo ""
echo "Current Hook: $hook"
echo ""
echo "Current Extension: $ext"
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Enter the target URL and press ENTER:"
echo ""
echo "DRAG & DROP IS SUPPORTED (DROP VIDEO THUMBNAIL HERE)"
echo ""
echo "Example: http://cinemassacre.com/2006/10/02/double-dragon-3/"
echo ""
echo ""


read getNewURL


case "$getNewURL" in

"")
getURL
;;

"w" | "W")
openWebSite
getURL
;;

"h" | "H")
setHook
;;

"e" | "E")
setExtension
;;

"x" | "X")
exit
;;

"a" | "A")
getAVGNList
;;

"v" | "V")
setVideoID
;;

"r" | "R")
doWork
;;

*)
url=$(echo "$getNewURL")

dumpHTML
;;

esac


}


openWebSite(){

firefox "http://www.cinemassacre.com" &

}


dumpHTML(){

cleanTemp

getRawHTML=$(wget $url)

parseHTML=$(filename='index.html'
filelines=`cat $filename`
for line in $filelines ; do
    echo $line
done)

getVideoID

buildDirectLink

getNewFilename

doWork

}


checkVideoType(){

#echo "THIS IS checkVideoType LANDING"
#read pause

#echo "$videoIDPreview"
#read pause

# Temporarily forcing BlipTV as source if videoID is BLANK and directed here
setTypeAsBlipTV

}


setTypeAsBlipTV(){

# Needs some work (check SnesVsSega) for multiple Video IDs

#echo "I AM setTypeAsBlipTV"
#read pause

getBlipTVRedirect=$(echo "$parseHTML" | grep -e "$hookBlipTV")

# If Blip.tv redirect returns BLANK then check for PLAYER type
case "$getBlipTVRedirect" in

"")
# Using VOD as new Player default 20140928
#setTypeAsVOD
setTypeAsPlayer
;;

*)
hook="$hookBlipTV2"
highToggle=""
ext="$extBlipTV"


setBlipTVRedirect=$(echo "$getBlipTVRedirect" | cut -d "\"" -f2 | cut -d "\"" -f1)

echo "setBlipTVRedirect: $setBlipTVRedirect"
#read pause

getNewHTML=$(wget -O index.html $setBlipTVRedirect)

# Check for Blank Blip parsing
case "$getNewHTML" in
 
"")
#echo "parseHTML: $parseHTML"
#read pause
getBlipTVRedirect=$(echo "$parseHTML" | grep -e "$hookBlipTV3")
echo "getBlipTVRedirect: $getBlipTVRedirect"
#read pause
;;

esac


parseNewHTML=$(filename='index.html'
filelines=`cat $filename`
for line in $filelines ; do
    echo $line
done)

#echo "$parseNewHTML"
#read pause

videoIDPreview=$(echo "$parseNewHTML" | grep -e "$hookBlipTV2" | sort -u)

#echo "videoIDPreview: $videoIDPreview"
#read pause

videoIDPreview2=$(echo "$videoIDPreview" | cut -d "-" -f3 | cut -d "\"" -f1)

#echo "videoIDPreview2: $videoIDPreview2"
#read pause


videoID=$(echo "$videoIDPreview2" | cut -d "." -f1)

echo "videoID: $videoID"
#read pause


;;

esac

cleanTemp

}


setTypeAsPlayer(){

#echo "I AM setTypeAsPlayer"
#read pause

videoIDPreview=$(echo "$parseHTML" | grep -e "$hookPlayer")

#echo "videoIDPreview: $videoIDPreview"
#read pause


# If Player redirect returns BLANK then check for VOD type
case "$videoIDPreview" in

"")
setTypeAsVOD
;;

*)
videoIDPreview2=$(echo "$videoIDPreview" | cut -d "-" -f2)

#echo "videoIDPreview2: $videoIDPreview2"
#read pause


videoID=$(echo "$videoIDPreview2" | cut -d "\"" -f1)

#echo "videoID: $videoID"
#read pause


# Temp VOD link fix 20140928
hook="$hookVOD"
highToggle="_high"


#hook="$hookPlayer2"

# The BLANK setting here actually downloads the HIGHEST QUALITY
#highToggle=""
# Set the hd1 highToggle for NORMAL QUALITY
#highToggle="_hd1"
ext="$extPlayer"
;;

esac

cleanTemp

}


setTypeAsVOD(){

#echo "I AM setTypeAsVOD"
#read pause

videoIDPreview=$(echo "$parseHTML" | grep -e "$hookVOD")

#echo "videoIDPreview: $videoIDPreview"
#read pause


# If Player redirect returns BLANK then check for Youtube type
case "$videoIDPreview" in

"")
setTypeAsYoutube
;;

*)
videoIDPreview2=$(echo "$videoIDPreview" | cut -d "-" -f2)

#echo "videoIDPreview2: $videoIDPreview2"
#read pause


videoID=$(echo "$videoIDPreview2" | cut -d "\"" -f1)

#echo "videoID: $videoID"
#read pause

hook="$hookVOD"

# http://video2.screenwavemedia.com/vod/cinemassacre-53100fa8e149f_hd1.mp4
# http://video2.screenwavemedia.com/vod/Cinemassacre-53100fa8e149f_high.mp4


# New VOD HIGH toggle 20140928
highToggle="_high"

ext="$extPlayer"
;;

esac

cleanTemp

}


setTypeAsYoutube(){

#echo "I AM setTypeAsYoutube"
#read pause

videoIDPreview=$(echo "$parseHTML" | grep -e "$hookYoutube")

#echo "videoIDPreview: $videoIDPreview"
#read pause

# If Youtube redirect returns BLANK then check for GameTrailers type
case "$videoIDPreview" in

"")
setTypeAsGameTrailers
;;

*)

videoIDPreview2=$(echo "$videoIDPreview" | cut -d "=" -f2)

#echo "videoIDPreview2: $videoIDPreview2"
#read pause


videoIDPreview3=$(echo "$videoIDPreview2" | cut -d "\"" -f2)

#echo "videoIDPreview3: $videoIDPreview3"
#read pause

setYoutubeRedirect=$(echo "$videoIDPreview3" | cut -c 3-)

#echo "setYoutubeRedirect: $setYoutubeRedirect"
#read pause

videoID=$(echo "$setYoutubeRedirect" | cut -d "/" -f3)

#echo "videoID: $videoID"
#read pause

hook="$hookYoutube2"
highToggle=""
ext="$extYoutube"

# Sample link from ID U7jWweLS47Y
# http://r4---sn-c0j3xtxj5caxntnuxh-uvae.c.youtube.com/videoplayback?ip=72.241.194.149&sver=3&mt=1380855662&fexp=919111%2C929116%2C924397%2C900377%2C916626%2C912310%2C924606%2C924616%2C916914%2C929117%2C929121%2C929906%2C929907%2C929922%2C929923%2C929127%2C929129%2C929131%2C929930%2C936403%2C925724%2C925726%2C936310%2C925720%2C925722%2C925718%2C936401%2C925714%2C929917%2C906945%2C929933%2C929935%2C929937%2C929939%2C939602%2C939604%2C912909%2C937102%2C906842%2C927704%2C913428%2C912715%2C919811%2C939908%2C935704%2C932309%2C913563%2C919373%2C930803%2C908538%2C931924%2C938608%2C940501%2C936308%2C924416%2C939201%2C900816%2C912711%2C916304%2C900391%2C934507%2C907231%2C936312%2C906001&sparams=cp%2Cid%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cupn%2Cexpire&upn=0uxhGMI8W_Q&itag=45&ipbits=8&ms=au&cp=U0hXRVhTT19NT0NON19QTVNIOnNKNDNhVHoyT3Ja&mv=m&id=53b8d6c1e2d2e3b6&expire=1380881785&source=youtube&ratebypass=yes&key=yt1&signature=C13816FA2A49403F827D9BCCC61FCF942F25B275.9BC4DC256DD3218A93E55F5A7C211CF977F6B8C4

;;

esac

cleanTemp

}


setTypeAsGameTrailers(){

# Final links for video files are separated in segments and fragments, "_Seg1-Frag1", "_Seg1-Frag2", "_Seg1-Frag3", etc
# Example: http://cp141527-f.akamaihd.net/z/mtvnorigin/gsp.gtcomstor/media/videos_root/games/2012/10_oct_2012/oct_02/gt_angryvideogamenerd_mariokart_10-2_9am_,384x216_400_m30,512x288_750_m30,640x360_1200_m30,768x432_1700_m30,960x540_2200_m31,1280x720_3500_h32,.mp4.csmil/5_19ac4d491726a836_Seg1-Frag1

#echo "I AM setTypeAsGameTrailers"
#read pause

videoIDPreview=$(echo "$parseHTML" | grep -e "$hookGameTrailers")

#echo "videoIDPreview: $videoIDPreview"
#read pause


videoIDPreview2=$(echo "$videoIDPreview" | cut -d "\"" -f2 | sort -u)

#echo "videoIDPreview2: $videoIDPreview2"
#read pause


videoIDPreview3=$(echo "$videoIDPreview2" | cut -d "/" -f5)

#echo "videoIDPreview3: $videoIDPreview3"
#read pause


videoLinkRedirect=$(echo "$videoIDPreview" | cut -d "\"" -f2 | sort -u)

#echo "videoLinkRedirect: $videoLinkRedirect"
#read pause


videoID=$(echo "$videoIDPreview3")

#echo "videoID: $videoID"
#read pause



getGameTrailersRedirect="$videoLinkRedirect"

case "$getGameTrailersRedirect" in

"")
blank=""
;;

*)

hook="$hookGameTrailers"
highToggle=""
ext="$extGameTrailers"

getNewHTML=$(wget -O index.html $getGameTrailersRedirect)

#echo "getNewHTML: $getNewHTML"
#read pause

parseNewHTML=$(filename='index.html'
filelines=`cat $filename`
for line in $filelines ; do
    echo $line
done)

#echo "$parseNewHTML"
#read pause

videoIDPreview=$(echo "$parseNewHTML" | grep -e "$hookGameTrailers2")

#echo "videoIDPreview: $videoIDPreview"
#read pause

videoIDPreview2=$(echo "$videoIDPreview" | cut -d "\"" -f2)

#echo "videoIDPreview2: $videoIDPreview2"
#read pause

videoLinkRedirectNew=$(echo "$videoIDPreview" | cut -d "\"" -f2)

#echo "videoLinkRedirectNew: $videoLinkRedirectNew"
#read pause

videoID=$(echo "$videoIDPreview2" | cut -d ":" -f6 | head -c36)

#echo "videoID: $videoID"
#read pause
;;

esac


hook="$hookGameTrailers3"
highToggle=""
ext="$extGameTrailers"


case "$videoLinkRedirectNew" in

"")
blank=""
;;

*)

hook="$hookGameTrailers3"
highToggle=""
ext=""

videoLinkRedirectNew2=$(echo "$hookGameTrailers3$videoID" | cut -d "\"" -f2)

#echo "videoLinkRedirectNew2: $videoLinkRedirectNew2"
#read pause

#videoID=$(echo "$videoIDPreview2" | cut -d ":" -f6 | head -c36)

#echo "videoID: $videoID"
#read pause
;;

esac


# Sample link in webpage
#http://www.gametrailers.com/videos/6jyvtj/angry-video-game-nerd-nerd-memories--super-mario-kart" target="_blank">Watch Super Mario Kart Memories on Gametrailers.com


getSegmentsandFragments

cleanTemp

}


getSegmentsandFragments(){

#echo "getSegmentsandFragments"
#read

blank=""

}



buildPlaylist(){

ip=$(echo "000.000.000.000")
videoID=$(echo "99999")


plistBuild1=$(echo "http://")
plistBuild2=$(echo "$ip")
plistBuild3=$(echo "$hookPlaylist")
plistBuild4=$(echo "$videoid")
plistBuild5=$(echo ".smil/playlist.m3u8")


plist="$plistBuild1""$plistBuild2""$plistBuild3""$plistBuild4""$plistBuild5"

}


buildDirectLink(){

directLinkBuild1="$hook"
directLinkBuild2="$videoID"
directLinkBuild3="$highToggle.$ext"

if [ "$hook" == "$hookGameTrailers3" ]; then
directLinkBuild3=""
fi

directLink="$directLinkBuild1""$directLinkBuild2""$directLinkBuild3"

}


getVideoName(){

videoName=$(echo $url | cut -d "/" -f7)

}



getNewFilename(){

cleanTemp

getVideoName

banner
navbar

echo "Original URL: $url"
echo ""
echo "Video ID: $videoID"
echo ""
echo "Direct Download: $directLink"
echo ""
if [ "$hook" == "$hookGameTrailers3" ]; then
echo "Default Filename: $videoName.mp4";
else
echo "Default Filename: $videoName.$ext"
fi
echo ""
echo ""
echo "Enter a name for this video and press ENTER:"
echo ""
echo "Example: AVGN 011 - Double Dragon 3"
echo ""
echo "The extension is automatically appended to the end of name."
echo ""
echo "Press ENTER with no input to use default filename"
#echo "Press ENTER with no input to use default filename: capture-$videoID.$ext"
echo ""
echo ""



read newFilename

case "$newFilename" in

"")

banner

echo "Original URL: $url"
echo ""
echo "Video ID: $videoID"
echo ""
echo "Saving as: ""$videoName.$ext"
#echo "Saving as: ""capture-$videoID.$ext"
echo ""
echo ""
newFilename=$(echo "$videoName")
#newFilename=$(echo "capture-$videoID")
wget -O "$newFilename.$ext" "$directLink"
;;

"r" | "R")
doWork
;;

*)

banner

echo "Original URL: $url"
echo ""
echo "Video ID: $videoID"
echo ""
echo "Saving as: ""$newFilename.$ext"
echo ""
echo ""
wget -O "$newFilename.$ext" "$directLink"
;;

esac

}


getVideoID(){

setVideoID

#echo "Preview: $videoIDPreview"
#echo "videoID: $videoID"
#read pause

}


setVideoID(){

setPreviewVideoID

videoID=$(echo "$videoIDPreview" | cut -d "=" -f3 | cut -d "\"" -f1)

# Using this as default for now as most videos use this
# Will fix when blip.tv and others are supported
hook="$hookJWPlayer"
#highToggle="_high"
#ext="mp4"

# Check the videoID for errors or abnormalities
case "$videoID" in

# Check for a BLANK videoID
"")
checkVideoType
;;

esac

}


setPreviewVideoID(){

# Preview area of capture to grab video ID
videoIDPreview=$(echo "$parseHTML" | grep -e "$hook")

}



getAVGNList(){

banner
#betaHeader

echo "Building AVGN Episode List...."
echo ""
echo ""

#pageGrab=$(wget $url -q -O -)
#newPage=$(links -dump -width 512 "$url" | cut -c 4-)
#newPage=$(lynx -listonly -dump "$url" | sed '1,3d' | cut -c 7-)
#echo "$newPage"


ListPagesTemp=$(lynx -listonly -dump "http://cinemassacre.com/category/avgn/avgnepisodes/page/1/" "http://cinemassacre.com/category/avgn/avgnepisodes/page/2/" "http://cinemassacre.com/category/avgn/avgnepisodes/page/3/" "http://cinemassacre.com/category/avgn/avgnepisodes/page/4/" "http://cinemassacre.com/category/avgn/avgnepisodes/page/5/")

getList2006=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2006/")

getList2007=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2007/")

getList2008=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2008/")

getList2009=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2009/")

getList2010=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2010/")

getList2011=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2011/")

getList2012=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2012/")

getList2013=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2013/")

getList2014=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2014/")


AVGNList=$(echo "$getList2006"$'\n'"$getList2007"$'\n'"$getList2008"$'\n'"$getList2009"$'\n'"$getList2010"$'\n'"$getList2011"$'\n'"$getList2012"$'\n'"$getList2013"$'\n'"$getList2014" | sort -u)

echo "$AVGNList"
echo "$AVGNList" > "AVGN-Episode-List.txt"

#read pause

}


setHook(){

banner


echo "Current Hook: $hook"
echo ""
echo ""
echo "VOD Hook: $hookVOD"
echo ""
echo "Embed Hook: $hookEmbed"
echo ""
echo "Player Hook: $hookPlayer"
echo ""
echo "Playlist Hook: $hookPlaylist"
echo ""
echo "Direct DL Hook: $hookJWPlayer"
echo ""
echo "Blip.tv Hook: $hookBlipTV"
echo ""
echo ""
echo ""
echo "Copy and Paste the new HOOK and press ENTER:"
echo ""
echo ""


read getNewHook


case "$getNewHook" in

"")
setHook
;;

*)
hook=$(echo "$getNewHook")

getURL
;;

esac


}


setExtension(){

banner


echo "Current Extension: $ext"
echo ""
echo ""
echo ""
echo ""
echo "Enter the new EXTENSION and press ENTER:"
echo ""
echo "Example: avi"
echo ""
echo ""


read getNewExtension


case "$getNewExtension" in

"")
setExtension
;;

*)
ext=$(echo "$getNewExtension")

getURL
;;

esac

}


cleanTemp(){

rm "index.html"

# This file is ONLY created if the videoID is not available and the default name is used, resulting in a zero-byte file
rm "capture-.$ext"

banner

}


resizeWindow
doWork






