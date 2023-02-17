#!/bin/bash

SUCCESS=0
FAIL=0
COUNTER=0
DIFF_RES=""
PROGRAM_NAME=$1

declare -a tests=(
"VAR src/test_cat/test_case_cat.txt"
)

declare -a extra=(
"-s src/test_cat/test_1_cat.txt"
"-b -e -n -s -t -v src/test_cat/test_1_cat.txt"
"-t src/test_cat/test_3_cat.txt"
"-n src/test_cat/test_2_cat.txt"
"src/test_cat/no_file.txt"
"-n -b src/test_cat/test_1_cat.txt"
"-s -n -e src/test_cat/test_4_cat.txt"
"-n src/test_cat/test_1_cat.txt"
"-n src/test_cat/test_1_cat.txt src/test_cat/test_2_cat.txt"
"-v src/test_cat/test_5_cat.txt"
)

testing()
{
    t=$(echo $@ | sed "s/VAR/$var/")
    $PROGRAM_NAME $t > src/test_cat/test_cat.log
    cat $t > src/test_cat/test_sys_cat.log
    DIFF_RES="$(diff -s src/test_cat/test_cat.log src/test_cat/test_sys_cat.log)"
    (( COUNTER++ ))
    if [ "$DIFF_RES" == "Files src/test_cat/test_cat.log and src/test_cat/test_sys_cat.log are identical" ]
    then
      (( SUCCESS++ ))
        echo "Fails: $FAIL"
        echo "Success: $SUCCESS"
        echo "Total: $COUNTER"
        echo "Current: success - cat $t"
    else
      (( FAIL++ ))
        echo "Fails: $FAIL"
        echo "Success: $SUCCESS"
        echo "Total: $COUNTER"
        echo "Current: fail - cat $t"
    fi
    rm src/test_cat/test_cat.log src/test_cat/test_sys_cat.log
}

# специфические тесты
for i in "${extra[@]}"
do
    var="-"
    testing $i
done

# 1 параметр
for var1 in b e n s t v
do
    for i in "${tests[@]}"
    do
        var="-$var1"
        testing $i
    done
done

# 2 параметра
for var1 in b e n s t v
do
    for var2 in b e n s t v
    do
        if [ $var1 != $var2 ]
        then
            for i in "${tests[@]}"
            do
                var="-$var1 -$var2"
                testing $i
            done
        fi
    done
done

# 3 параметра
for var1 in b e n s t v
do
    for var2 in b e n s t v
    do
        for var3 in b e n s t v
        do
            if [ $var1 != $var2 ] && [ $var2 != $var3 ] && [ $var1 != $var3 ]
            then
                for i in "${tests[@]}"
                do
                    var="-$var1 -$var2 -$var3"
                    testing $i
                done
            fi
        done
    done
done

# 4 параметра
for var1 in b e n s t v
do
    for var2 in b e n s t v
    do
        for var3 in b e n s t v
        do
            for var4 in b e n s t v
            do
                if [ $var1 != $var2 ] && [ $var2 != $var3 ] \
                && [ $var1 != $var3 ] && [ $var1 != $var4 ] \
                && [ $var2 != $var4 ] && [ $var3 != $var4 ]
                then
                    for i in "${tests[@]}"
                    do
                        var="-$var1 -$var2 -$var3 -$var4"
                        testing $i
                    done
                fi
            done
        done
    done
done

echo "\033[31mFAIL: $FAIL\033[0m"
echo "\033[32mSUCCESS: $SUCCESS\033[0m"
echo "ALL: $COUNTER"

if [ "$FAIL" -ne "0" ]; then
    exit 1;
fi
