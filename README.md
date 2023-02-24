# SaphyraOS
SaphyraOS will be a simple OS, only for me to learn the basic about OS Development

## Steps to create a fat32 image
```bash
fallocated -l 256M disk_image.img
```

```bash
mformat -v SaphyraOS -F -i disk_image.img
```

## Steps to build bootsector
```bash
nasm -fbin bootloader/bootsector.asm -o bin/bootsector
```

## Steps to put bootsector into fat32.bootcode
```bash
./saphyra_fs disk_image.img --bootcode 'bin/bootsector'
```

## Run it with Qemu
```bash
qemu-system-x86_84 -drive format=raw,file=disk_image.img
```
