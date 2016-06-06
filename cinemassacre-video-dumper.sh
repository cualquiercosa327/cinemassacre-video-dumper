#!/bin/bash


# Cinemassacre Video Dumper v0.9
# esc0rtd3w 2016 / https://github.com/esc0rtd3w


#-------------------------------------------------------------
# Version History

# v0.9
# - Rewrote most of the script.
# - Added support for outputting Text and XML dump files
# - Added support for jwplatform video links.
# - Added main menu to choose options.
# - Cleaned up code.
# - Merged navbar with main header

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
# - Changed the default video name to be capture-$mediaID when no name is entered to save.
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

#-------------------------------------------------------------


#-------------------------------------------------------------
# LEGACY

# Find main playlist in script example:
# http://206.217.201.108/Cinemassacre/smil:Cinemassacre-24611.smil/playlist.m3u8


# Direct MP4 Links
# http://player.screenwavemedia.com/play/jwplayer/Cinemassacre-24611.mp4
# http://player.screenwavemedia.com/play/jwplayer/Cinemassacre-24611_high.mp4
#-------------------------------------------------------------


#-------------------------------------------------------------
# HTML source hook
# div class="videoarea"

# New 2016 JWPlatform Hook
# Example New Parse #1 (From Page): content.jwplatform.com/players/[video_id]-[pid].js
# Example New Parse #2 (From JS): content.jwplatform.com/manifests/[video_id].m3u8
#-------------------------------------------------------------




resizeWindow()
{

	printf '\033[8;33;88t'

}


setWindowTitle(){

	title='echo -ne "\033]0;Cinemassacre Video Dumper v0.9 / esc0rtd3w 2016\007"'

	$title

}



setDefaults(){

	scriptVersion="0.9"

	browser="firefox"
	websiteMain="http://www.cinemassacre.com"

	url="0"

	ext="0"
	extBlipTV="m4v"
	extPlayer="mp4"
	extGameTrailers="swf"
	extJWPlatform="m3u8"

	# For XML Output for Kodi plugin
	xmlID="0"
	xmlItemID="0"

	# Used for batch-like processing
	skipMain="0"


	loopList="0"
	urlList="/tmp/urlList"

	# This is solely for letting scripting know if you just launched script or it has been running
	freshStart="1"


	# This is for high quality setting. Variable can be BLANKED for normal quality
	highToggle="_high"

	# Default Hook
	hook="0"

	#-------------------------------------------------------------
	# Legacy Hooks
	hookEmbed="http://player.screenwavemedia.com/play/embed.php?id="
	hookPlayer="http://player.screenwavemedia.com/play/player.php?id=Cinemassacre-"
	hookPlayer2="http://player.screenwavemedia.com/play/Cinemassacre-"
	hookPlaylist="/Cinemassacre/smil:Cinemassacre-"
	hookJWPlayer="http://player.screenwavemedia.com/play/jwplayer/Cinemassacre-"
	hookGorilla="http://cdn.springboard.gorillanation.com/storage/cinemassacre/conversion/"
	hookVOD="http://video2.screenwavemedia.com/vod/Cinemassacre-"
	hookBlipTV="http://a.blip.tv/api.swf#"
	hookBlipTV2="http://blip.tv/file/get/Cinemassacre-"
	hookBlipTV3="http://blip.tv/play/"
	hookYoutube="//www.youtube.com/embed/"
	hookYoutube2="http://www.youtube.com/embed/"
	hookYoutube3="http://www.youtube.com/watch?v="
	hookGameTrailers="http://www.gametrailers.com/videos/"
	hookGameTrailers2="http://media.mtvnservices.com/fb/mgid:arc:video:gametrailers.com:"
	hookGameTrailers3="http://media.mtvnservices.com/player/prime/mediaplayerprime.2.5.7.swf?uri=mgid:arc:video:gametrailers.com:"
	#-------------------------------------------------------------

	#-------------------------------------------------------------
	# New Hooks

	hookDirect="0"

	# //content.jwplatform.com/players/cRG5JPZN-DKo5ucaI.js
	hookJWPlatform="content.jwplatform.com/players/"
	hookJWPlatformJS="content.jwplatform.com/manifests/"
	hookJWPlatformDirect="content.jwplatform.com/videos/"
	hookJWPlatformThumbs="content.jwplatform.com/thumbs/"
	hookJWPlatformPreview="content.jwplatform.com/previews/"
	hookJWPlatformVTT="content.jwplatform.com/strips/"

	hookType="jwplatform"
	hookText="JW Platform"

	# http://content.jwplatform.com/previews/[mediaid]
	previewHook="http://content.jwplatform.com/previews/"
	#-------------------------------------------------------------

	# This is used if the hook must intercept another page to get info
	urlPre="0"
	extPre="0"

	# Preview Videos (If Available)
	#previewLink="$hookJWPlatformPreview$mediaID"

	# HTML Source Dump (Per Page)
	dumpFileToParse="/tmp/dump.html"
	dumpFileHTML="/tmp/dump.html"
	dumpFileJS="/tmp/dump.js"

	configJWP="0"

}


banner(){

	hookText=$(<"/tmp/tmp_hookText")

	clear
	echo "---------------------------------------------------------------------------------------"
	echo "Cinemassacre Video Dumper v$scriptVersion / esc0rtd3w 2016 / github.com/esc0rtd3w"
	echo "---------------------------------------------------------------------------------------"
	echo "---------------------------------------------------------------------------------------"
	echo "Hook: $hookText  |  Media ID: $mediaID  |  PID: $pid"
	echo "---------------------------------------------------------------------------------------"
	echo "---------------------------------------------------------------------------------------"
	echo "Direct Link: $urlNew"
	echo "---------------------------------------------------------------------------------------"
	echo ""

}



# If you want to do NOTHING, DO IT HERE!!!
doNothing() {

	nothing="0"

}



#-------------------------------------------------------------
# LIST PROCESSING --> SHOWS

listShowsAVGN(){

	outFileOption="$PWD/list-shows-avgn.txt"

	listShowsAVGN=$(echo "http://cinemassacre.com/category/avgn/avgnepisodes/page/1/")
	readLinksToList "$listShowsAVGN" "$outFileOption"
	listShowsAVGN=$(echo "http://cinemassacre.com/category/avgn/avgnepisodes/page/2/")
	readLinksToList "$listShowsAVGN" "$outFileOption"
	listShowsAVGN=$(echo "http://cinemassacre.com/category/avgn/avgnepisodes/page/3/")
	readLinksToList "$listShowsAVGN" "$outFileOption"
	listShowsAVGN=$(echo "http://cinemassacre.com/category/avgn/avgnepisodes/page/4/")
	readLinksToList "$listShowsAVGN" "$outFileOption"
	listShowsAVGN=$(echo "http://cinemassacre.com/category/avgn/avgnepisodes/page/5/")
	readLinksToList "$listShowsAVGN" "$outFileOption"
	listShowsAVGN=$(echo "http://cinemassacre.com/category/avgn/avgnepisodes/page/6/")
	readLinksToList "$listShowsAVGN" "$outFileOption"
	#listShowsAVGN=$(echo "http://cinemassacre.com/category/avgn/avgnepisodes/page/7/")
	#readLinksToList "$listShowsAVGN" "$outFileOption"

}


listShowsJamesMike(){

	outFileOption="$PWD/list-shows-jamesmike.txt"

	listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/1/")
	readLinksToList "$listShowsJamesMike" "$outFileOption"
	listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/2/")
	readLinksToList "$listShowsJamesMike" "$outFileOption"
	listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/3/")
	readLinksToList "$listShowsJamesMike" "$outFileOption"
	listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/4/")
	readLinksToList "$listShowsJamesMike" "$outFileOption"
	listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/5/")
	readLinksToList "$listShowsJamesMike" "$outFileOption"
	listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/6/")
	readLinksToList "$listShowsJamesMike" "$outFileOption"
	listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/7/")
	readLinksToList "$listShowsJamesMike" "$outFileOption"
	#listShowsJamesMike=$(echo "http://cinemassacre.com/category/jamesandmike/page/8/")
	#readLinksToList "$listShowsJamesMike" "$outFileOption"

}


listShowsMikeRyan(){

	outFileOption="$PWD/list-shows-mikeryan.txt"

	listShowsMikeRyan=$(echo "http://cinemassacre.com/category/mikeryantalkaboutgames/page/1/")
	readLinksToList "$listShowsMikeRyan" "$outFileOption"
	#listShowsMikeRyan=$(echo "http://cinemassacre.com/category/mikeryantalkaboutgames/page/2/")
	#readLinksToList "$listShowsMikeRyan" "$outFileOption"

}


listShowsMikeBootsy(){

	outFileOption="$PWD/list-shows-mikebootsy.txt"

	listShowsMikeBootsy=$(echo "http://cinemassacre.com/category/mike-bootsy/page/1/")
	readLinksToList "$listShowsMikeBootsy" "$outFileOption"
	#listShowsMikeBootsy=$(echo "http://cinemassacre.com/category/mike-bootsy/page/2/")
	#readLinksToList "$listShowsMikeBootsy" "$outFileOption"

}


listShowsBoardJames(){

	outFileOption="$PWD/list-shows-boardjames.txt"

	listShowsBoardJames=$(echo "http://cinemassacre.com/category/boardjames/page/1/")
	readLinksToList "$listShowsBoardJames" "$outFileOption"
	listShowsBoardJames=$(echo "http://cinemassacre.com/category/boardjames/page/2/")
	readLinksToList "$listShowsBoardJames" "$outFileOption"
	#listShowsBoardJames=$(echo "http://cinemassacre.com/category/boardjames/page/3/")
	#readLinksToList "$listShowsBoardJames" "$outFileOption"

}


listShowsYKWB(){

	outFileOption="$PWD/list-shows-ykwb.txt"

	listShowsYKWB=$(echo "http://cinemassacre.com/category/ykwb/page/1/")
	readLinksToList "$listShowsYKWB" "$outFileOption"
	listShowsYKWB=$(echo "http://cinemassacre.com/category/ykwb/page/2/")
	readLinksToList "$listShowsYKWB" "$outFileOption"
	#listShowsYKWB=$(echo "http://cinemassacre.com/category/ykwb/page/3/")
	#readLinksToList "$listShowsYKWB" "$outFileOption"

}
#-------------------------------------------------------------


#-------------------------------------------------------------
# LIST PROCESSING --> GAMES


listGamesMikesGamingVideos(){

	outFileOption="$PWD/list-games-mikevideos.txt"

	listGamesMikesGamingVideos=$(echo "http://cinemassacre.com/category/mikevideos/page/1/")
	readLinksToList "$listGamesMikesGamingVideos" "$outFileOption"
	listGamesMikesGamingVideos=$(echo "http://cinemassacre.com/category/mikevideos/page/2/")
	readLinksToList "$listGamesMikesGamingVideos" "$outFileOption"
	listGamesMikesGamingVideos=$(echo "http://cinemassacre.com/category/mikevideos/page/3/")
	readLinksToList "$listGamesMikesGamingVideos" "$outFileOption"
	#listGamesMikesGamingVideos=$(echo "http://cinemassacre.com/category/mikevideos/page/4/")
	#readLinksToList "$listGamesMikesGamingVideos" "$outFileOption"

}


listGamesBootsyBeats(){

	outFileOption="$PWD/list-games-bootsybeats.txt"

	listGamesBootsyBeats=$(echo "http://cinemassacre.com/category/gamevideos/bootsy-beats/page/1/")
	readLinksToList "$listGamesBootsyBeats" "$outFileOption"
	#listGamesBootsyBeats=$(echo "http://cinemassacre.com/category/gamevideos/bootsy-beats/page/2/")
	#readLinksToList "$listGamesBootsyBeats" "$outFileOption"

}


listGamesJamesGamingVideos(){

	outFileOption="$PWD/list-games-jamesgamingvideos.txt"

	listGamesJamesGamingVideos=$(echo "http://cinemassacre.com/category/jamesgamingvideos/page/1/")
	readLinksToList "$listGamesJamesGamingVideos" "$outFileOption"
	#listGamesJamesGamingVideos=$(echo "http://cinemassacre.com/category/jamesgamingvideos/page/2/")
	#readLinksToList "$listGamesJamesGamingVideos" "$outFileOption"

}


listGamesOtherGamingVideos(){

	outFileOption="$PWD/list-games-othergamingvideos.txt"

	listGamesOtherGamingVideos=$(echo "http://cinemassacre.com/category/othergaming-videos/page/1/")
	readLinksToList "$listGamesOtherGamingVideos" "$outFileOption"
	#listGamesOtherGamingVideos=$(echo "http://cinemassacre.com/category/othergaming-videos/page/2/")
	#readLinksToList "$listGamesOtherGamingVideos" "$outFileOption"

}


listGamesGameCollection(){

	outFileOption="$PWD/list-games-gamecollection.txt"

	listGamesGameCollection=$(echo "http://cinemassacre.com/2007/03/22/game-collection/page/1/")
	readLinksToList "$listGamesGameCollection" "$outFileOption"
	#listGamesGameCollection=$(echo "http://cinemassacre.com/2007/03/22/game-collection/page/2/")
	#readLinksToList "$listGamesGameCollection" "$outFileOption"

}

#-------------------------------------------------------------


#-------------------------------------------------------------
# LIST PROCESSING --> MOVIES


listMoviesMovieReviewsAZ(){

	outFileOption="$PWD/list-movies-moviereviewsatoz.txt"

	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/1/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/2/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/3/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/4/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/5/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/6/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/7/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/8/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/9/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/10/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/11/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/12/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/13/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/14/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/15/")
	readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"
	#listMoviesMovieReviewsAZ=$(echo "http://cinemassacre.com/category/moviereviewsatoz/page/16/")
	#readLinksToList "$listMoviesMovieReviewsAZ" "$outFileOption"

}


listMoviesTopTens(){

	outFileOption="$PWD/list-movies-toptens.txt"

	listMoviesTopTens=$(echo "http://cinemassacre.com/category/moviereviews/top-tens/page/1/")
	readLinksToList "$listMoviesTopTens" "$outFileOption"
	#listMoviesTopTens=$(echo "http://cinemassacre.com/category/moviereviews/top-tens/page/2/")
	#readLinksToList "$listMoviesTopTens" "$outFileOption"

}


listMoviesAnimationRelated(){

	outFileOption="$PWD/list-movies-animationrelated.txt"

	listMoviesAnimationRelated=$(echo "http://cinemassacre.com/category/moviereviews/animation-moviereviews/page/1/")
	readLinksToList "$listMoviesAnimationRelated" "$outFileOption"
	#listMoviesAnimationRelated=$(echo "http://cinemassacre.com/category/moviereviews/animation-moviereviews/page/2/")
	#readLinksToList "$listMoviesAnimationRelated" "$outFileOption"

}


listMoviesCommentaries(){

	outFileOption="$PWD/list-movies-commentaries.txt"

	listMoviesCommentaries=$(echo "http://cinemassacre.com/category/moviereviews/commentaries/page/1/")
	readLinksToList "$listMoviesCommentaries" "$outFileOption"
	#listMoviesCommentaries=$(echo "http://cinemassacre.com/category/moviereviews/commentaries/page/2/")
	#readLinksToList "$listMoviesCommentaries" "$outFileOption"

}


listMoviesInterviews(){

	outFileOption="$PWD/list-movies-interviews.txt"

	listMoviesInterviews=$(echo "http://cinemassacre.com/category/interviews/page/1/")
	readLinksToList "$listMoviesInterviews" "$outFileOption"
	#listMoviesInterviews=$(echo "http://cinemassacre.com/category/interviews/page/2/")
	#readLinksToList "$listMoviesInterviews" "$outFileOption"

}


listMoviesLocationTours(){

	outFileOption="$PWD/list-movies-locationtours.txt"

	listMoviesLocationTours=$(echo "http://cinemassacre.com/category/location-tours/page/1/")
	readLinksToList "$listMoviesLocationTours" "$outFileOption"
	#listMoviesLocationTours=$(echo "http://cinemassacre.com/category/location-tours/page/2/")
	#readLinksToList "$listMoviesLocationTours" "$outFileOption"

}


listMoviesMonsterMadness(){

	outFileOption="$PWD/list-movies-monstermadness.txt"

	listMoviesMonsterMadness=$(echo "http://cinemassacre.com/category/moviereviews/monstermadness/page/1/")
	readLinksToList "$listMoviesMonsterMadness" "$outFileOption"
	#listMoviesMonsterMadness=$(echo "http://cinemassacre.com/category/moviereviews/monstermadness/page/2/")
	#readLinksToList "$listMoviesMonsterMadness" "$outFileOption"

}


listMoviesTriviaVideos(){

	outFileOption="$PWD/list-movies-triviavideos.txt"

	listMoviesTriviaVideos=$(echo "http://cinemassacre.com/category/trivia-videos/page/1/")
	readLinksToList "$listMoviesTriviaVideos" "$outFileOption"
	#listMoviesTriviaVideos=$(echo "http://cinemassacre.com/category/trivia-videos/page/2/")
	#readLinksToList "$listMoviesTriviaVideos" "$outFileOption"

}


listMoviesOtherMovieStuff(){

	outFileOption="$PWD/list-movies-othermovierelatedvideos.txt"

	listMoviesOtherMovieStuff=$(echo "http://cinemassacre.com/category/othermovierelatedvideos/page/1/")
	readLinksToList "$listMoviesOtherMovieStuff" "$outFileOption"
	#listMoviesOtherMovieStuff=$(echo "http://cinemassacre.com/category/othermovierelatedvideos/page/2/")
	#readLinksToList "$listMoviesOtherMovieStuff" "$outFileOption"

}

#-------------------------------------------------------------


#-------------------------------------------------------------
# LIST PROCESSING --> ORIGINAL FILMS


listFilmsMain(){

	outFileOption="$PWD/list-films-main.txt"

	listFilmsMain=$(echo "http://cinemassacre.com/category/films/page/1/")
	readLinksToList "$listFilmsMain" "$outFileOption"
	listFilmsMain=$(echo "http://cinemassacre.com/category/films/page/2/")
	readLinksToList "$listFilmsMain" "$outFileOption"
	listFilmsMain=$(echo "http://cinemassacre.com/category/films/page/3/")
	readLinksToList "$listFilmsMain" "$outFileOption"
	listFilmsMain=$(echo "http://cinemassacre.com/category/films/page/4/")
	readLinksToList "$listFilmsMain" "$outFileOption"
	#listFilmsMain=$(echo "http://cinemassacre.com/category/films/page/5/")
	#readLinksToList "$listFilmsMain" "$outFileOption"

}


listFilmsFavorites(){

	outFileOption="$PWD/list-films-favorites.txt"

	listFilmsFavorites=$(echo "http://cinemassacre.com/category/films/favorites/page/1/")
	readLinksToList "$listFilmsFavorites" "$outFileOption"
	#listFilmsFavorites=$(echo "http://cinemassacre.com/category/films/favorites/page/2/")
	#readLinksToList "$listFilmsFavorites" "$outFileOption"

}


listFilmsAnimation(){

	outFileOption="$PWD/list-films-animation.txt"

	listFilmsAnimation=$(echo "http://cinemassacre.com/category/films/animation/page/1/")
	readLinksToList "$listFilmsAnimation" "$outFileOption"
	#listFilmsAnimation=$(echo "http://cinemassacre.com/category/films/animation/page/2/")
	#readLinksToList "$listFilmsAnimation" "$outFileOption"

}


listFilmsHorror(){

	outFileOption="$PWD/list-films-horror.txt"

	listFilmsHorror=$(echo "http://cinemassacre.com/category/films/horror-films/page/1/")
	readLinksToList "$listFilmsHorror" "$outFileOption"
	listFilmsHorror=$(echo "http://cinemassacre.com/category/films/horror-films/page/2/")
	readLinksToList "$listFilmsHorror" "$outFileOption"
	#listFilmsHorror=$(echo "http://cinemassacre.com/category/films/horror-films/page/3/")
	#readLinksToList "$listFilmsHorror" "$outFileOption"

}


listFilmsComedy(){

	outFileOption="$PWD/list-films-comedy.txt"

	listFilmsComedy=$(echo "http://cinemassacre.com/category/films/comedy/page/1/")
	readLinksToList "$listFilmsComedy" "$outFileOption"
	#listFilmsComedy=$(echo "http://cinemassacre.com/category/films/comedy/page/2/")
	#readLinksToList "$listFilmsComedy" "$outFileOption"

}


listFilmsFortyEightHours(){

	outFileOption="$PWD/list-films-48hour.txt"

	listFilmsFortyEightHours=$(echo "http://cinemassacre.com/category/films/48-hour-films/page/1/")
	readLinksToList "$listFilmsFortyEightHours" "$outFileOption"
	#listFilmsFortyEightHours=$(echo "http://cinemassacre.com/category/films/48-hour-films/page/2/")
	#readLinksToList "$listFilmsFortyEightHours" "$outFileOption"

}


listFilmsOther(){

	outFileOption="$PWD/list-films-other.txt"

	listFilmsOther=$(echo "http://cinemassacre.com/category/films/other/page/1/")
	readLinksToList "$listFilmsOther" "$outFileOption"
	#listFilmsOther=$(echo "http://cinemassacre.com/category/films/other/page/2/")
	#readLinksToList "$listFilmsOther" "$outFileOption"

}


listFilmsGallery(){

	outFileOption="$PWD/list-films-gallery.txt"

	listFilmsGallery=$(echo "http://cinemassacre.com/category/photo-gallery/page/1/")
	readLinksToList "$listFilmsGallery" "$outFileOption"
	listFilmsGallery=$(echo "http://cinemassacre.com/category/photo-gallery/page/2/")
	readLinksToList "$listFilmsGallery" "$outFileOption"
	#listFilmsGallery=$(echo "http://cinemassacre.com/category/photo-gallery/page/3/")
	#readLinksToList "$listFilmsGallery" "$outFileOption"

}

#-------------------------------------------------------------


#-------------------------------------------------------------
# LIST PROCESSING --> MUSIC


listMusicMain(){

	outFileOption="$PWD/list-music-main.txt"

	listMusicMain=$(echo "http://cinemassacre.com/category/music-2/page/1/")
	readLinksToList "$listMusicMain" "$outFileOption"

	#listMusicMain=$(echo "http://cinemassacre.com/category/music-2/page/1/")
	#readLinksToList "$listMusicMain" "$outFileOption"

}


listMusicAudioSlaughter(){

	outFileOption="$PWD/list-music-audioslaughter.txt"

	listMusicAudioSlaughter=$(echo "http://cinemassacre.com/category/music-2/audio-slaughter/page/1/")
	readLinksToList "$listMusicAudioSlaughter" "$outFileOption"

	#listMusicAudioSlaughter=$(echo "http://cinemassacre.com/category/music-2/audio-slaughter/page/1/")
	#readLinksToList "$listMusicAudioSlaughter" "$outFileOption"

}


listMusicKyleJustin(){

	outFileOption="$PWD/list-music-kylejustin.txt"

	listMusicKyleJustin=$(echo "http://cinemassacre.com/category/music-2/kylejustin/page/1/")
	readLinksToList "$listMusicKyleJustin" "$outFileOption"

	#listMusicKyleJustin=$(echo "http://cinemassacre.com/category/music-2/kylejustin/page/1/")
	#readLinksToList "$listMusicKyleJustin" "$outFileOption"

}


listMusicNameThatTune(){

	outFileOption="$PWD/list-music-namethattune.txt"

	listMusicNameThatTune=$(echo "http://cinemassacre.com/category/music-2/namethattune/page/1/")
	readLinksToList "$listMusicNameThatTune" "$outFileOption"

	#listMusicNameThatTune=$(echo "http://cinemassacre.com/category/music-2/namethattune/page/1/")
	#readLinksToList "$listMusicNameThatTune" "$outFileOption"

}

#-------------------------------------------------------------


#-------------------------------------------------------------
# LIST PROCESSING --> SITE


listSiteMain(){

	outFileOption="$PWD/list-site-main.txt"

	listSiteMain=$(echo "http://cinemassacre.com/category/site-2/page/1/")
	readLinksToList "$listSiteMain" "$outFileOption"
	#listSiteMain=$(echo "http://cinemassacre.com/category/site-2/page/2/")
	#readLinksToList "$listSiteMain" "$outFileOption"

}


listSiteArticles(){

	outFileOption="$PWD/list-site-featuredarticles.txt"

	listSiteArticles=$(echo "http://cinemassacre.com/category/site-2/featuredarticles/page/1/")
	readLinksToList "$listSiteArticles" "$outFileOption"
	#listSiteArticles=$(echo "http://cinemassacre.com/category/site-2/featuredarticles/page/2/")
	#readLinksToList "$listSiteArticles" "$outFileOption"

}


listSiteAppearances(){

	outFileOption="$PWD/list-site-appearances.txt"

	listSiteAppearances=$(echo "http://cinemassacre.com/category/site-2/appearances/page/1/")
	readLinksToList "$listSiteAppearances" "$outFileOption"
	#listSiteAppearances=$(echo "http://cinemassacre.com/category/site-2/appearances/page/2/")
	#readLinksToList "$listSiteAppearances" "$outFileOption"

}


listSiteMiscVideos(){

	outFileOption="$PWD/list-site-miscvideos.txt"

	listSiteMiscVideos=$(echo "http://cinemassacre.com/category/site-2/misc-videos/page/1/")
	readLinksToList "$listSiteMiscVideos" "$outFileOption"
	#listSiteMiscVideos=$(echo "http://cinemassacre.com/category/site-2/misc-videos/page/2/")
	#readLinksToList "$listSiteMiscVideos" "$outFileOption"

}

#-------------------------------------------------------------




menuMain(){

	case "$freshStart" in

		"1")
		cleanOutput
		;;
	
	esac

	case "$skipMain" in

		"1")
		menuAuto
		;;
	
	esac

	# Set fresh start as "0" to prevent cleaning of files when returning to main menu from within script
	freshStart="0"

	cleanTemp	

	banner

	echo "Choose An Option and Press ENTER:"
	echo ""
	echo ""
	echo "A) *Automated Parsing and File Creation*"
	echo ""
	echo "1) Enter URL To Parse"
	echo "2) Dump Source From URL"
	echo ""
	echo "3) Detect Hook From Source"
	echo "4) Set Hook Manually"
	echo ""
	echo "5) Get Video ID"
	echo ""
	echo "6) Build Links"
	echo ""
	echo "7) Create Files"
	echo ""
	echo "X) Exit"
	echo ""
	echo ""

	read task


	case "$task" in

		"")
		menuMain
		;;

		"a" | "A")
		banner
		echo "Select An Option and Press ENTER:"
		echo ""
		echo ""
		echo "1) Skip Return Back To Main Menu After Parsing"
		echo ""
		echo "2) Build New List of URLs To Parse and Dump"
		echo ""
		echo "3) Load List of URLs To Parse and Dump"
		echo ""
		echo ""
		echo ""
		echo ""
		echo "** YOU MAY JUST PRESS ENTER TO CONTINUE NORMALLY **"
		echo ""
		echo ""

		read autoOptions

		case "$autoOptions" in

			"1")
			skipMain="1"
			;;

			"2")
			buildNewLists
			;;

			"3")
			banner
			echo "Type or Drag List Name To Process and Press ENTER:"
			echo ""
			echo ""

			read urlListOption

			urlListOptionTrimmed=$(echo "$urlListOption" | sed "s/'//g")
			#echo "$urlListOptionTrimmed"
			#read pause

			cp "$urlListOptionTrimmed" "/tmp/urlList"
			#read pause

			dumpFileToParse="/tmp/dump.html"

			#loadList "loop"
			loadList
			;;

		esac

		menuAuto
		;;

		"1")
		getURL
		;;

		"2")
		dumpHTML
		;;

		"3")
		detectHook
		;;

		"4")
		setHook
		;;

		"5")
		getMediaID
		;;

		"6")
		buildLinks
		;;

		"7")
		createOutputFiles "plaintext"
		#createOutputFiles "html"
		createOutputFiles "xml"
		;;

		"x" | "X")
		cleanExit
		;;

		*)
		menuMain
		;;

	esac

menuMain


}


menuAuto(){

	cleanTemp

	setDefaultHook

	getURL
	dumpHTML
	getMediaID
	getShortLink
	buildLinks

	dumpJS
	getJSInfo

	createOutputFiles "plaintext"
	#createOutputFiles "html"
	createOutputFiles "xml"
	
	menuMain

}


buildNewLists(){

	banner
	echo "Select A Main Category To Build New List From:"
	echo ""
	echo ""
	echo "1) Entire Cinemassacre Site (WARNING! THIS MAY TAKE A LONG TIME!)"
	echo ""
	echo "2) Shows"
	echo ""
	echo "3) Games"
	echo ""
	echo "4) Movies"
	echo ""
	echo "5) Original Films"
	echo ""
	echo "6) Music"
	echo ""
	echo "7) Site"
	echo ""
	echo ""

	read buildOption

	case "$buildOption" in

		"")
		buildNewLists
		;;

		"1")
		listBuilder "all"
		;;

		"2")
		#listBuilder "shows"

		banner
		echo "Select A Sub Category To Build New List From:"
		echo ""
		echo ""
		echo "1) Angry Video Game Nerd"
		echo ""
		echo "2) James & Mike Mondays"
		echo ""
		echo "3) Mike & Ryan"
		echo ""
		echo "4) Mike & Bootsy"
		echo ""
		echo "5) Board James"
		echo ""
		echo "6) You Know What's Bullshit"
		echo ""
		echo ""

		read subCatShows

		case "$subCatShows" in

			"")
			doNothing
			;;

			"1")
			listShowsAVGN
			;;

			"2")
			listShowsJamesMike
			;;

			"3")
			listShowsMikeRyan
			;;

			"4")
			listShowsMikeBootsy
			;;

			"5")
			listShowsBoardJames
			;;

			"6")
			listShowsYKWB
			;;

			*)
			doNothing
			;;

		esac

		;;

		"3")
		#listBuilder "games"

		banner
		echo "Select A Sub Category To Build New List From:"
		echo ""
		echo ""
		echo "1) Mike's Gaming Videos"
		echo ""
		echo "2) Bootsy Beats"
		echo ""
		echo "3) James' Gaming Videos"
		echo ""
		echo "4) Other Gaming Videos"
		echo ""
		echo "5) Game Collection"
		echo ""
		echo ""

		read subCatGames

		case "$subCatGames" in

			"")
			doNothing
			;;

			"1")
			listGamesMikesGamingVideos
			;;

			"2")
			listGamesBootsyBeats
			;;

			"3")
			listGamesJamesGamingVideos
			;;

			"4")
			listGamesOtherGamingVideos
			;;

			"5")
			listGamesGameCollection
			;;

			*)
			doNothing
			;;

		esac
		;;

		"4")
		#listBuilder "movies"

		banner
		echo "Select A Sub Category To Build New List From:"
		echo ""
		echo ""
		echo "1) Movie Reviews A-Z"
		echo ""
		echo "2) Top Tens"
		echo ""
		echo "3) Animation Related"
		echo ""
		echo "4) Commentaries"
		echo ""
		echo "5) Interviews"
		echo ""
		echo "6) Location Tours"
		echo ""
		echo "7) Monster Madness"
		echo ""
		echo "8) Trivia Videos"
		echo ""
		echo "9) Other Movie Stuff"
		echo ""
		#echo ""

		read subCatMovies

		case "$subCatMovies" in

			"")
			doNothing
			;;

			"1")
			listMoviesMovieReviewsAZ
			;;

			"2")
			listMoviesTopTens
			;;

			"3")
			listMoviesAnimationRelated
			;;

			"4")
			listMoviesCommentaries
			;;

			"5")
			listMoviesInterviews
			;;

			"6")
			listMoviesLocationTours
			;;

			"7")
			listMoviesMonsterMadness
			;;

			"8")
			listMoviesTriviaVideos
			;;

			"9")
			listMoviesOtherMovieStuff
			;;

			*)
			doNothing
			;;

		esac
		;;

		"5")
		#listBuilder "originalfilms"

		banner
		echo "Select A Sub Category To Build New List From:"
		echo ""
		echo ""
		echo "1) Main Page"
		echo ""
		echo "2) Favorites"
		echo ""
		echo "3) Animation"
		echo ""
		echo "4) Horror"
		echo ""
		echo "5) Comedy"
		echo ""
		echo "6) 48-Hour Films"
		echo ""
		echo "7) Other Personal Films"
		echo ""
		echo "8) Gallery"
		echo ""
		echo ""

		read subCatFilms

		case "$subCatFilms" in

			"")
			doNothing
			;;

			"1")
			listFilmsMain
			;;

			"2")
			listFilmsFavorites
			;;

			"3")
			listFilmsAnimation
			;;

			"4")
			listFilmsHorror
			;;

			"5")
			listFilmsComedy
			;;

			"6")
			listFilmsFortyEightHours
			;;

			"7")
			listFilmsOther
			;;

			"8")
			listFilmsGallery
			;;

			*)
			doNothing
			;;

		esac
		;;

		"6")
		#listBuilder "music"

		banner
		echo "Select A Sub Category To Build New List From:"
		echo ""
		echo ""
		echo "1) Main Page"
		echo ""
		echo "2) Audio Slaughter"
		echo ""
		echo "3) Kyle Justin"
		echo ""
		echo "4) Name That Tune"
		echo ""
		echo ""

		read subCatMusic

		case "$subCatMusic" in

			"")
			doNothing
			;;

			"1")
			listMusicMain
			;;

			"2")
			listMusicAudioSlaughter
			;;

			"3")
			listMusicKyleJustin
			;;

			"4")
			listMusicNameThatTune
			;;

			*)
			doNothing
			;;

		esac
		;;

		"7")
		#listBuilder "site"

		banner
		echo "Select A Sub Category To Build New List From:"
		echo ""
		echo ""
		echo "1) Main Page"
		echo ""
		echo "2) Articles"
		echo ""
		echo "3) Appearances"
		echo ""
		echo "4) Misc Videos"
		echo ""
		echo ""

		read subCatSite

		case "$subCatSite" in

			"")
			doNothing
			;;

			"1")
			listSiteMain
			;;

			"2")
			listSiteArticles
			;;

			"3")
			listSiteAppearances
			;;

			"4")
			listSiteMiscVideos
			;;

			*)
			doNothing
			;;

		esac
		;;

		*)
		buildNewLists
		;;

	esac

menuMain

}


listBuilder(){

	case "$1" in

		"")
		echo "Build Type Not Defined!"
		echo ""
		echo ""
		read pause
		;;

		"all")
		read pause
		;;

		"shows")

		read pause
		;;

		"games")
		read pause
		;;

		"movies")

		read pause
		;;

		"originalfilms")

		read pause
		;;

		"music")

		read pause
		;;

		"site")

		read pause
		;;

		*)
		echo "Build Type Not Defined!"
		echo ""
		echo ""
		read pause
		;;

	esac

menuMain

}


loadList(){

	# Check for loop argument
	case "$1" in
	
		"loop")
		loopList="1"
		;;

	esac

	#banner
	#echo "ATTENTION!! THIS IS NOT WORKING PROPERLY"
	#echo ""
	#echo ""

	#sleep 5

	

	banner
	echo ""

	#cleanTemp

	setDefaultHook


	# URL must be set here to dump
	#urlLine=0
	#timesLooped=0
	while read line;do

		url=$(echo "$line")

		#((urlLine++))

		# dumpHTML
		getRawHTML=$(wget $url -O $dumpFileToParse)
		parseHTML=$(cat "$dumpFileToParse")
		getShortLink

		# getMediaID
		hook="$hookJWPlatform"
		echo "$hookText">"/tmp/tmp_hookText"
		mediaID=$(cat "$dumpFileToParse" | grep $hook | cut -d "." -f3 | cut -d "/" -f3 | cut -d "-" -f1)
		pid=$(cat "$dumpFileToParse" | grep $hook | cut -d "." -f3 | cut -d "/" -f3 | cut -d "-" -f2)
		echo "$mediaID">"/tmp/tmp_mediaID"
		echo "$pid">"/tmp/tmp_pid"

		# buildLinks
		hookDirect="$hookJWPlatformJS"
		ext="$extJWPlatform"
		extPre="js"
		urlPre="$hook$mediaID-$pid.$extPre"
		urlNew="$hookDirect$mediaID.$ext"

		# dumpJS
		getRawJS=$(wget $urlPre -O $dumpFileJS)
		parseJS=$(cat '/tmp/dump.js')

		# getJSInfo
		configJWPTemp=$(cat "$dumpFileJS" | sed -n -E -e '/Initialize player/,$ p' | sed '1 d')
		configJWP=$(echo "$configJWPTemp" | sed -n -E -e '/playlist/,$ p' | sed '1 d')
		echo "$configJWP">"/tmp/configJWP"
		dumpList=$(cat "/tmp/configJWP" | grep $mediaID)
		itemDuration=$(cat "/tmp/configJWP" | grep duration | cut -d "\"" -f3 | cut -d ":" -f2 | head -n 1 | sed 's/[ ]//' | sed 's/[,]//')
		itemLegacyID=$(cat "/tmp/configJWP" | grep legacy_id | cut -d ":" -f2 | cut -d "\"" -f2)
		itemPubDate=$(cat "/tmp/configJWP" | grep pubdate | cut -d "\"" -f4)
		itemTitle=$(cat "/tmp/configJWP" | grep title | cut -d "\"" -f4)
		itemTitleXML=$(cat "/tmp/configJWP" | grep title | cut -d "\"" -f4 | sed 's/[&]/&amp;/')
		itemPlaylist=$(cat "/tmp/configJWP" | grep $hookJWPlatformJS | cut -d "\"" -f4)
		itemAudio=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep m4a | cut -d "\"" -f4)
		itemVideoList=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep mp4 | cut -d "\"" -f4)
		itemVideoList1=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep mp4 | cut -d "\"" -f4 | head -n 1)
		itemVideoList2=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep mp4 | cut -d "\"" -f4 | tail -n 1)
		itemImage=$(cat "/tmp/configJWP" | grep image | cut -d "\"" -f4)
		itemPreview=$(cat "/tmp/configJWP" | grep $hookJWPlatformPreview | cut -d "\"" -f4)
		itemThumbnail=$(cat "/tmp/configJWP" | grep $hookJWPlatformThumbs | cut -d "\"" -f4)
		itemThumbnailBig=$(cat "/tmp/configJWP" | grep thumbnail_url | cut -d "\"" -f4)
		itemVTT=$(cat "/tmp/configJWP" | grep $hookJWPlatformVTT | cut -d "\"" -f4)
		itemWebLink="$url"
		itemPlaylist=$(echo "http:$itemPlaylist")
		itemAudio=$(echo "http:$itemAudio")
		itemVideoList1=$(echo "http:$itemVideoList1")
		itemVideoList2=$(echo "http:$itemVideoList2")
		itemImage=$(echo "http:$itemImage")
		itemPreview=$(echo "http:$itemPreview")
		itemThumbnail=$(echo "http:$itemThumbnail")
		#itemThumbnailBig=$(echo "http:$itemThumbnailBig")
		itemVTT=$(echo "http:$itemVTT")
		#itemWebLink=$(echo "http:$itemWebLink")


		# If pubDate is BLANK, then the url is INVALID
		case "$itemPubDate" in
		
			"")
				
			;;

			*)
			# Build PlainText List
			echo "">>"/$PWD/dump-plaintext.txt"
			echo "itemTitle: $itemTitle">>"/$PWD/dump-plaintext.txt"
			echo "itemWebLink: $itemWebLink">>"/$PWD/dump-plaintext.txt"
			echo "itemPlaylist: $itemPlaylist">>"/$PWD/dump-plaintext.txt"
			echo "itemAudio: $itemAudio">>"/$PWD/dump-plaintext.txt"
			echo "itemVideoList: $itemVideoList">>"/$PWD/dump-plaintext.txt"
			echo "itemVideoList1: $itemVideoList1">>"/$PWD/dump-plaintext.txt"
			echo "itemVideoList2: $itemVideoList2">>"/$PWD/dump-plaintext.txt"
			echo "itemDuration: $itemDuration">>"/$PWD/dump-plaintext.txt"
			echo "itemImage: $itemImage">>"/$PWD/dump-plaintext.txt"
			echo "itemLegacyID: $itemLegacyID">>"/$PWD/dump-plaintext.txt"
			echo "itemPubDate: $itemPubDate">>"/$PWD/dump-plaintext.txt"
			echo "itemPreview: $itemPreview">>"/$PWD/dump-plaintext.txt"
			echo "itemThumbnail: $itemThumbnail">>"/$PWD/dump-plaintext.txt"
			echo "itemThumbnailBig: $itemThumbnailBig">>"/$PWD/dump-plaintext.txt"
			echo "itemVTT: $itemVTT">>"/$PWD/dump-plaintext.txt"
			echo "itemShortLink: $itemShortLink">>"/$PWD/dump-plaintext.txt"
			echo "itemShortLinkID: $itemShortLinkID">>"/$PWD/dump-plaintext.txt"
			echo "">>"/$PWD/dump-plaintext.txt"


			# Build XML for Kodi plugin
			#xmlID=$(($xmlID+1))
			#xmlItemID=$(($xmlItemID+1))
			echo "<item id=\"$itemShortLinkID\" activeInd=\"Y\">">>"/$PWD/dump-xml.xml"
			echo "<title>$itemTitleXML</title>">>"/$PWD/dump-xml.xml"
			echo "<link>$itemWebLink</link>">>"/$PWD/dump-xml.xml"
			echo "<pubDate>$itemPubDate</pubDate>">>"/$PWD/dump-xml.xml"
			echo "<id>$itemShortLinkID</id>">>"/$PWD/dump-xml.xml"
			echo "<movieURL>$mediaID</movieURL>">>"/$PWD/dump-xml.xml"
			echo "<description>$itemTitleXML</description>">>"/$PWD/dump-xml.xml"
			echo "<smallThumbnail>$itemThumbnail</smallThumbnail>">>"/$PWD/dump-xml.xml"
			echo "<duration>$itemDuration</duration>">>"/$PWD/dump-xml.xml"
			echo "<categories>">>"/$PWD/dump-xml.xml"
			echo "<category id=\"402\" activeInd=\"Y\"/>">>"/$PWD/dump-xml.xml"
			echo "<category id=\"1065\" activeInd=\"Y\"/>">>"/$PWD/dump-xml.xml"
			echo "</categories>">>"/$PWD/dump-xml.xml"
			echo "</item>">>"/$PWD/dump-xml.xml"
			echo "">>"/$PWD/dump-xml.xml"
			;;

		esac
		

	done < $urlList


	#case "$loopList" in
	
	#	"1")

	#	if (($urlLine > 3)); then

	#		echo "Reached End Of List!"
	#		echo ""
	#		read pause

	#	fi

	#	;;

	#esac

menuMain

}


setDefaultHook(){

	hook="$hookJWPlatform"
	hookType="jwplatform"
	hookText="JW Platform"

	echo "$hook">"/tmp/tmp_hook"
	echo "$hookType">"/tmp/tmp_hookType"
	echo "$hookText">"/tmp/tmp_hookText"
}


detectHook(){

	read pause

}


getURL(){

	banner

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

		"v" | "V")
		setmediaID
		;;

		"r" | "R")
		menuMain
		;;

		*)
		url=$(echo "$getNewURL")
		#echo "$url"
		echo "$url">"/tmp/url.tmp"
		#read pause
		#dumpHTML
		;;

	esac

}


dumpHTML(){

	#cleanTemp

	url=$(<"/tmp/url.tmp")
	rm "/tmp/url.tmp"
	#echo "$url"
	#read pause

	getRawHTML=$(wget $url -O $dumpFileHTML)

	parseHTML=$(filename='/tmp/dump.html'
	filelines=`cat $filename`
	for line in $filelines ; do
	    echo $line
	done)

}


# Temp fix for new JWPlatform because I am lazy ;)
dumpJS(){

	urlPre=$(<"/tmp/urlPre.tmp")
	rm "/tmp/urlPre.tmp"
	#echo "$urlPre"
	#read pause

	getRawJS=$(wget $urlPre -O $dumpFileJS)

	parseJS=$(filename='/tmp/dump.js'
	filelines=`cat $filename`
	for line in $filelines ; do
	    echo $line
	done)
}


setHook(){

	banner


	echo "Select New Hook and Press ENTER:"
	echo ""
	echo ""
	echo "1) $hookJWPlatform"
	echo ""
	echo ""
	echo "*** ALL BELOW ARE LEGACY HOOKS AND MOST LIKELY WILL FAIL ***"
	echo ""
	echo "2) $hookVOD"
	echo ""
	echo "3) $hookEmbed"
	echo ""
	echo "4) $hookPlayer"
	echo ""
	echo "5) $hookPlaylist"
	echo ""
	echo "6) $hookJWPlayer"
	echo ""
	echo "7) $hookBlipTV"
	echo ""
	echo ""


	read getNewHook


	case "$getNewHook" in

		"")
		hook="$hookJWPlatform"
		hookType="jwplatform"
		hookText="JW Platform"
		;;

		"1")
		hook="$hookJWPlatform"
		hookType="jwplatform"
		hookText="JW Platform"
		;;

		"2")
		hook="$hookVOD"
		hookType="vod"
		hookText="Video On-Demand"
		;;

		"3")
		hook="$hookEmbed"
		hookType="embed"
		hookText="YouTube Embedded"
		;;

		"4")
		hook="$hookPlayer"
		hookType="player"
		hookText="JWPlayer Old 1"
		;;

		"5")
		hook="$hookPlaylist"
		hookType="playlist"
		hookText="Playlist Style"
		;;

		"6")
		hook="$hookJWPlayer"
		hookType="jwplayer"
		hookText="JWPlayer Old 2"
		;;

		"7")
		hook="$hookBlipTV"
		hookType="bliptv"
		hookText="Blip.tv"
		;;

		*)
		hook="$hookJWPlatform"
		hookType="jwplatform"
		hookText="JW Platform"
		;;

	esac

echo "$hook">"/tmp/tmp_hook"
echo "$hookType">"/tmp/tmp_hookType"
echo "$hookText">"/tmp/tmp_hookText"

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
		;;

	esac

}


getShortLink(){

	# Grab shortlink from HTML for XML ID
	itemShortLink=$(cat "$dumpFileToParse" | grep shortlink | cut -d "'" -f4)
	echo "$itemShortLink">"/tmp/tmp_itemShortLink"
	itemShortLinkID=$(cat "$dumpFileToParse" | grep shortlink | cut -d "'" -f4 | cut -d "=" -f2)
	echo "$itemShortLinkID">"/tmp/tmp_itemShortLinkID"
	#read pause
}


getMediaID(){

	# Using this as default for now as most videos use this
	hook="$hookJWPlatform"
	
	# Some hackery
	echo "$hookText">"/tmp/tmp_hookText"

	# Find this:
	# <div class="videoarea"><script src="//content.jwplatform.com/players/OHU6XdZk-f5T0945b.js">

	# Preview area of capture to grab video ID
	mediaID=$(cat "$dumpFileHTML" | grep $hook | cut -d "." -f3 | cut -d "/" -f3 | cut -d "-" -f1)
	pid=$(cat "$dumpFileHTML" | grep $hook | cut -d "." -f3 | cut -d "/" -f3 | cut -d "-" -f2)

	echo "$mediaID">"/tmp/tmp_mediaID"
	echo "$pid">"/tmp/tmp_pid"

}


getJSInfo(){

	# Dumping JS File with all the goodies!

	#findMain="jwplayer("

	#findAdvertising="\"advertising\":"

	# Find main JWPlayer Section and cut off everything before it
	configJWPTemp=$(cat "$dumpFileJS" | sed -n -E -e '/Initialize player/,$ p' | sed '1 d')

	# This cuts off aspectratio, but returns everything afer it
	#configJWP=$(echo "$configJWPTemp" | sed -n -E -e '/aspectratio/,$ p' | sed '1 d')

	configJWP=$(echo "$configJWPTemp" | sed -n -E -e '/playlist/,$ p' | sed '1 d')

	# Dump a minimal useable output
	echo "$configJWP">"/tmp/configJWP"
	dumpList=$(cat "/tmp/configJWP" | grep $mediaID)

	# Start setting variables from text

	# Text Fields
	itemDuration=$(cat "/tmp/configJWP" | grep duration | cut -d "\"" -f3 | cut -d ":" -f2 | head -n 1 | sed 's/[ ]//' | sed 's/[,]//')
	itemLegacyID=$(cat "/tmp/configJWP" | grep legacy_id | cut -d ":" -f2 | cut -d "\"" -f2)
	itemPubDate=$(cat "/tmp/configJWP" | grep pubdate | cut -d "\"" -f4)
	itemTitle=$(cat "/tmp/configJWP" | grep title | cut -d "\"" -f4)

	# XML Syntax Fix
	itemTitleXML=$(cat "/tmp/configJWP" | grep title | cut -d "\"" -f4 | sed 's/[&]/&amp;/')
	
	# Links
	itemPlaylist=$(cat "/tmp/configJWP" | grep $hookJWPlatformJS | cut -d "\"" -f4)
	itemAudio=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep m4a | cut -d "\"" -f4)

	# Fix later if more than 2 sources, something must be done to check
	# By using this method, the 2nd video should yield the highest quality
	itemVideoList=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep mp4 | cut -d "\"" -f4)

	itemVideoList1=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep mp4 | cut -d "\"" -f4 | head -n 1)
	itemVideoList2=$(cat "/tmp/configJWP" | grep $hookJWPlatformDirect | grep mp4 | cut -d "\"" -f4 | tail -n 1)
	itemImage=$(cat "/tmp/configJWP" | grep image | cut -d "\"" -f4)
	itemPreview=$(cat "/tmp/configJWP" | grep $hookJWPlatformPreview | cut -d "\"" -f4)
	itemThumbnail=$(cat "/tmp/configJWP" | grep $hookJWPlatformThumbs | cut -d "\"" -f4)
	itemThumbnailBig=$(cat "/tmp/configJWP" | grep thumbnail_url | cut -d "\"" -f4)
	itemVTT=$(cat "/tmp/configJWP" | grep $hookJWPlatformVTT | cut -d "\"" -f4)

	# This should be the original entered URL
	itemWebLink="$url"<"/tmp/url.tmp"


	# Prepend http text
	itemPlaylist=$(echo "http:$itemPlaylist")
	itemAudio=$(echo "http:$itemAudio")
	itemVideoList1=$(echo "http:$itemVideoList1")
	itemVideoList2=$(echo "http:$itemVideoList2")
	itemImage=$(echo "http:$itemImage")
	itemPreview=$(echo "http:$itemPreview")
	itemThumbnail=$(echo "http:$itemThumbnail")
	#itemThumbnailBig=$(echo "http:$itemThumbnailBig")
	itemVTT=$(echo "http:$itemVTT")
	#itemWebLink=$(echo "http:$itemWebLink")


	#clear
	#echo "itemTitle: $itemTitle"
	#echo ""
	#echo "itemWebLink: $itemWebLink"
	#echo ""
	#echo "itemPlaylist: $itemPlaylist"
	#echo "itemAudio: $itemAudio"
	#echo ""
	#echo "itemVideoList: $itemVideoList"
	#echo ""
	#echo "itemVideoList1: $itemVideoList1"
	#echo "itemVideoList2: $itemVideoList2"
	#echo ""
	#echo "itemDuration: $itemDuration"
	#echo "itemImage: $itemImage"
	#echo "itemLegacyID: $itemLegacyID"
	#echo "itemPubDate: $itemPubDate"
	#echo ""
	#echo "itemPreview: $itemPreview"
	#echo "itemThumbnail: $itemThumbnail"
	#echo "itemThumbnailBig: $itemThumbnailBig"
	#echo "itemVTT: $itemVTT"
	#echo "itemShortLink: $itemShortLink"
	#echo "itemShortLinkID: $itemShortLinkID"
	#read pause

}


createOutputFiles(){

	case "$1" in

		"plaintext")

		# If pubDate is BLANK, then the url is INVALID
		case "$itemPubDate" in
		
			"")
				
			;;

			*)
			echo "">>"/$PWD/dump-plaintext.txt"
			echo "itemTitle: $itemTitle">>"/$PWD/dump-plaintext.txt"
			echo "itemWebLink: $itemWebLink">>"/$PWD/dump-plaintext.txt"
			echo "itemPlaylist: $itemPlaylist">>"/$PWD/dump-plaintext.txt"
			echo "itemAudio: $itemAudio">>"/$PWD/dump-plaintext.txt"
			echo "itemVideoList: $itemVideoList">>"/$PWD/dump-plaintext.txt"
			echo "itemVideoList1: $itemVideoList1">>"/$PWD/dump-plaintext.txt"
			echo "itemVideoList2: $itemVideoList2">>"/$PWD/dump-plaintext.txt"
			echo "itemDuration: $itemDuration">>"/$PWD/dump-plaintext.txt"
			echo "itemImage: $itemImage">>"/$PWD/dump-plaintext.txt"
			echo "itemLegacyID: $itemLegacyID">>"/$PWD/dump-plaintext.txt"
			echo "itemPubDate: $itemPubDate">>"/$PWD/dump-plaintext.txt"
			echo "itemPreview: $itemPreview">>"/$PWD/dump-plaintext.txt"
			echo "itemThumbnail: $itemThumbnail">>"/$PWD/dump-plaintext.txt"
			echo "itemThumbnailBig: $itemThumbnailBig">>"/$PWD/dump-plaintext.txt"
			echo "itemVTT: $itemVTT">>"/$PWD/dump-plaintext.txt"
			echo "itemShortLink: $itemShortLink">>"/$PWD/dump-plaintext.txt"
			echo "itemShortLinkID: $itemShortLinkID">>"/$PWD/dump-plaintext.txt"
			echo "">>"/$PWD/dump-plaintext.txt"
			;;

		esac
		;;

		"html")
		echo ""
		;;

		"xml")

		# This is a template to match (from Kodi plugin.video.cinemassacre)

		# <item id="1392" activeInd="Y">
		# <title>AVGN: Transformers</title>
		# <link>http://cinemassacre.com/2009/06/17/transformers/</link>
		# <pubDate>Wed, 17 Jun 2009 12:55:44 -0400</pubDate>
		# <id>1392</id>
		# <!-- <movieURL>Cinemassacre-1392</movieURL> -->
		# <movieURL>2NsS1EPl</movieURL>
		# <description>Episode 71: Transformers</description>
		# <smallThumbnail>http://cinemassacre.com/wp-content/uploads/2009/06/072-Transformers.jpg</smallThumbnail>
		# <duration>764</duration>
		# <categories>
		#  <category id="402" activeInd="Y"/>
		#  <category id="1065" activeInd="Y"/>
		#  <category id="18" activeInd="Y"/>
		#  <category id="422" activeInd="Y"/>
		#  <category id="7" activeInd="Y"/>
		# </categories>
		# </item>

		# If pubDate is BLANK, then the url is INVALID
		case "$itemPubDate" in
		
			"")
				
			;;

			*)
			# Build XML for Kodi plugin
			echo "<item id=\"$itemShortLinkID\" activeInd=\"Y\">">>"/$PWD/dump-xml.xml"
			echo "<title>$itemTitleXML</title>">>"/$PWD/dump-xml.xml"
			echo "<link>$itemWebLink</link>">>"/$PWD/dump-xml.xml"
			echo "<pubDate>$itemPubDate</pubDate>">>"/$PWD/dump-xml.xml"
			echo "<id>$itemShortLinkID</id>">>"/$PWD/dump-xml.xml"
			echo "<movieURL>$mediaID</movieURL>">>"/$PWD/dump-xml.xml"
			echo "<description>$itemTitleXML</description>">>"/$PWD/dump-xml.xml"
			echo "<smallThumbnail>$itemThumbnail</smallThumbnail>">>"/$PWD/dump-xml.xml"
			echo "<duration>$itemDuration</duration>">>"/$PWD/dump-xml.xml"
			echo "<categories>">>"/$PWD/dump-xml.xml"
			echo "<category id=\"402\" activeInd=\"Y\"/>">>"/$PWD/dump-xml.xml"
			echo "<category id=\"1065\" activeInd=\"Y\"/>">>"/$PWD/dump-xml.xml"
			echo "</categories>">>"/$PWD/dump-xml.xml"
			echo "</item>">>"/$PWD/dump-xml.xml"
			echo "">>"/$PWD/dump-xml.xml"
			;;

		esac
		;;

	esac

}


openWebSite(){

	$browser $webpageMain &

}


checkVideoType(){

	echo "THIS IS checkVideoType LANDING"
	read pause

}



buildLinks(){

	hookDirect="$hookJWPlatformJS"
	ext="$extJWPlatform"
	extPre="js"

	urlPre="$hook$mediaID-$pid.$extPre"
	echo "$urlPre">"/tmp/urlPre.tmp"

	urlNew="$hookDirect$mediaID.$ext"


	#echo "$urlPre"
	#echo "$urlNew"
	#read pause
}


getVideoName(){

	videoName=$(echo $url | cut -d "/" -f7)

}



getNewFilename(){

	#cleanTemp

	getVideoName

	banner

	echo "Original URL: $url"
	echo ""
	echo "Media ID: $mediaID"
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
	#echo "Press ENTER with no input to use default filename: capture-$mediaID.$ext"
	echo ""
	echo ""



	read newFilename

	case "$newFilename" in

		"")

		banner

		echo "Original URL: $url"
		echo ""
		echo "Media ID: $mediaID"
		echo ""
		echo "Saving as: ""$videoName.$ext"
		#echo "Saving as: ""capture-$mediaID.$ext"
		echo ""
		echo ""
		newFilename=$(echo "$videoName")
		#newFilename=$(echo "capture-$mediaID")
		wget -O "$newFilename.$ext" "$directLink"
		;;

		"r" | "R")
		menuMain
		;;

		*)

		banner

		echo "Original URL: $url"
		echo ""
		echo "Media ID: $mediaID"
		echo ""
		echo "Saving as: ""$newFilename.$ext"
		echo ""
		echo ""
		wget -O "$newFilename.$ext" "$directLink"
		;;

	esac

}


readLinksToList(){

	banner
	echo "Building Link List...."
	echo ""
	echo ""

	inList="$1"
	outFile="$2"

	#echo "$inList"
	#read pause

	ListPagesTemp=$(lynx -listonly -dump "$inList")


	getList2005=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2005/" | grep -v category)
	getList2006=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2006/" | grep -v category)
	getList2007=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2007/" | grep -v category)
	getList2008=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2008/" | grep -v category)
	getList2009=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2009/" | grep -v category)
	getList2010=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2010/" | grep -v category)
	getList2011=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2011/" | grep -v category)
	getList2012=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2012/" | grep -v category)
	getList2013=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2013/" | grep -v category)
	getList2014=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2014/" | grep -v category)
	getList2015=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2015/" | grep -v category)
	getList2016=$(echo "$ListPagesTemp" | sed '1,3d' | cut -c 7- | grep "/2016/" | grep -v category)

	ListPages=$(echo "$getList2005"$'\n'"$getList2006"$'\n'"$getList2007"$'\n'"$getList2008"$'\n'"$getList2009"$'\n'"$getList2010"$'\n'"$getList2011"$'\n'"$getList2012"$'\n'"$getList2013"$'\n'"$getList2014"$'\n'"$getList2015"$'\n'"$getList2016" | sort -u)

	echo "$ListPages" >> "$outFile"

}






cleanTemp(){

	if [ -e "/tmp/url.tmp" ]; then
		rm "/tmp/url.tmp"
	fi

	if [ -e "/tmp/urlPre.tmp" ]; then
		rm "/tmp/urlPre.tmp"
	fi

	if [ -e "/tmp/dump.html" ]; then
		rm "/tmp/dump.html"
	fi

	if [ -e "/tmp/dump.js" ]; then
		rm "/tmp/dump.js"
	fi

	if [ -e "/tmp/tmp_hook" ]; then
		rm "/tmp/tmp_hook"
	fi

	if [ -e "/tmp/tmp_hookType" ]; then
		rm "/tmp/tmp_hookType"
	fi

	if [ -e "/tmp/tmp_hookText" ]; then
		rm "/tmp/tmp_hookText"
	fi

	if [ -e "/tmp/configJWP" ]; then
		rm "/tmp/configJWP"
	fi

	if [ -e "/tmp/tmp_mediaID" ]; then
		rm "/tmp/tmp_mediaID"
	fi

	if [ -e "/tmp/tmp_mediaID" ]; then
		rm "/tmp/tmp_shortLink"
	fi

	if [ -e "/tmp/tmp_mediaID" ]; then
		rm "/tmp/tmp_shortLinkID"
	fi

	if [ -e "/tmp/tmp_pid" ]; then
		rm "/tmp/tmp_pid"
	fi


	# This file is ONLY created if mediaID is not available and default name is used, resulting in a zero-byte file	
	if [ -e "capture-.$ext" ]; then
		rm "capture-.$ext"
	fi

	

	banner

}


cleanOutput(){

	if [ -e "/$PWD/dump-plaintext.txt" ]; then
		rm "/$PWD/dump-plaintext.txt"
	fi

	if [ -e "/$PWD/dump-xml.xml" ]; then
		rm "/$PWD/dump-xml.xml"
	fi
}


cleanExit(){

	cleanTemp

	clear
	echo "Cinemassacre Video Dumping Script v$scriptVersion Has Closed Gracefully ;)"
	echo ""
	echo ""
	echo "Visit https://github.com/esc0rtd3w To View All Projects"
	echo ""
	echo ""
	
	exit
}


setWindowTitle
setDefaults
resizeWindow

setDefaultHook
menuMain




