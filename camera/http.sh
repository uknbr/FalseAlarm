for p in $(pgrep -f "m SimpleHTTPServer $1") ; do kill -9 ${p} ; done
nohup python2 -m SimpleHTTPServer $1 </dev/null >/dev/null 2>&1 &
echo -e "[0] http  | $(date +'%D %T')"
