# SaphyraOS
SaphyraOS

## Steps to create a fat32 image
```bash
fallocated -l 256M disk_image.img
```

```bash
mformat -v SaphyraOS -F -i disk_image.img
```

## Steps to put bootsector into fat32.bootcode 
```bash
./saphyra_fs disk_image.img --bootcode 'bin/bootsector'
```

## Qemu Example
```bash
qemu-system-x86_84 -drive format=raw,file=disk_image.img
```
