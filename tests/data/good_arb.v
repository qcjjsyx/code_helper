//@cc: schema: cc_header_v1
//@cc: name: cArbMergeN_modName
//@cc: family: ArbMergeN
//@cc: params:
//@cc:   NUM_PORTS: 2
//@cc: roles:
//@cc:   inputs: [i_drive0, i_drive1]
//@cc:   outputs: [o_driveNext, o_data, o_free0, o_free1]
//@cc: contract:
//@cc:   arb_policy: lowest-index-first

module cArbMergeN_modName (
    input i_drive0,
    input i_drive1,
    output o_free0,
    output o_free1,
    output o_driveNext,
    output [7:0] o_data
);
endmodule
