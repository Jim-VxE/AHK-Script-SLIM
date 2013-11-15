
cmp_ver( a, b ) {
; Returns zer0 if the segmented versions are equal, 1 if 'a' is less than 'b',
; -1 if 'b' is less than 'a', or blank if 'a' and 'b' aren't similarly segmented.

	x := []
	y := []
	Loop, Parse, a, % RegexReplace( a, "\w" )
		If ( A_LoopField != "" )
			x.Insert( Round( A_LoopField ) )
	Loop, Parse, b, % RegexReplace( b, "\w" )
		If ( A_LoopField != "" )
			y.Insert( Round( A_LoopField ) )
	If ( y.MaxIndex() != x.MaxIndex() )
		Return
	Loop % x.MaxIndex()
		If ( x[A_Index] < y[A_Index] )
			return 1
		Else If ( y[A_Index] < x[A_Index] )
			return -1
	return 0
}
