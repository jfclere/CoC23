BEGIN {
	print "user system idle"
}
{
        if ($1 == "procs")
          next
        if ($1 == "r")
          next
	print $13 , $14, $15;
}
END {
	;
}
