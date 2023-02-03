#!/bin/zsh

branch="$(git rev-parse --abbrev-ref HEAD)"
buildhome="/Users/shell/Documents/GitHub/Marlin/.pio/build"
firmhome="/Users/shell/Documents/GitHub/Ender-3-S1-Pro-Firmware/$branch"
curdir="$(pwd)"

declare -a f1_build_variants=(STM32F103RE_creality_s1pro_abl STM32F103RE_creality_s1pro_ubl STM32F103RE_creality_s1plus_abl STM32F103RE_creality_s1plus_ubl)
declare -a f4_build_variants=(STM32F401RC_creality_s1pro_abl STM32F401RC_creality_s1pro_ubl STM32F401RC_creality_s1plus_abl STM32F401RC_creality_s1plus_ubl)

for variant in "${f1_build_variants[@]}"
do
    rm -rf $buildhome/$variant
    pio run -e $variant
done

for variant in "${f4_build_variants[@]}"
do
    rm -rf $buildhome/$variant
    pio run -e $variant
done

rm -rf $firmhome
mkdir -p $firmhome
cd $firmhome

for variant in "${f1_build_variants[@]}"
do
    mkdir -p $firmhome/$variant
    cp $buildhome/$variant/*.bin $firmhome/$variant/
    zip -rm $variant.zip $variant
done

for variant in "${f4_build_variants[@]}"
do
    mkdir -p $firmhome/$variant/STM32F4_UPDATE
    cp $buildhome/$variant/*.bin $firmhome/$variant/STM32F4_UPDATE/
    zip -rm $variant.zip $variant
done

cd $curdir

