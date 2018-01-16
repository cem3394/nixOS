cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 enc-pv
pvcreate /dev/mapper/enc-pv
vgcreate vg /dev/mapper/enc-pv

# The lvcreate commands create the logical partitions. The first is a 20GB swap drive. 
# The laptop has 16GB of memory so I set this to be enough to store all of memory when hibernating plus extra. 
# It could be made quite a bit smaller.
lvcreate -n swap vg -L 20G
lvcreate -n root vg -l 100%FREE

# Format partitions
mkfs.fat /dev/nvme0n1p1
mkfs.ext4 -L root /dev/vg/root
mkswap -L swap /dev/vg/swap

# Mount partitions
mount /dev/vg/root /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/vg/swap

# Create config file
nixos-generate-config --root /mnt

# Enable wifi first
curl https://raw.githubusercontent.com/cem3394/nixOS/master/configuration.nix > /mnt/etc/nixos/desktop-configuration.nix

# include desktop-configuration and checks the other configuration options
# vim /mnt/etc/nixos/configuration.nix
# nixos-install
# reboot
