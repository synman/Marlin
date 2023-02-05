#!/bin/zsh
set -e -o pipefail

home="$(echo ~)"
curdir="$(pwd)"
branch="$(git rev-parse --abbrev-ref HEAD)"

buildhome="$curdir/.pio/build"
firmhome="$home/Documents/GitHub/Ender-3-S1-Pro-Firmware/$branch"

declare -a f1_build_variants=(STM32F103RE_creality_s1pro_abl STM32F103RE_creality_s1pro_ubl STM32F103RE_creality_s1plus_abl STM32F103RE_creality_s1plus_ubl)
declare -a f4_build_variants=(STM32F401RC_creality_s1pro_abl STM32F401RC_creality_s1pro_ubl STM32F401RC_creality_s1plus_abl STM32F401RC_creality_s1plus_ubl)

# delete our build directory (cleanall)
rm -rf $buildhome

# build our F1 chip variants
for variant in "${f1_build_variants[@]}"
do
    rm -rf $buildhome/$variant
    pio run -e $variant -t clean
    pio run -e $variant
done

# build our F4 chip variants
for variant in "${f4_build_variants[@]}"
do
    rm -rf $buildhome/$variant
    pio run -e $variant -t clean
    pio run -e $variant
done

# prep our destination for magic
rm -rf $firmhome
mkdir -p $firmhome
cd $firmhome

# process F1 binaries
for variant in "${f1_build_variants[@]}"
do
    mkdir -p $firmhome/$variant
    cp $buildhome/$variant/*.bin $firmhome/$variant/
    variantshort="$(echo $variant | sed 's/STM32F103RE_creality_/F1-/')" 
    zip -rm $branch-$variantshort.zip $variant
done

# process F4 binaries
for variant in "${f4_build_variants[@]}"
do
    mkdir -p $firmhome/$variant/STM32F4_UPDATE
    cp $buildhome/$variant/*.bin $firmhome/$variant/STM32F4_UPDATE/
    variantshort="$(echo $variant | sed 's/STM32F401RC_creality_/F4-/')" 
    zip -rm $branch-$variantshort.zip $variant
done

cd $curdir

echo 
echo Build Completed Successfully!
echo 