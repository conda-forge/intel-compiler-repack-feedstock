#include <sycl/sycl.hpp>
#include <iostream>

int main(void) {
  std::cout << "SYCL_LANGUAGE_VERSION = "
            << SYCL_LANGUAGE_VERSION
            << std::endl;

  sycl::queue q;
  sycl::device d = q.get_device();

  std::cout << "Device: "
            << d.get_info<sycl::info::device::name>()
            << std::endl;
  std::cout << "Vendor: "
            << d.get_info<sycl::info::device::vendor>()
            << std::endl;
  std::cout << "Driver: [" << d.get_platform().get_backend()
            << "] Version: " << d.get_info<sycl::info::device::driver_version>()
            << std::endl;

  int v[16] = {2, 3, 5, 7,
               11, 13, 17, 19,
               23, 29, 31, 37,
               41, 43, 47, 53};
  int v2[16];
  int *p_shared = sycl::malloc_shared<int>(16, q);
  int *p_device = sycl::malloc_device<int>(16, q);
  int *p_host = sycl::malloc_device<int>(16, q);

  auto e1 = q.copy<int>(&v[0], p_shared, 16);
  auto e2 = q.copy<int>(p_shared, p_device, 16, {e1});
  auto e3 = q.copy<int>(p_device, p_host, 16, {e2});
  auto e4 = q.copy<int>(p_host, &v2[0], 16, {e3});
  e4.wait();

  bool eq = std::equal(std::begin(v2), std::end(v2), std::begin(v));

  sycl::free(p_shared, q);
  sycl::free(p_device, q);
  sycl::free(p_host, q);

  return ((eq) ? 0 : 1);
}
