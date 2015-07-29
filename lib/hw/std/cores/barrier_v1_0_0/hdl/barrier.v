//-
// Copyright (c) 2015 University of Cambridge
// Copyright (c) 2015 Modified by Georgina Kalogeridou
// All rights reserved.
//
// This software was developed by the University of Cambridge Computer Laboratory 
// under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
// and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), 
// under contract FA8750-11-C-0249.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//
/*******************************************************************************
 *  File:
 *        barrier.v
 *
 *  Library:
 *        hw/std/cores/barrier_v1_0_0
 *
 *  Module:
 *        barrier
 *
 *  Author:
 *        Modified by Georgina Kalogeridou
 * 		
 *  Description:
 *        Barrier control module. Aggregates barrier good notifications
 * 	  from individual modules and pushes out a global barrier good notification
 * 	  when all modules are ready.
 *
 *
 */

`timescale 1ns/1ps

module barrier #(
   parameter NUM_PORTS = 4
)
(
   input [NUM_PORTS:0] activity_stim, 
   input [NUM_PORTS:0] activity_rec,
   input activity_trans_sim,
   input activity_trans_log,
   input [NUM_PORTS:0] barrier_req, 
   input barrier_req_trans,
   output reg barrier_proceed
);

// Time to wait before declaring the system "stuck" when we have a barrier
// and not all modules are ready to proceed.
//
parameter INACTIVITY_TIMEOUT = 2000;
time req_time;
reg timeout;
wire [NUM_PORTS:0] activity;
wire activity_trans;

assign activity = {activity_stim[4] || activity_rec[4],activity_stim[3] || activity_rec[3],activity_stim[2] || activity_rec[2],activity_stim[1] || activity_rec[1],activity_stim[0] || activity_rec[0]};

assign activity_trans = {activity_trans_sim || activity_trans_log};

initial
begin
   barrier_proceed = 0;
   timeout = 0;

   forever begin
      wait ({barrier_req, barrier_req_trans} != 'h0);

      req_time = $time;
      timeout = 0;
      #1;

      // Wait until either all ports are asserting a barrier request,
      // none of the ports are asserting a barrier request, or a timeout
      // occurs waiting for the barrier
      wait (({barrier_req, barrier_req_trans} === {(NUM_PORTS+2){1'b1}}) ||
            ({barrier_req, barrier_req_trans} === 'h0) || timeout);

      if (timeout == 1) begin
         $display($time," %m Error: timeout exceeded waiting for barrier");
         $finish;
      end
      else if ({barrier_req, barrier_req_trans} === {(NUM_PORTS+2){1'b1}}) begin
         // Barrier request from all modules

         barrier_proceed = 1;

         wait ({barrier_req, barrier_req_trans} === 'h0);

         barrier_proceed = 0;
      end      
   end  
end

initial
begin
   forever begin
      wait ({barrier_req, barrier_req_trans} != 'h0 && {activity, activity_trans} != 'h0);

      req_time = $time;
      #1;
   end
end

initial
begin
   forever begin
      
      if ({barrier_req, barrier_req_trans} != 'h0) begin
         while ({barrier_req, barrier_req_trans} != 'h0) begin
            #1;
            #(req_time + INACTIVITY_TIMEOUT - $time);
            if ({barrier_req, barrier_req_trans} != 'h0 && req_time + INACTIVITY_TIMEOUT <= $time)
               timeout = 1;
         end
      end
      else begin
         wait ({barrier_req, barrier_req_trans} != 'h0);
      end
   end
end

endmodule // barrier_ctrl
