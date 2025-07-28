#cmdstan path
cmdstanr::set_cmdstan_path("C:/Users/ansle/anaconda3/envs/stan/Library/bin/cmdstan")

#tbb path - check path with Sys.getenv("PATH")
Sys.setenv(PATH = paste(Sys.getenv("PATH"), "C:\\Users\\ansle\\anaconda3\\envs\\stan\\Library\\bin\\cmdstan\\stan\\lib\\stan_math\\lib\\tbb", sep = ";"))

#g++ paths
# in anaconda
# C:\rtools44\x86_64-w64-mingw32.static.posix\bin\g++.exe
# (stan) C:\Users\ansle\anaconda3\envs\stan\Library\bin\cmdstan\examples\bernoulli>g++ --version
# g++ (GCC) 13.3.0
# Copyright (C) 2023 Free Software Foundation, Inc.
# This is free software; see the source for copying conditions.  There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# (stan) C:\Users\ansle\anaconda3\envs\stan\Library\bin\cmdstan\examples\bernoulli>where make
# C:\rtools44\usr\bin\make.exe
# C:\Users\ansle\anaconda3\envs\stan\Library\usr\bin\make.exe

# in R
# "C:\\rtools44\\X86_64~1.POS\\bin\\G__~1.EXE"
# > system("g++ --version")
# G__~1.EXE (GCC) 13.3.0
# Copyright (C) 2023 Free Software Foundation, Inc.
# This is free software; see the source for copying conditions.  There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# > system("where make")
# C:\rtools44\usr\bin\make.exe
# [1] 0
