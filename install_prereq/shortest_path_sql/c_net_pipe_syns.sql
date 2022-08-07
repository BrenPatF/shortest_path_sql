DEFINE lib=&1
/***************************************************************************************************
Name: c_net_pipe_syns.sql               Author: Brendan Furey                      Date: 24-Aug-2019

Installation script for the synonyms in the plsql_network module.

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

There are install scripts for the base install, and optional scripts for the examples, and for 
unit testing.

INSTALL SCRIPTS
====================================================================================================
|  Script                     |  Notes                                                             |
|==================================================================================================|
|  BASE                                                                                            |
|--------------------------------------------------------------------------------------------------|
|  install_net_pipe.sql       |  Creates Net_Pipe package, in lib schema, with grants to app       |
|-----------------------------|--------------------------------------------------------------------|
|  grant_net_pipe_to_app.sql  |  Grants privileges on Net_Pipe components from lib to app schema   |
|-----------------------------|--------------------------------------------------------------------|
| *c_net_pipe_syns.sql*       |  Creates synonyms for Net_Pipe components in app schema to lib     |
|                             |  schema                                                            |
|--------------------------------------------------------------------------------------------------|
|  EXAMPLES                                                                                        |
|--------------------------------------------------------------------------------------------------|
|  install_fk.sql             |  Installs foreign key example network in app. This copies          |
|                             |  information from the Oracle view all_constraints into table       |
|                             |  fk_link to represent foreign key links as a network. The links    |
|                             |  visible in the Oracle view depend on the tables readable by app   |
|-----------------------------|--------------------------------------------------------------------|
|  install_brightkite.sql     |  Installs example "Friendship network of Brightkite users" in app  |
|                             |  schema, large example having 58,228 nodes and 214,078 links from: |
|                             |  https://snap.stanford.edu/data/loc-brightkite.html                |
|--------------------------------------------------------------------------------------------------|
|  UNIT TEST                                                                                       |
|--------------------------------------------------------------------------------------------------|
|  install_net_pipe_tt.sql    |  Creates unit test components that require a minimum Oracle        |
|                             |  database version of 12.2 in lib schema                            |
====================================================================================================
This file creates synonyms for Net_Pipe components in app schema to lib schema.

Synonyms created:

    Synonym             Object Type
    ==================  ============================================================================
    Net_Pipe             Package

***************************************************************************************************/
PROMPT Creating synonyms for &lib Net_Pipe components...
CREATE OR REPLACE SYNONYM Net_Pipe FOR &lib..Net_Pipe
/