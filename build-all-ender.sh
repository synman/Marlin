#!/bin/zsh
set -e -o pipefail

home="$(echo ~)"
curdir="$(pwd)"
origbranch="$(git rev-parse --abbrev-ref HEAD)"

piohome="$curdir/.pio"
buildhome="$curdir/.pio/build"
noclean=0

declare -a branches=($origbranch)

if [ "$1" = "--all_branches" ]
then
    declare -a branches=(bugfix-2.1.x 2.1.2-ender-3-s1 2.0.8-ender-3-s1)
fi

if [ "$1" = "--no_clean" ]
then
    noclean=1
fi

declare -a f1_build_variants=(STM32F103RE_creality_s1pro_abl STM32F103RE_creality_s1pro_ubl25 STM32F103RE_creality_s1pro_ubl100 STM32F103RE_creality_s1plus_abl STM32F103RE_creality_s1plus_ubl25 STM32F103RE_creality_s1plus_ubl100)
declare -a f4_build_variants=(STM32F401RC_creality_s1pro_abl STM32F401RC_creality_s1pro_ubl25 STM32F401RC_creality_s1pro_ubl100 STM32F401RC_creality_s1plus_abl STM32F401RC_creality_s1plus_ubl25 STM32F401RC_creality_s1plus_ubl100)

for branch in "${branches[@]}"
do
    git checkout $branch

    # delete our .pio directory and cleanall
    if [ "$noclean" = "0" ]
    then
        rm -rf $piohome
        pio run -t cleanall

        #let things settle down
        sleep 15
    fi

    # build our F1 chip variants
    for variant in "${f1_build_variants[@]}"
    do
        if [ "$noclean" = "0" ]
        then
            rm -rf $buildhome/$variant
            pio run -e $variant -t clean
        fi
        pio run -e $variant
    done

    # build our F4 chip variants
    for variant in "${f4_build_variants[@]}"
    do
        if [ "$noclean" = "0" ]
        then
            rm -rf $buildhome/$variant
            pio run -e $variant -t clean
        fi
        pio run -e $variant
    done

    # prep our destination for magic
    firmhome="$home/Documents/GitHub/Ender-3-S1-Pro-Firmware/$branch"

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
done

# reset our branch if it changed
git checkout $origbranch

# delete our .pio directory and cleanall
if [ "$noclean" = "0" ]
then
    rm -rf $piohome
    pio run -t cleanall
fi

echo " "
echo "Build Completed Successfully!"
echo " "