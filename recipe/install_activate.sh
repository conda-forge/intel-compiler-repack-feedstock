# Name this script starting with `~` so it is run after all other compiler activation scripts.
mkdir -p "${PREFIX}/etc/conda/activate.d"
if [[ "$target_platform" == "linux-64" ]]; then
  HOST=x86_64-conda-linux-gnu
else
  echo "unknown platform"
  exit 1
fi
if [[ "$PKG_NAME" == "dpcpp_linux-64" ]]; then
  sed "s/@HOST@/$HOST/g" "${RECIPE_DIR}/scripts/activate-dpcpp.sh" > "${PREFIX}/etc/conda/activate.d/~activate-dpcpp.sh"
  cat "${PREFIX}/etc/conda/activate.d/~activate-dpcpp.sh"
fi

if [[ "$PKG_NAME" == "ifx_linux-64" ]]; then
  sed "s/@HOST@/$HOST/g" "${RECIPE_DIR}/scripts/activate-ifx.sh" > "${PREFIX}/etc/conda/activate.d/~activate-ifx.sh"
  cat "${PREFIX}/etc/conda/activate.d/~activate-ifx.sh"
fi
