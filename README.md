
bash_ini_parser -- Simple INI file parser
=========================================

This is a comfortable and simple INI file parser to be used in
bash scripts.




COPYRIGHT
---------

Copyright (c) 2009 Kevin Porter / Advanced Web Construction Ltd
(http://coding.tinternet.info / http://webutils.co.uk)
Copyright (c) 2010-2014 Ruediger Meier <sweet_f_a@gmx.de>
(https://github.com/rudimeier/)
Copyright (c) 2022-2023 Pablo Lee <pablo.lee@ntxembedded.com>
https://github.com/Pablo-NTX/bash_ini_parser
License: BSD-3-Clause, see LICENSE file




USAGE
-----

You must source the bash file into your script:

> . read_ini.sh

and then use the read_ini function, defined as:

> read_ini INI_FILE [SECTION] [[--booleans|b] [0|1]]

If SECTION is supplied, then only the specified section of the file will
be processed.

After running the read_ini function, variables corresponding to the ini
file entries will be available to you.

INI_ALL

to show all section:
```
echo  ${!INI_ALL[@]}
```

OPTIONS
-------

[--booleans | -b] [0|1]
Whether to interpret special unquoted string values 'yes', 'no', 'true',
'false', 'on', 'off' as booleans.
Default: 1


EXAMPLE
-------

For example, to read and output the variables of this ini file:

-- START test1.[META] file

[model]
model1
model2

[link]
default=xxx2
model1=xxx1

[rename]
default=ren-xxx
model1=ren-xxx1

[chmod]
default=1777,root:root
model2=1777,user:user

-- END test1.[META] file

you could do this:

-- START bash script

. read_ini.sh

read_ini test1.[META]

-- END bash script


to show all section:
```
echo ${!INI_ALL[@]}
```

to check if section exist
```
exist_section INI_ALL model
```
return 1 if '[model]' section exist
otherwise it return 0

to check if key exist
```
exist_key INI_ALL chmod model2
```
return 1 if 'model2' key exist
otherwise it return 0

to get the value:
```
get_value INI_ALL chmod model2
```
it will return the string of the value of key 'model2'





