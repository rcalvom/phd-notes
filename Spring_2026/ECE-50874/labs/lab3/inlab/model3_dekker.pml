/* * Lab Model 3: Dekker's Algorithm
 * Goal: Software-only Mutual Exclusion (Safety & Liveness)
 * IEC 61508 Topic: Defensive Programming 
 */

bit turn;       /* 0 or 1: Whose turn is it? */
bool flag[2];   /* flag[x] is true if thread x wants to enter */
byte count;     /* For checking mutex */

active [2] proctype mutex() {
    pid i, j;
    i = _pid;           /* Current thread ID (0 or 1) */
    j = 1 - _pid;       /* The "other" thread ID */

again:
    flag[i] = true;     /* I want a turn */
    
    do
    :: flag[j] ->       /* If the other thread also wants a turn... */
        if
        :: turn == j ->             /* ...and it's actually their turn: */
            //flag[i] = false;        /* 1. Politness Check */
            (turn != j);            /* 2. BLOCK until it's no longer their turn */
            flag[i] = true;         /* 3. Re-raise my flag and restart loop */
        :: else ->                  /* ...but if it's NOT their turn: */
            skip                    /* Just wait for them to give up their flag */
        fi
    :: else ->          /* No one else wants a turn */
        break           /* Move to Critical Section */
    od;

    /* --- ENTER CRITICAL SECTION --- */
    progress:
    count++;
    assert(count == 1); 
    count--;

    /* --- LEAVE CRITICAL SECTION --- */
    turn = j;           /* Give the turn to the other thread */
    flag[i] = false;    /* I am done */
    goto again
}