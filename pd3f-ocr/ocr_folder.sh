#!/usr/bin/env bash
set -x

mkdir -p /to-ocr

while sleep 1; do
    # Use case-insensitive matching and null-delimited paths.
    # This picks up .pdf/.PDF and handles spaces safely.
    while IFS= read -r -d '' f; do
        # unlock PDF is needed
        if qpdf --is-encrypted "$f"; then
            qpdf --decrypt "$f" "$f".2 && mv "$f".2 "$f"
        fi

        echo "$f"
        tfn=$(basename "${f%.*}")
        lang=${tfn##*.}
        # Keep output extension normalized to lowercase so app.py can detect
        # .pdf.done/.pdf.failed/.pdf.log regardless of input extension casing.
        out_base="${f%.*}.pdf"
        done_file="${out_base}.done"
        failed_file="${out_base}.failed"
        log_file="${out_base}.log"
        if ocrmypdf -l "$lang" --pdf-renderer hocr --output-type pdf --clean --skip-text --deskew "$f" "$done_file" &>"$log_file"; then
            rm "$f"
            echo 'success'
        else
            rm -f "$done_file"
            mv "$f" "$failed_file"
            echo 'failed'
        fi
    done < <(find /to-ocr -type f \( -iname "*.pdf" \) -print0)
done
