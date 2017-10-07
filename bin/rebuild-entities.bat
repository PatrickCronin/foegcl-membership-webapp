echo Rebuilding Legacy entities
call dbicdump etc\dbicdump-legacy.conf
echo Rebuilding WebApp entities
call dbicdump etc\dbicdump-webapp.conf