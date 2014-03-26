BEGIN {
	print "FreeMemory";
}
{
        if ($1 == "procs")
          next
        if ($1 == "r")
          next
	print $4;
}
END {
	;
}
