function __fish_complete_p -d "Completions for the p shortcut"
	set -l wd $PWD
	set -l owd $OLDPWD

	for i in "/Volumes/Projects"
		builtin cd $wd
		eval builtin cd $i

		eval printf '"%s\t\n"' '(commandline -ct)'\*/
	end

	builtin cd $wd
	set OLDPWD $owd
end
