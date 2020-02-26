

#if [ $# -lt 2  ] || [ $# -gt 2  ] ;then
#     echo "Incorrect usage. Use: build.sh <param1> "
#     echo "<param1>: gitlab user"
#     echo "<param2>: gitlab access token"
#     exit 1
#fi


docker build -f Dockerfile -t d-reg.hb.dfki.de/rosbasic/melodic_18.04:latest .

