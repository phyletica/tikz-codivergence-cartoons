#!/bin/bash

set -e

npx="1024"
npixels=$(expr $npx \* $npx)


for tex_path in ../tex/slides*tex
do
    tex_dir="$(dirname $tex_path)"
    tex_file="$(basename $tex_path)"
    file_prefix="${tex_file/\.tex/}"
    pdf_file="${file_prefix}.pdf"
    gif_file="${file_prefix}.gif"
    mp4_file="${file_prefix}.mp4"

    (
        cd "$tex_dir" && \
            latexmk -C "$tex_file" && \
            latexmk -pdf "$tex_file" && \
            rm "$gif_file" && \
            rm "$mp4_file"

        # convert -density 600 "$final_pdf" -flatten -strip -resize @${npixels} -transparent white "PNG8:dpp-3-slide-%02d.png"
        convert -density 600 "$pdf_file" -strip -resize @${npixels} PNG8:${file_prefix}-slide-%02d.png

        shopt -s nullglob
        png_files=(${file_prefix}-slide-??\.png)

        # Create gif from png files
        convert -layers OptimizePlus -delay 125 ${png_files[@]} -delay 200 ${png_files[-1]} -loop 0 "$gif_file"

        rm ${file_prefix}-slide-0?.png

        ffmpeg -f gif -i "$gif_file" "$mp4_file" 

        latexmk -C "$tex_file"
    )
done
