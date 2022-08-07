CREATE OR REPLACE PACKAGE Net_Pipe AUTHID CURRENT_USER AS
/***************************************************************************************************
Name: net_pipe.pks                      Author: Brendan Furey                      Date: 10-May-2015

Package body component in the plsql_network module. 

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

PACKAGES
====================================================================================================
|  Package      |  Notes                                                                           |
|==================================================================================================|
| *Net_Pipe*    |  Package with pipelined function for network analysis                            |
|---------------|----------------------------------------------------------------------------------|
|  TT_Net_Pipe  |  Unit testing the Net_Pipe package. Depends on the module trapit_oracle_tester   |
====================================================================================================

This file has the Net_Pipe package spec. See README for API specification and examples of use.

***************************************************************************************************/
TYPE net_rec IS RECORD(
            root_node_id                   VARCHAR2(100),
            dirn                           VARCHAR2(1),
            node_id                        VARCHAR2(100),
            link_id                        VARCHAR2(100),
            node_level                     NUMBER,
            loop_flag                      VARCHAR2(1),
            line_no                        NUMBER
);
TYPE net_arr IS TABLE OF net_rec;

FUNCTION All_Nets RETURN net_arr PIPELINED;

END Net_Pipe;
/
SHO ERR
