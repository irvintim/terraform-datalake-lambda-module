#!/bin/bash -e

if ! pip install --upgrade virtualenv; then
  echo "Unable to install "virtualenv" package" 1>&2
  exit 1
fi
cd $path_cwd
dir_name=lambda_pkg_$random_string/
mkdir -p $dir_name

cd $path_module
if ! virtualenv -p $runtime env-$function_name; then
  echo "Unable to create virtualenv for $runtime, you need to install $runtime on your build system" 1>&2
  exit 1
fi
source env-$function_name/bin/activate

if [[ $source_code_path != /* ]];then
   source_code_path=$path_cwd/$source_code_path
fi

FILE=$source_code_path/requirements.txt
if [ -f $FILE ]; then
  echo "requirements.txt file exists in source_code_path. Installing dependencies.."
  pip install -q -r $FILE -t $path_cwd/$dir_name --upgrade
else
  echo "requirements.txt file does not exist. Skipping installation of dependencies."
fi
deactivate
cp -r $source_code_path/. $path_cwd/$dir_name
echo "Random value to trigger a source rebuild "$random_string > $path_cwd/$dir_name/.hashtrigger
rm -rf $path_module/env-$function_name/
GIT_FILE=$path_cwd/.gitignore
grep -q '#ignore lambda_pkg dir' $path_cwd/.gitignore 2> /dev/null || echo '#ignore lambda_pkg dir' >> $path_cwd/.gitignore
grep -q $dir_name $path_cwd/.gitignore 2> /dev/null || echo $dir_name >> $path_cwd/.gitignore