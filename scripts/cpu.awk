BEGIN {
	#print "user system idle";
        user=0
        sys=0
        idl=0
        total=0
}
{
        if ($1 == "procs")
          next
        if ($1 == "r")
          next
        user=user+$13;
        sys=sys+$14;
        idl=idl+$15;
        total=total+1;
	#print $13 , $14, $15;
}
END {
	#print user/total , sys/total, idl/total, (user+sys)/total;
	print (user+sys)/total;
}
