set_property MARK_DEBUG true [get_nets PI_GPIO9_IBUF]
set_property MARK_DEBUG true [get_nets PI_GPIO11_OBUF]
connect_debug_port u_ila_0/probe1 [get_nets [list PI_GPIO9_IBUF]]
connect_debug_port u_ila_0/probe3 [get_nets [list PI_GPIO11_OBUF]]

set_property MARK_DEBUG false [get_nets PI_GPIO10_IBUF]
set_property MARK_DEBUG false [get_nets PI_GPIO8_IBUF]
set_property MARK_DEBUG false [get_nets PI_GPIO9_OBUF]
set_property MARK_DEBUG false [get_nets PI_GPIO11_IBUF]
