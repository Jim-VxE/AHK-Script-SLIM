
UniqueIdentifier() {
; returns a 14 character unique (like a GUID) token suitable as an identifier
	b32 := "23456789abcdefghjkmnopqrstuvwxyz"
	y := A_Now
	y -= SubStr( y, 1, 2 ) "00", s
	y := y * 174 + A_MSec / 6
	s := SubStr( b32, 17 + ( ( y >> 35 ) & 15 ), 1 )
		. SubStr( b32, 1 + ( ( y >> 30 ) & 31 ), 1 )
	Random r, 0, 0x3FFFFFFF
	y := ( y << 30 ) ^ r
	Loop 12
		s .= SubStr( b32, 1 + ( ( y >> 5 * ( 12 - A_Index ) ) & 31 ), 1 )
	Return s
}

_ListAuthors( slim, delimiter = "`n" ) {
	If !IsObject( slim.Authors )
		return ""

	VarSetCapacity( s, 1000, 0 )
	for k, v in slim.Authors
		s .= delimiter _ObjKey( k, 1 )
	return SubStr( s, 1 + StrLen( delimiter ) )
}

_ObjKey( obj, index = 1 ) {
	If IsObject( obj )
		for k, v in obj
			If ( A_Index = index )
				return k
	return ""
}

_RegRead( reg, def="" ) {
	oel := ErrorLevel
	If !RegexMatch( reg, "i)^(?<_root>HK\w+)\\(?<_path>.*)\\(?<_key>[^\\]*)$", reg )
		return def, ErrorLevel := oel
	RegRead reg, %reg_root%, %reg_path%, %reg_key%
	return (!ErrorLevel ? reg : def), ErrorLevel := oel
}

_RegWrite( reg, val="" ) {
	oel := ErrorLevel
	If !RegexMatch( reg, "i)^(?<_root>HK\w+)\\(?<_path>.*)\\(?<_key>[^\\]*)$", reg )
		return 1, ErrorLevel := oel
	RegWrite REG_SZ, %reg_root%, %reg_path%, %reg_key%, %val%
	return ErrorLevel + 0, ErrorLevel := oel
}

_lvtx( row, col=1 ) {
	LV_GetText( s, row, col )
	return s
}

_lvfind( lvhwnd, str, start = 0 ) { 
	Static LVFI_STRING := 2, LVFI_SUBSTRING := 4
	LVM_FINDITEM := A_IsUnicode = 1 ? 0x1053 : 0x100D
	oel := ErrorLevel
	start |= 0
	If ( partial := ( SubStr( str, 0 ) = "*" ? LVFI_SUBSTRING : 0 ) )
		StringTrimRight str, str, 1
	VarSetCapacity( LVFINDINFO, 12 + 3 * ( A_PtrSize = 8 ? 8 : 4 ), 0 )
	NumPut( LVFI_STRING | partial, LVFINDINFO, 0, "UInt" )
	NumPut( &str, LVFINDINFO, 4 )
	SendMessage, LVM_FINDITEM, % start < 0 ? -1 : start - 1, &LVFINDINFO,, Ahk_ID %lvhwnd%
	Return ( ErrorLevel & 0xFFFFFFFF ) + 1, ErrorLevel := oel
}

addcmd( s ) {
	Global
	0++
	%0% := s
}

cmpver( a, b ) {
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

Replace( s, n, h ) {
	oel := ErrorLevel
	StringReplace, s, s, %n%, %h%, A
	Return s, ErrorLevel := oel
}

SortManifestInfo( pkg, langs ) {
; Finds the pkg.info member with the most desirable language and makes it info[1]
	n := []
	j := StrLen( langs := "`n" langs "`n" ) + 1
	for k, v in pkg.info
	{
msgbox % json_fromobj( v )
		langs .= v.Language "`n"
		p := InStr( langs, "`n" v.Language "`n" )
		If ( p < j )
		{
			j := p
			n.Insert( 1, v )
		}
		Else
			n.Insert( v )
	}
	pkg.info := n
}

StrCount( haystack, needle ) {
	oel := ErrorLevel
	StringReplace, haystack, haystack, % needle, % needle, UseErrorLevel
	return ErrorLevel + 0, ErrorLevel := oel
}
