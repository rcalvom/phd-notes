/*
03_handshake_liveness.pml
Sender keeps issuing requests, receiver may reply or drop forever.
*/

chan req = [1] of { byte };
chan ack = [1] of { byte };

byte waiting = 0;
byte got_ack = 0;

proctype Sender()
{
    do
    :: req!1;
       waiting = 1;

       if
       :: (len(ack) > 0) ->
            ack?1;
            got_ack = 1;
            waiting = 0
       :: else -> skip
       fi
    od
}

proctype Receiver()
{
    do
    :: req?1 ->
        /* nondeterministic: reply or drop */
        if
        :: ack!1
        :: skip
        fi
    od
}

/* Liveness SPIN Check */
ltl RESP { [] ( (waiting == 1) -> <> (got_ack == 1) ) }

init
{
    atomic {
        run Sender();
        run Receiver();
    }
}