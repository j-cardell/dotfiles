function discvid
    set -l input $argv[1]
    set -l dir (dirname (realpath $input))
    set -l base (path change-extension "" -- (path basename -- $input))
    set -l output "$dir/$base"_discord.webm

    # 1. Get duration and calculate bitrate
    set -l duration (ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $input)
    set -l total_bitrate (math "65000 / $duration")
    set -l video_bitrate (math "min(7000, $total_bitrate - 64)")

    echo "Encoding: $base at $video_bitrate kbps..."

    # 2. Encode
    ffmpeg -i $input \
        -c:v libsvtav1 -preset 6 \
        -svtav1-params "rc=1:tbr=$video_bitrate:tune=0:film-grain=4" \
        -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1" \
        -c:a libopus -b:a 64k \
        -map_metadata -1 -movflags +faststart -y $output

    if test $status -eq 0
        set -l final_bytes (stat -c %s $output)
        
        if test $final_bytes -le 10000000
            #Copy the URI list so Discord treats it as a file upload
            echo "file://$output" | wl-copy --type text/uri-list
            
            notify-send -i video-x-generic "Encoding Success" "Ready to paste! (Size: "(math -s1 $final_bytes / 1000000)"MB)"
            echo "Success! Path copied as URI. Try Ctrl+V in Discord."
        else
            notify-send -u critical "Encoding Failed" "Still too large: "(math -s1 $final_bytes / 1000000)"MB"
        end
    else
        notify-send -u critical "FFmpeg Error" "Conversion crashed."
    end
end