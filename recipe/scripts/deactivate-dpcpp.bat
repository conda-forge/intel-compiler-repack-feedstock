rem Only restore LIB if this env's activation saved it; otherwise (e.g. the package was
rem installed into an already active env) leave the caller's LIB untouched.
if defined _CONDA_DPCPP_LIB_SET set "LIB=%_CONDA_DPCPP_BACKUP_LIB%"
set "_CONDA_DPCPP_BACKUP_LIB="
set "_CONDA_DPCPP_LIB_SET="
