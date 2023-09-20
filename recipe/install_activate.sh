# Name this script starting with `~` so it is run after all other compiler activation scripts.
mkdir -p "${PREFIX}/etc/conda/activate.d"
sed "s/@HOST@/x86_64-conda-linux-gnu/g" "${RECIPE_DIR}/scripts/activate-dpcpp.sh" > "${PREFIX}/etc/conda/activate.d/~activate-dpcpp.sh"
cat "${PREFIX}/etc/conda/activate.d/~activate-dpcpp.sh"
