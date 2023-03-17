# usage in script:
#
#	source journal.sh <path to journal file>
#
#	if journal_check; then
#		<first operation statements>
#	fi
#
#	if journal_check; then
#		<second operation statements>
#	fi
#
#	<...other journal operations...>
#
#	journal_close
#

__journal_file=$1
__journal_current_operation=0

# load __journal_file
echo "[journal] loading journal from $__journal_file"
if [ -e $__journal_file ]; then
	__journal_last_operation=$(cat $__journal_file)
	let __journal_last_operation=__journal_last_operation+0  # convert it to an integer number
else
	__journal_last_operation=0
fi

function journal_close {
	### Close the journal, i.e. registers the last operation
	
	let __journal_last_operation=__journal_current_operation
	echo "[journal] registering last operation on journal $__journal_file"
	echo $__journal_last_operation > $__journal_file
}


function journal_check {
	### check if the current operation was already executed successfully
	###	optionally takes a string argument that is a label of the initiating operation

	let __journal_current_operation=__journal_current_operation+1
	if [ $__journal_last_operation -lt $__journal_current_operation ]; then
		let __journal_last_operation=__journal_current_operation-1
		echo $__journal_last_operation > $__journal_file
		echo "[journal] executing operation #$__journal_current_operation $1"
		true
	else
		echo "[journal] skipping operation #$__journal_current_operation $1: already executed"
		false
	fi
}