MAKE SURE YOU HAVE ACTUAL GIT FROM http://git-scm.com/ INSTALLED, AND NOT JUST THE WINDOWS GUI.

Mark down what your git.exe root folder is.

For Windows 7 64-bit (like me): C:\Program Files (x86)\Git\cmd

32-bit would be C:\Program Files\Git\cmd

Make sure to edit the PATH environment variable in your Windows settings. Don't worry, this is a lot easier than it sounds.

1. Start Menu. Rightclick My Computer.
2. Hit "Properties."
3. Advanced System Settings.
4. Near the bottom: Environment Variables button.
5. Scroll down till you see "Path."
6. Edit in the folder where your git.exe is, like so: ";C:\Program Files (x86)\Git\cmd" without the quotes.
7. Reboot (or maybe just log in/out) your PC to apply.
8. Your build.cmd should be working.

this is a test
