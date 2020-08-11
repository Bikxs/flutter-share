#Generate debug google signatures

#windows
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore

#linux
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore