TEST_S:
    andeq r0, r1, #21
    eorne r0, r1, r2
    mullt r0, r1, r2
    ldrlsb r0, [r1]
    subcs r0, r1, r2, asr r3
    rsbcc r0, r1, r2
    ldmea sp!, {r5, r7}
    addmi r0, r1, r2, lsl #2
    adcpl r0, r1, r2
    sbcvs r0, r1, r2
    rscvc r0, r1, r2, lsr r3
    strleb r0, [r1]
    tsthi r0, r1
    stmfd sp!, {r4, r5}
    ldrh r0, [r1]
    swp r1, r1, [r0]
    adr r0, L1
    mrs r9, cpsr
    teqls r0, r1
    cmpge r0, r1
    cmnlt r0, r1
    strcc r0, [r1]
    orrgt r0, r1, r2
    movle r0, r1
    blgt L2
    bical r0, r1, r2
    mvnhs r0, r1
    ldreq r0, [r1]
    strne r0, [r1]
    ldrgeb r0, [r1]
    strleb r0, [r1]
    blt L1
    cmphi r0, r1
L1:
L2:

