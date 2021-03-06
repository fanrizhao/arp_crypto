#!/bin/sh
#
# Copyright (c) 2015 University of Cambridge
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory under EPSRC INTERNET Project EP/H040536/1, National Science
# Foundation under Grant No. CNS-0855268, and Defense Advanced Research
# Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), under
# contract FA8750-11-C-0249.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA (NetFPGA) under one or more contributor license
# agreements.  See the NOTICE file distributed with this work for additional
# information regarding copyright ownership.  NetFPGA licenses this file to you
# under the NetFPGA Hardware-Software License, Version 1.0 (the "License"); you
# may not use this file except in compliance with the License.  You may obtain
# a copy of the License at:
#
#   http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#

# Run bash pci_rescan_run.sh

PcieBusPath=/sys/bus/pci/devices
PcieDeviceList=`ls /sys/bus/pci/devices/`

for BusNo in $PcieDeviceList
do	
	VenderId=`cat $PcieBusPath/$BusNo/device`
	if [ "$VenderId" = "0x7028" ]; then
		echo 1 > /sys/bus/pci/devices/$BusNo/remove
		sleep 1
		echo 1 > /sys/bus/pci/rescan
		echo
		echo "Completed rescan PCIe information !"
		echo
		exit 1
	fi
done

echo "Check programming FPGA or Reboot machine !"


