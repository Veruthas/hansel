# **hansel**
*Bash script for logging and retracing an arch installation.*  
  
####__hansel__ {options}  
  
### **OPTIONS**
##### BASIC
* __do__ <command>
* __if__ <condition> ...
* __ask__ <prompt> -y|-n ...
* __pause__ <prompt>
* ___ignore___ *<will be used in next version>*

##### VARS
variables can be accessed using the __VAR__ function in do/if/set
* __vars__ {name}
* __set__ [--from <command> | --as <value>] {name}
* __unset__ {name}
* __on__ <name> ...

##### ARCH
* __install__ <package> [--confirm]
* __aur__ <package> [--force | --version #] [--confirm]
* __sync__ [YYYY/MM/DD]
* __category__ <name>

##### TRACE
* __trace__ [file]

##### SETTINGS
* __path__ [var | cache] [path_name]

### **TODO**
* Implement Logging (the second main point of hansel)
* Implement help libary for options
* Try to implement interactive mode for each option