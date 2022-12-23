from kepocnhh/debian-amd64:3

env USER=foo
run useradd $USER
run mkdir -p /home/$USER
run chown -R $USER:$USER /home/$USER
workdir /home/$USER
user $USER

copy ex/util/mkdirs ex/util/mkdirs
copy internal/check/ex/util/mkdirs/check.sh .

cmd ./check.sh
