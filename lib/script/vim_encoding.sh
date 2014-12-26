for file in $(find $(pwd) -type file -name "*.rb" -o -name "*.rake" -o -name "*.scss" -o -name "*.coffee")
do
    vim -c ":set fileencoding=utf-8" -c ":wq" ${file}
done
