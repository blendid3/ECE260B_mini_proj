#!/bin/bash
pt_shell -f run_pt.tcl
innovus -nowin -init run_eco.tcl
pt_shell -f eva_pt.tcl