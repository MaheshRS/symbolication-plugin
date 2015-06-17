# symbolication-plugin

Symbolication project enables `Symbolicate` Xcode plugin. This plugin is available in Product menu and is named 'Symbolicate'.

* Symbolicate Plugin is used to symbolicate crashes. If `dSYM file` and  `crash file` is available, the crash can be symbolicated using the Plugin. 
  
* 1.0 (0.1)


### How do I get set up? ###

* Open the SymbolicationPlugin project
* cmd + k (clean the project)
* cmd + b (build the project)
* Volila the plugin is installed

### How to check if the plugin is installed
* Open Terminal
* Navigate to ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins directory
* Type ls -l
* `SymbolicationPlugin.xcplugin` should be listed in the installed plug-in's list.

### Contribution guidelines ###
Wanna contribute? Great! Fork the repository and send pull request's to the development branch.
