if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/3.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/lunar/Desktop/Snn_single_neuron"
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- Snn_single_neuron_impl_1.vm Snn_single_neuron_impl_1.ldc
run_engine synpwrap -prj "Snn_single_neuron_impl_1_synplify.tcl" -log "Snn_single_neuron_impl_1.srf"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t UWG30 -sp High-Performance_1.2V -oc Industrial -top -w -o Snn_single_neuron_impl_1_syn.udb Snn_single_neuron_impl_1.vm] "C:/Users/lunar/Desktop/Snn_single_neuron/impl_1/Snn_single_neuron_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
