if test $(id -u) -ge 1000 &&\
   test -d $HOME/.local/bin
then
	append_path $HOME/.local/bin
fi

