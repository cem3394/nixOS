cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 enc-pv
pvcreate /dev/mapper/enc-pv
vgcreate vg /dev/mapper/enc-pv
lvcreate -n swap vg -L 8G
lvcreate -n root vg -l 100%FREE
mkfs.vfat -n BOOT /dev/nvme0n1p1
mkfs.ext4 -L root /dev/vg/root
mkswap -L swap /dev/vg/swap
mount /dev/vg/root /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/vg/swap
nixos-generate-config --root /mnt

export $REMOTE_DESKTOP_CONF ='https://gist.githubusercontent.com/cem3394'

# enable wifi first
curl $REMOTE_DESKTOP_CONF > /mnt/etc/nixos/desktop-configuration.nix

# include desktop-configuration and checks the other configuration options
vim /mnt/etc/nixos/configuration.nix
nixos-install
reboot
