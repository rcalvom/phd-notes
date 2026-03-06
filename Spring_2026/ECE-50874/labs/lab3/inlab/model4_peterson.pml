/* * Lab Model 4: Peterson's Algorithm
 * Goal: Efficient Software Mutex (Safety & Liveness)
 * IEC 61508 Topic: Guaranteed Determinism
 */

bool turn;    /* Boolean: Whose turn is it? (0 or 1) */
bool flag[2]; /* flag[x] is true if thread x is interested in the CS */
byte count;   /* Mutex counter for verification */

active [2] proctype mutex() {
    pid i, j;
    i = _pid;       /* 0 or 1 */
    j = 1 - _pid;   /* The other thread */

again:
    flag[i] = true; /* State interest */
    turn = i;       /* Set turn to self (the 'after you' logic) */

    /* Wait until the other thread is uninterested OR it is no longer our turn.
       This single guard handles both safety and deadlock prevention. */
    (flag[j] == false || turn != i) -> 

    /* --- ENTER CRITICAL SECTION --- */
    count++;
    assert(count == 1); 
    count--;
    /* --- LEAVE CRITICAL SECTION --- */

    flag[i] = false; /* Release interest */
    
    goto again
}