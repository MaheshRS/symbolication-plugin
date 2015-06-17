# symbolication-plugin
Symbolication project enables `Symbolicate` Xcode plugin. This plugin is available in Product menu and is named 'Symbolicate'.

* Symbolicate Plugin is used to symbolicate crashes. If `dSYM file` and  `crash file` is available, the crash can be symbolicated using the Plugin. 
* 1.0 (0.1)

![Product Menu][product_menu]

### How do I get set up? ##

* Open the SymbolicationPlugin project
* cmd + k (clean the project)
* cmd + b (build the project)
* ta-da! the plugin is installed

### How to check if the plugin is installed
* Open Terminal
* Navigate to ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins directory
* Type ls -l
* `SymbolicationPlugin.xcplugin` should be listed in the installed plug-in's list.

### Requirements
To use the complete features of the Plugin the following files are required.

* The application bundle (application.app file).
* The dSYM file associated with the build.
* The application unix executable file for the available inside the application.app bundle (application.app/application).

### How to use the Plugin?
Below are the details of using the three sections of the plugin `Symbolicate`, `Details` and `Memory`

#### Symbolicating crash file
Use the `Symbolicate` tab to symbolicate the crash log.

* Select the dSYM file from the disk.
* Select the the crash file from the disk.
* Select Symbolicate. The plugin begins symbolicating the crash.

Note: Additionally you can save the crash file by clicking at the down arrow at the bottom left of the screen.

![Symbolicate][symbolicate]

#### Checking the application details
Used the `Details` tab to get the build information.

* Select the application executable file (Unix executable file) available inside the application.app bundle (application.app/application).
* The details of the application like the build UUID, the build architecture is displayed.

![Details][details]

#### Symbolicating memory references available in the crash file 
Used the `Mmeory` tab to symbolicate memory references

* Select the application executable file (Unix executable file) available inside the application.app bundle (application.app/application).
* List down the memory addresses a single space saperated list.
* Select the architecture (This can be found using the above 'Details' section).
* Select Symbolicate. The Plugin displayes the symbolicated memory reference.

![Memory][memory]

### Contribution guidelines ##
Wanna contribute? Great! Fork the repository and send pull request's to the development branch.

