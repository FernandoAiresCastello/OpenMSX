variable ram_watch_start_address 0
variable ram_watch_line_count 6
variable ram_watch_address_count 0

proc ram_watch_block {addr_start lines} {
	variable ram_watch_start_address
	variable ram_watch_line_count

	set ram_watch_start_address $addr_start
	set ram_watch_line_count $lines

	if {[osd exists ram_view]} {
		osd destroy ram_view
	}

	ram_watch_block_create_widget
	set id [after frame ram_watch_block_update_widget]
	
	return "RAM block watch widget added ([format "%i lines starting from 0x%04X" $ram_watch_line_count $ram_watch_start_address])"
}

proc ram_watch_block_create_widget {} {
	variable ram_watch_line_count
	variable ram_watch_start_address
	variable ram_watch_address_count
	
	variable addr $ram_watch_start_address
	variable addr_str ""
	variable y 5
	variable x 38
	variable px $x
	variable index 0
	variable index_str ""
	variable line_str ""
	variable height 0
	
	set height [expr (10 * $ram_watch_line_count) + 15]
	
	osd create rectangle ram_view -x 0 -y 0 -h $height -w 360 -scaled false -rgba 0x0000e0c0

	for {set line 0} {$line < $ram_watch_line_count} {incr line} {
		for {set col 0} {$col < 16} {incr col} {
			set index_str "i"
			append index_str $index
			# Byte in each consecutive address
			osd create text ram_view.${index_str} -text "??" -x $x -y $y -size 10 -rgba 0xffffffff
			set x [expr $x + 20]
			incr index
		}
		set x $px
		set line_str "lineheader"
		append line_str $line
		# Line header displaying address on each line
		set addr_str [format "%04X:" $addr]
		osd create text ram_view.${line_str} -text $addr_str -x [expr $x - 32] -y $y -size 10 -rgba 0xffff00ff
		set y [expr $y + 10]
		set addr [expr $addr + 16]
	}
	
	set ram_watch_address_count $index
}

proc ram_watch_block_update_widget {} {
	variable ram_watch_start_address
	variable ram_watch_address_count
	
	variable addr $ram_watch_start_address
	variable index_str ""
	variable value ""

	for {set i 0} {$i < $ram_watch_address_count} {incr i} {
		set index_str "i"
		append index_str $i
		set value [format "%02X" [peek [expr $ram_watch_start_address + $i]]]
		
		osd configure ram_view.${index_str} -text $value
	}
	
	set id [after frame ram_watch_block_update_widget]
}

namespace export ram_watch_block
