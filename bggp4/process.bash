OUT=./out
echo -n > $OUT
for dir in */; do
  # Find files
  TEMPLATE=$dir/template
  SOURCE=$dir/source*
  FOUR=$dir/*4
  echo $TEMPLATE $SOURCE $FOUR
  # Check if SHA of FOUR and SOURCE match
  SHA_SOURCE=$(sha256sum $SOURCE | awk '{print $1}')
  SHA_FOUR=$(sha256sum $FOUR | awk '{print $1}')
  if [ ! "$SHA_SOURCE" = "$SHA_FOUR" ]; then
    echo "SHA mismatch"
    exit 1
  fi
  BYTES=$(wc -c < $FOUR) # sloppy hack, only works for ascii but eh they're all ascii
  # b64 encode. Remove newlines and escape slashes
  BASE64=$(base64 $FOUR | sed -e 's/\//\\\//g' | tr -d '\n')
  # Substitute %HASH% and %B64% in template, add size after "info?: " and concat to out
  sed -e "s/%HASH%/$SHA_SOURCE/g" -e "s/%B64%/$BASE64/g" -e "s/info?: /info?: $BYTES bytes. /g" $TEMPLATE >> $OUT
done