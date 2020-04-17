#!/bin/bash
# Move photo to a format path
sDir="${1:-/volume1/Others/ALL-In}"
dDir="${2:-/volume1/Others/photos_new}"
mDepth="${3:-2}"
iLog="${dDir}move.csv"
eLog="${dDir}move.err"
declare -A mCode=(["0"]="Created" ["1"]="Exsit" ["2"]="Overwrite" ["3"]="Noneed" ["4"]="Unknow" ["5"]="Failed")
function AddLog(){
        echo "${rCode:-4},$(date +%F\ %T),${sPath},${dPath},${fTime}" >>"${iLog}" 2>>"${eLog}"
        return "${rCode}"
}
touch "${iLog}" "${eLog}"
find "${sDir}" -maxdepth "${mDepth}" ! -path "*@eaDir*" -type f -iname "*.jpg" -o -iname "*.jpeg" -o iname "*.cr2" | while read sPath; do
        unset "rCode" "dPath" "oTime" "fTime"
        grep -q "${sPath}" "${iLog}" && continue || oTime=`exiv2 -q -g Exif.Photo.DateTimeOriginal -P v "${sPath}" 2>>"${eLog}"`
        if [ -z "${oTime}" ]; then
                rCode=3 && AddLog
                continue
        fi
        fTime=$(echo "${oTime}" | sed 's/:/-/;s/:/-/')
        dPath=$(date -d "${fTime}" +"${dDir}%Y/%Y%m%d-%H%M%S.jpg")
        if [ -f "${dPath}" ]; then
                if [ `stat --printf=%s "${dPath}"` -lt `stat --printf=%s "${sPath}"` ]; then
                        cp -v "${sPath}" "${dPath}" 2>>"${eLog}" && rCode=2 || rCode=5
                else
                        rCode=1
                fi
        else
                cp -v "${sPath}" "${dPath}" 2>>"${eLog}" && rCode=0 || rCode=5
        fi
        AddLog
done
