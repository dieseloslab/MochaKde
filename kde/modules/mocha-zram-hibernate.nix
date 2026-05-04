{ ... }:

{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 32767;
  };

  boot.resumeDevice = "/dev/disk/by-uuid/b97fcbf3-1eec-4877-a74a-9f585822cf0c";

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    "vm.page-cluster" = 0;
  };
}
