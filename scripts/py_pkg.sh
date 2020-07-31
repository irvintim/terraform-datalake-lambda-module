#!/bin/bash -e

dir_name=lambda_pkg_$random_string/
mkdir -p $path_cwd/$dir_name

if [[ $source_code_path != /* ]];then
   source_code_path=$path_cwd/$source_code_path
fi

cp -r $source_code_path/. $path_cwd/$dir_name
echo "Random value to trigger a source rebuild "$random_string > $path_cwd/$dir_name/.hashtrigger
