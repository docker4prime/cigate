# common SSL options for HTTPS vhosts
# -- enable keepalive
keepalive_timeout    70;
# -- prevent BEAST
ssl_ciphers EECDH+AESGCM:EDH+AESGCM:EECDH:EDH:!MD5:!RC4:!LOW:!MEDIUM:!CAMELLIA:!ECDSA:!DES:!DSS:!3DES:!NULL;
ssl_prefer_server_ciphers on;
# -- prevent POODLE
ssl_protocols TLSv1.2;
# -- enable OCSP stapling
ssl_stapling on;
# -- share TLS sessions
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
