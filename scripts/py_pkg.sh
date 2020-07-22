#!/bin/bash -e
#set directory permissions
if ! pip install --upgrade virtualenv; then
  echo "Unable to install "virtualenv" package" 1>&2
  exit 1
fi
cd $path_cwd
dir_name=lambda_pkg_$random_string/
mkdir -p $dir_name

#virtual env setup
cd $path_module
if ! virtualenv -p $runtime env-$function_name; then
  echo "Unable to create virtualenv for $runtime, you need to install $runtime on your build system" 1>&2
  exit 1
fi
source env-$function_name/bin/activate

if [[ $source_code_path != /* ]];then
   source_code_path=$path_cwd/$source_code_path
fi

#installing python dependencies
FILE=$source_code_path/requirements.txt
if [ -f $FILE ]; then
  echo "requirements.txt file exists in source_code_path. Installing dependencies.."
  pip install -q -r $FILE -t $path_cwd/$dir_name --upgrade
else
  echo "requirements.txt file does not exist. Skipping installation of dependencies."
fi
#deactivate virtualenv
deactivate
#creating deployment package
#cd env-$function_name/lib/$runtime/site-packages/
#cp -r . $path_cwd/$dir_name
cp -r $source_code_path/. $path_cwd/$dir_name
#removing virtual env folder
rm -rf $path_module/env-$function_name/
#add lambda_pkg directory to .gitignore
GIT_FILE=$path_cwd/.gitignore
grep -q '#ignore lambda_pkg dir' $path_cwd/.gitignore 2> /dev/null || echo '#ignore lambda_pkg dir' >> $path_cwd/.gitignore
grep -q $dir_name $path_cwd/.gitignore 2> /dev/null || echo $dir_name >> $path_cwd/.gitignore