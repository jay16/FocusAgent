script_path=$1
speed=$2
wait_path=$3
wget_file="$1/agent_wget.rb"
mv2wait_file="$1/agent_mv2wait.rb"
ruby $wget_file
ruby $wv2wait_file $speed $wait_path
