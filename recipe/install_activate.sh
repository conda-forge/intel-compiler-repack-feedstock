# Name this script starting with `~` so it is run after all other compiler activation scripts.
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/scripts/activate-dpcpp.sh" "${PREFIX}/etc/conda/activate.d/~activate-dpcpp.sh"
