# Name this script starting with `~` so it is run after all other compiler activation scripts.
mkdir -p "${PREFIX}/etc/conda/activate.d"
if [[ "$target_platform" == "linux-64" ]]; then
  HOST=x86_64-conda-linux-gnu
else
  echo "unknown platform"
  exit 1
fi
sed "s/@HOST@/$HOST/g" "${RECIPE_DIR}/scripts/activate-dpcpp.sh" > "${PREFIX}/etc/conda/activate.d/~activate-dpcpp.sh"
cat "${PREFIX}/etc/conda/activate.d/~activate-dpcpp.sh"
