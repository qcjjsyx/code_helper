# Components

## arb_merge

### cArbMergeN_modName
- file: pipeline/cArbMergeN_modName.v
- params: NUM_PORTS=3, DATA_WIDTH=32, DELAY1=1, DELAY2=1
- ports: input rstn 1, input i_drive0 1, input i_data0 DATA_WIDTH, output o_free0 1, input i_drive1 1, input i_data1 DATA_WIDTH, output o_free1 1, input i_drive2 1, input i_data2 DATA_WIDTH, output o_free2 1, output o_driveNext 1, output o_data DATA_WIDTH, input i_freeNext 1
- deps: components=[cPmtFifo1] primitives=[contTap, freeSetDelay] unresolved=[i]
- contract: inputs=[idx0:drive=i_drive0,data=i_data0,free=o_free0; idx1:drive=i_drive1,data=i_data1,free=o_free1; idx2:drive=i_drive2,data=i_data2,free=o_free2] outputs=driveNext:o_driveNext, data:o_data, free:None, freeNext:i_freeNext
- policy: arbitration=lowest-index-first selection=None join=None
- customization_guide:
```
1.Instantiation: cArbMerge8_exe #(88, 8) u_cArbMerge8_exe(...);
cArbMerge8_exe #(.DATA_WIDTH(88),.NUM_PORTS(8)) u_cArbMerge8_exe(...);
2.Modification: Modify the modelname (cArbMergeX_exe, DATA_WIDTH, NUM_PORTS)
Modify the interface (i_drive0, i_data0, o_free0)
Modify the signal (w_pf1id, w_pf1of, w_idata, o_data)
```

## fifo

### cFifo1_modName
- file: pipeline/cFifo1_modName.v
- params: (none)
- ports: input i_drive 1, input i_freeNext 1, output o_free 1, output o_driveNext 1, output o_fire_1 1, input rstn 1
- deps: components=[] primitives=[sender, relay, receiver, freeSetDelay] unresolved=[]
- contract: inputs=[idx0:drive=i_drive,data=None,free=o_free] outputs=driveNext:o_driveNext, data:None, free:o_free, freeNext:i_freeNext

## mutex_merge

### cMutexMergeN_modName
- file: pipeline/cMutexMergeN_modName.v
- params: DATA_WIDTH=32
- ports: input i_drive0 1, input i_drive1 1, input i_data0 DATA_WIDTH, input i_data1 DATA_WIDTH, input i_freeNext 1, output o_free0 1, output o_free1 1, output o_driveNext 1, output o_data DATA_WIDTH, input rstn 1
- deps: components=[] primitives=[freeSetDelay, contTap] unresolved=[]
- contract: inputs=[idx0:drive=i_drive0,data=i_data0,free=o_free0; idx1:drive=i_drive1,data=i_data1,free=o_free1] outputs=driveNext:o_driveNext, data:o_data, free:None, freeNext:i_freeNext

## nat_split

### cNatSplitN_modName
- file: pipeline/cNatSplitN_modName.v
- params: NUM_PORTS=3, DATA_WIDTHI=32, DATA_WIDTHOUT0=12, DATA_WIDTHOUT1=32, DATA_WIDTHOUT2=24
- ports: input i_drive 1, input i_freeNext_n NUM_PORTS, input i_data DATA_WIDTHI, output o_free 1, output o_driveNext_n NUM_PORTS, output o_data0 DATA_WIDTHOUT0, output o_data1 DATA_WIDTHOUT1, output o_data2 DATA_WIDTHOUT2, input rstn 1
- deps: components=[] primitives=[delay1U, freeSetDelay, contTap] unresolved=[]
- contract: inputs=[idx0:drive=i_drive,data=i_data,free=o_free] outputs=driveNext:o_driveNext_n, data:None, free:o_free, freeNext:i_freeNext_n
- policy: arbitration=None selection=None join=all-ports-ready

## pmt_fifo

### cPmtFifo1_modName
- file: pipeline/cPmtFifo1_modName.v
- params: (none)
- ports: input i_drive 1, input i_freeNext 1, output o_free 1, output o_driveNext 1, output o_fire_1 1, input rstn 1, input pmt 1
- deps: components=[] primitives=[sender, pmtRelay, relay, receiver, freeSetDelay] unresolved=[]
- contract: inputs=[idx0:drive=i_drive,data=None,free=o_free] outputs=driveNext:o_driveNext, data:None, free:o_free, freeNext:i_freeNext

## sel_split

### cSelSplitN_modName
- file: pipeline/cSelSplitN_modName.v
- params: NUM_PORTS=2, DATA_WIDTH=32, DELAY_IDRIVE=7, DELAY_OFREE=1
- ports: input i_data [DATA_WIDTH + NUM_PORTS - 1:0], input i_drive 1, input i_free0 1, input i_free1 1, output o_free 1, output o_drive0 1, output o_drive1 1, output o_data0 DATA_WIDTH, output o_data1 DATA_WIDTH, input rstn 1
- deps: components=[] primitives=[freeSetDelay] unresolved=[]
- contract: inputs=[idx0:drive=i_drive,data=i_data,free=o_free] outputs=driveNext:None, data:None, free:o_free, freeNext:None
- policy: arbitration=None selection=one-hot in high bits join=None

## wait_merge

### cWaitMergeN_modName
- file: pipeline/cWaitMergeN_modName.v
- params: NUM_PORTS=3, DATA_WIDTH_I0=1, DATA_WIDTH_I1=3, DATA_WIDTH_I2=3, DATA_WIDTH_O=10
- ports: input i_drive0 1, input i_drive1 1, input i_drive2 1, input i_data0 DATA_WIDTH_I0, input i_data1 DATA_WIDTH_I1, input i_data2 DATA_WIDTH_I2, input i_freeNext 1, output o_free0 1, output o_free1 1, output o_free2 1, output o_driveNext 1, output o_data DATA_WIDTH_O, input rstn 1
- deps: components=[] primitives=[contTap, delay1U] unresolved=[]
- contract: inputs=[idx0:drive=i_drive0,data=i_data0,free=o_free0; idx1:drive=i_drive1,data=i_data1,free=o_free1; idx2:drive=i_drive2,data=i_data2,free=o_free2] outputs=driveNext:o_driveNext, data:o_data, free:None, freeNext:i_freeNext
- policy: arbitration=None selection=None join=all-ports-ready
