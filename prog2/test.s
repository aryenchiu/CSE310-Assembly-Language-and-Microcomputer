TEST_S:
    ADD r0,r0,r1
    SUBEQ r0,r0,r1
    BL TEST_S
    LDREQ r0,[r1]
    PUSH {r0,r1}
    CMPLT r0,r1
