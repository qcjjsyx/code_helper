//*******************************************************************       //
//IMPORTANT NOTICE                                                          //
//================                                                          //
//Copyright Mentor Graphics Corporation 1996 - 1999.  All rights reserved.  //
//This file and associated deliverables are the trade secrets,              //
//confidential information and copyrighted works of Mentor Graphics         //
//Corporation and its licensors and are subject to your license agreement   //
//with Mentor Graphics Corporation.                                         //
//                                                                          //
//Use of these deliverables for the purpose of making silicon from an IC    //
//design is limited to the terms and conditions of your license agreement   //
//with Mentor Graphics If you have further questions please contact Mentor  //
//Graphics Customer Support.                                                //
//                                                                          //
//This Mentor Graphics core (mi2cv2 v2002.030) was extracted on             //
//workstation hostid 80889f14 Inventra                                      //
// mi2cv2 Configuration File 
// Copyright Mentor Graphics Corporation and Licensors 2002

// Revision History
// $Log: mi2cv2_cfg.v,v $
// Revision 1.1  2002/02/25
// new file for clock divider selection
//

// mi2cv2 Clock Divider Select 
// This file contains a configuration parameter for the mi2cv2.

// If divider_en is defined then a clock divider is instantiated in module m3s001br
// If divider_en is not definied then FSEN and HSEN are definied at the top-level
// and the user has to ensure these are provided.
`define divider_en

