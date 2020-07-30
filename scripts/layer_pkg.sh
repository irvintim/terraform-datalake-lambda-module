#!/bin/bash -e

cd $path_cwd
FILE=$source_code_path/requirements.txt
# If requirements.txt hasn't changed then do nothing
if unzip -p $layer_zipfile requirements.txt | diff -b -B  -q - $FILE; then
  exit 0
fi
dir_name=layer_pkg_$random_string/
if [ -f $FILE ]; then
  mkdir -p $path_cwd/$dir_name
  echo "requirements.txt file exists in source_code_path. Installing dependencies for layer file.."
  pip install -q -r $FILE -t $path_cwd/$dir_name --upgrade
  cp $FILE $path_cwd/$dir_name
else
  echo "requirements.txt file does not exist. Skipping installation of dependencies, no layer file is needed."
  exit 0
fi

if ! $runtime --version; then
  echo "Unable to run $runtime on this system, needed to create a Lambda layer with the python packages needed by this module, exiting...." 1>&2
  exit 1
fi

if ! $runtime -m ensurepip --user; then
   echo "Unable to install pip for $runtime" 1>&2
   exit 1
fi

if ! $runtime -m pip install --user --upgrade virtualenv; then
  echo "Unable to install "virtualenv" package" 1>&2
  exit 1
fi

cd $path_module
if ! virtualenv -p $runtime env-$function_name; then
  echo "Unable to create virtualenv for $runtime, you need to install $runtime on your build system" 1>&2
  exit 1
fi
source env-$function_name/bin/activate

if [[ $source_code_path != /* ]];then
   source_code_path=$path_cwd/$source_code_path
fi

deactivate
echo "Random value to trigger a source rebuild "$random_string > $path_cwd/$dir_name/.hashtrigger
rm -rf $path_module/env-$function_name/
GITIGNOREFILE=$path_cwd/.gitignore
grep -q '#ignore layer_pkg dir' $GITIGNOREFILE 2> /dev/null || echo '#ignore layer_pkg dir' >> $GITIGNOREFILE
grep -q $dir_name $GITIGNOREFILE 2> /dev/null || echo $dir_name >> $GITIGNOREFILE

exit 0