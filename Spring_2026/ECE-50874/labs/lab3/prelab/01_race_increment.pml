/*
01_race_increment.pml
Two threads increment a shared variable using a non atomic read/modify/write.
*/

byte x = 0;
byte done1 = 0;
byte done2 = 0;

proctype Inc(byte id)
{
    byte tmp;

    /* non atomic operation */
    tmp = x;
    x   = tmp + 1;

    if
    :: (id == 1) -> done1 = 1
    :: (id == 2) -> done2 = 1
    fi
}

init
{
    atomic {
        run Inc(1);
        run Inc(2);
    }

    /* wait for both threads to finish */
    do
    :: (done1 && done2) -> break
    :: else -> skip
    od

    /* SPIN CHECK */
    assert(x == 2)
}
