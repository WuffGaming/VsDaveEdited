# HOW 2 COMPILE:

Run THESE commands after installing Haxe 4.3.7 & Git:

haxelib --global install hmm
haxelib --global run hmm setup
hmm install (NOTE DONT COPY: IF YOU RUN INTO AN ERROR, RERUN THE COMMAND!)
haxelib run lime rebuild cpp -clean
haxelib run lime setup
lime rebuild extension-webm windows

You should be able to build with "Lime Test Windows" and enjoy!

IF YOU RUN INTO LIME-RELATED ISSUES: 
If it's a submodule issue, your path is probably too long for your operating system. Move the entire project to a shorter path and reinstall Lime.