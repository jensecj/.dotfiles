#!/usr/bin/env bash

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## If the option `use_preview_script` is set to `true`,
## then this script will be called and its output will be displayed in ranger.
## ANSI color codes are supported.
## STDIN is disabled, so interactive scripts won't work properly

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade ranger.

## Because of some automated testing we do on the script #'s for comments need
## to be doubled up. Code that is commented out, because it's an alternative for
## example, gets only one #.

## Meanings of exit codes:
## code | meaning    | action of ranger
## -----+------------+-------------------------------------------
## 0    | success    | Display stdout as preview
## 1    | no preview | Display no preview at all
## 2    | plain text | Display the plain content of the file
## 3    | fix width  | Don't reload when width changes
## 4    | fix height | Don't reload when height changes
## 5    | fix both   | Don't ever reload
## 6    | image      | Display the image `$IMAGE_CACHE_PATH` points to as an image preview
## 7    | image      | Display the file directly as an image

## Script arguments
FILE_PATH="${1}"         # Full path of the highlighted file
PV_WIDTH="${2}"          # Width of the preview pane (number of fitting characters)
## shellcheck disable=SC2034 # PV_HEIGHT is provided for convenience and unused
PV_HEIGHT="${3}"         # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH="${4}"  # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}"  # 'True' if image previews are enabled, 'False' otherwise.

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"

## Settings
HIGHLIGHT_SIZE_MAX=262143  # 256KiB
HIGHLIGHT_TABWIDTH="${HIGHLIGHT_TABWIDTH:-8}"
HIGHLIGHT_STYLE="${HIGHLIGHT_STYLE:-pablo}"
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE="${PYGMENTIZE_STYLE:-autumn}"
OPENSCAD_IMGSIZE="${RNGR_OPENSCAD_IMGSIZE:-1000,1000}"
OPENSCAD_COLORSCHEME="${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}"

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo| \
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
            atool --list -- "${FILE_PATH}" && exit 5
            bsdtar --list --file "${FILE_PATH}" && exit 5
            exit 1;;

        patch)
            bat -- "${FILE_PATH}" && exit 5
            exit 2;;

        torrent)
            transmission-show -- "${FILE_PATH}" && exit 5
            exit 1;;

        xlsx)
            ## https://github.com/dilshod/xlsx2csv
            xlsx2csv -- "${FILE_PATH}" && exit 5
            exit 1;;

        htm|html|xhtml)
            # lynx -dump -- "${FILE_PATH}" && exit 5
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            ;;

        json|ipynb)
            jq --color-output . "${FILE_PATH}" && exit 5
            python -m json.tool -- "${FILE_PATH}" && exit 5
            ;;
    esac
}

handle_image() {
    local DEFAULT_SIZE="1920x1080"

    local mimetype="${1}"
    case "${mimetype}" in
        image/svg+xml|image/svg)
            convert -- "${FILE_PATH}" "${IMAGE_CACHE_PATH}" && exit 6
            exit 7;;

        # image/vnd.djvu)
        #     ddjvu -format=tiff -quality=90 -page=1 -size="${DEFAULT_SIZE}" \
        #           - "${IMAGE_CACHE_PATH}" < "${FILE_PATH}" \
        #           && exit 6 || exit 1;;

        image/*)
            local orientation
            orientation="$( identify -format '%[EXIF:Orientation]\n' -- "${FILE_PATH}" )"
            ## If orientation data is present and the image actually
            ## needs rotating ("1" means no rotation)...
            if [[ -n "$orientation" && "$orientation" != 1 ]]; then
                ## ...auto-rotate the image according to the EXIF data.
                convert -- "${FILE_PATH}" -auto-orient "${IMAGE_CACHE_PATH}" && exit 6
            fi

            exit 7;;

        video/*)
            ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}" -s 0 && exit 6
            ffmpeg -i "${FILE_PATH}" -map 0:v -map -0:V -c copy "${IMAGE_CACHE_PATH}" && exit 6
            exit 1;;

        application/pdf)
            pdftoppm -f 1 -l 1 \
                     -scale-to-x "${DEFAULT_SIZE%x*}" \
                     -scale-to-y -1 \
                     -singlefile \
                     -jpeg -tiffcompression jpeg \
                     -- "${FILE_PATH}" "${IMAGE_CACHE_PATH%.*}" \
                && exit 6 || exit 1;;

        application/epub+zip|application/x-mobipocket-ebook)
            gnome-epub-thumbnailer -s "${DEFAULT_SIZE%x*}" "${FILE_PATH}" "${IMAGE_CACHE_PATH}" && exit 6
            exit 1;;

        application/font*|application/*opentype)
            preview_png="/tmp/$(basename "${IMAGE_CACHE_PATH%.*}").png"
            if fontimage -o "${preview_png}" \
                         --pixelsize "120" \
                         --fontname \
                         --pixelsize "80" \
                         --text "  ABCDEFGHIJKLMNOPQRSTUVWXYZ  " \
                         --text "  abcdefghijklmnopqrstuvwxyz  " \
                         --text "  0123456789.:,;(*!?') ff fl fi ffi ffl  " \
                         --text "  The quick brown fox jumps over the lazy dog.  " \
                         "${FILE_PATH}";
            then
                convert -- "${preview_png}" "${IMAGE_CACHE_PATH}" \
                    && rm "${preview_png}" \
                    && exit 6
            else
                exit 1
            fi
            ;;
    esac
}

handle_mime() {
    local mimetype="${1}"
    case "${mimetype}" in
        text/rtf|*msword)
            ## note: catdoc does not always work for .doc files
            ## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
            catdoc -- "${FILE_PATH}" && exit 5
            exit 1;;

        *wordprocessingml.document)
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            exit 1;;

        message/rfc822)
            cat -- "${FILE_PATH}" && exit 5
            exit 1;;

        *ms-excel)
            ## xls2csv comes with catdoc:
            ##   http://www.wagner.pp.ru/~vitus/software/catdoc/
            xls2csv -- "${FILE_PATH}" && exit 5
            exit 1;;

        text/* | */xml)
            if [[ "$( stat --printf='%s' -- "${FILE_PATH}" )" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
                exit 2
            fi
            env COLORTERM=8bit bat --color=always --style="plain" -- "${FILE_PATH}" && exit 5
            exit 2;;

        image/vnd.djvu)
            djvutxt "${FILE_PATH}" | fmt -w "${PV_WIDTH}" && exit 5
            exiftool "${FILE_PATH}" && exit 5
            exit 1;;

        image/*)
            mediainfo -- "${FILE_PATH}" && exit 0
            # viu -- "${FILE_PATH}" && exit 4
            exit 1;;

        video/* | audio/*)
            mediainfo "${FILE_PATH}" && exit 5
            exit 1;;
    esac
}

handle_fallback() {
    echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit 5
    exit 1
}


MIMETYPE="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"
if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
    handle_image "${MIMETYPE}"
fi

handle_extension
handle_mime "${MIMETYPE}"
handle_fallback

exit 1
