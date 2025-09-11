#!/bin/bash

BOT_TOKEN="7057824626:AAFsKVHbRmHYBN_GzR_xegcW7iu7zdvxfEM"
CHAT_ID="-4904715921"

HOME="$(pwd)"
ZIP_NAME="A22-$(date +%Y%m%d-%H%M).zip"
OUT_IMG="$HOME/out/arch/arm64/boot/Image.gz"
ANYKERNEL="$HOME/AnyKernel3"

cp "$OUT_IMG" "$ANYKERNEL/"
cd "$ANYKERNEL" || exit 1
zip -r9 "$ZIP_NAME" * > /dev/null
rm -f Image.gz

DATE=$(date +"%d-%m-%Y %H:%M")

if [ -f "$OUT_IMG" ]; then
  KERNEL_VER=$(gzip -dc "$OUT_IMG" \
                | strings \
                | grep -m1 "Linux version" )
else
  KERNEL_VER="Unknown"
fi

CAPTION="*A22-$DATE*
\`\`\`
LocalVersion :
$KERNEL_VER
\`\`\`
*Flash via TWRP only*
"

curl -F document=@"$ZIP_NAME" \
     -F "chat_id=$CHAT_ID" \
     -F "caption=$CAPTION" \
     -F "parse_mode=Markdown" \
     https://api.telegram.org/bot$BOT_TOKEN/sendDocument
cd $ANYKERNEL
rm -rf $ZIP_NAME
cd $HOME
