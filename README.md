# SaphyraOS
SaphyraOS will be a simple OS, only for me to learn the basic about OS Development

## Steps to create a fat32 image
```bash
fallocate -l 256M disk_image.img
```

```bash
mformat -v SaphyraOS -F -i disk_image.img
```

## Steps to build bootsector
```bash
nasm -fbin bootloader/bootsector.asm -o bin/bootsector
```

## Steps to build saphyra_fs
```bash
cd tools/saphyra_fs
gcc main.c -o saphyra_fs
mv saphyra_fs ../../saphyra_fs
cd ../../
```

## Steps to put bootsector into fat32.bootcode
```bash
./saphyra_fs disk_image.img --bootcode 'bin/bootsector'
```

## Run it with Qemu
```bash
qemu-system-x86_64 -drive format=raw,file=disk_image.img
```
