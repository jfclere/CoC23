BEGIN {
	name="";
        val=0;
}
{
        if (val == 0)
          val=$1
        if (name == "")
          name=$2
        if (name == $2)
          val=val+$1
        else {
          print val, name
          val=$1
          name=$2
        }
}
END {
        print val, name
}
