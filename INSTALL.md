# Install

The following is a brief installation tutorial for [Arch Linux][1]. It assumes
familiarity with the Arch [Installation Guide][3].

This Guide is aimed at a system that uses UEFI. We will also use a nvme dive as
our main storage disk. If you use a ssd you may need to change the path in some
cases from '/dev/nvme0n1' to something like '/dev/sda'.

## Start

Boot into the Arch installer.

If you use a different Keyboradlayout like me, set your layout.

    $ loadkeys de_CH-latin1

If your console font is tiny ([HiDPI][4] systems), set a new font.

    $ setfont sun12x22

Connect to the Internet.

Verify that the [system clock is up to date][5].

    $ timedatectl set-ntp true

## Partitioning

Create partitions for EFI, boot, and root.

    $ parted -s /dev/nvme0n1 mklabel gpt
    $ parted -s /dev/nvme0n1 mkpart primary fat32 1MiB 513MiB
    $ parted -s /dev/nvme0n1 set 1 boot on
    $ parted -s /dev/nvme0n1 set 1 esp on
    $ parted -s /dev/nvme0n1 name 1 boot

    $ parted -s /dev/nvme0n1 mkpart primary 513MiB 4609MiB
    $ parted -s /dev/nvme0n1 name 2 swap

    $ parted -s /dev/nvme0n1 mkpart primary 4609MiB 100%
    $ parted -s /dev/nvme0n1 name 3 root

    $ mkfs.vfat -F32 /dev/nvme0n1p1
    $ mkfs.ext4 /dev/nvme0n1p3

    $ mkswap /dev/nvme0n1p3
    $ swapon /dev/nvme0n1p3

## Mount the file systems

Mount the file system on the root partition to `/mnt`, for example:

    $ mount /dev/nvme0n1p3 /mnt
    
Create mount points for any remaining partitions and mount them accordingly:

    $ mkdir /mnt/boot
    $ mount /dev/nvme0n1p1 /mnt/boot

## Select the mirrors

Install the [reflector][6] package.

    $ pacman -Syy reflector

Grab the latest mirrorlist for your country

    $ reflector --latest 200 --protocol http --protocol https --sort rate --country Germany --country Switzerland --save /etc/pacman.d/mirrorlist

## Install the base packages

Use the pacstrap script to install the base package group.

    $ pacstrap /mnt base base-devel
    $ pacman -S intel-ucode

Generate an fstab file.

    $ genfstab -U /mnt >> /mnt/etc/fstab


Change root into the base install and perform [base configuration tasks][7].

    $ arch-chroot /mnt
    $ export LANG=en_US.UTF-8
    $ echo $LANG UTF-8 >> /etc/locale.gen
    $ locale-gen
    $ echo LANG=$LANG > /etc/locale.conf
    $ ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
    $ hwclock --systohc --utc
    $ echo curie.rhwilr.ch > /etc/hostname
    $ systemctl enable dhcpcd@eno1.service
    $ passwd

Install systemd-boot

    $ bootctl --path=/boot install

    $ echo "default  arch" > /boot/loader/loader.conf
    $ echo "timeout  2" > /boot/loader/loader.conf
    $ echo "console-mode max" > /boot/loader/loader.conf
    $ echo "editor   no" > /boot/loader/loader.conf

    $ echo "title   Arch Linux" > /boot/loader/entries/arch.conf
    $ echo "linux   /vmlinuz-linux" > /boot/loader/entries/arch.conf
    $ echo "initrd  /intel-ucode.img" > /boot/loader/entries/arch.conf
    $ echo "initrd  /initramfs-linux.img" > /boot/loader/entries/arch.conf
    $ echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p3) rw" >> /boot/loader/entries/arch.conf


Cleanup and reboot!

    $ exit
    $ umount -R /mnt
    $ reboot


Run ansible!


[1]: https://www.archlinux.org/ 
[3]: https://wiki.archlinux.org/index.php/Installation_guide 
[4]: https://wiki.archlinux.org/index.php/HiDPI
[5]: https://wiki.archlinux.org/index.php/Installation_guide#Update_the_system_clock
[6]: https://wiki.archlinux.org/index.php/reflector
[7]: https://wiki.archlinux.org/index.php/Installation_guide#Configure_the_system