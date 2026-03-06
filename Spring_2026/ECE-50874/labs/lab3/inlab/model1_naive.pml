byte count;     /* If 1,someone is in the CRITICAL SECTION. Should be 0 or 1 at all times. */
byte x, y, z;


/* Set two threads who share count, x, y, and z */
active [2] proctype thread() {
    byte thread_id = _pid + 1;     /* thread_id is 1 or 2 */

again:

    /* PHASE 1: ADMISSION CONTROL
    * Check if the 'turn' (y) is available. 
    */

    x = thread_id;     /* Set our 'intent' (x) to enter CRITICAL SECTION */
    if
    :: (y == 0 || y == thread_id) -> skip
    :: else -> goto again     /* Abort if 'turn' (y) is set to another thread */
    fi;

    /* PHASE 2: SERIALIZATION CHECK
    * Verify that 'intent' (x) hasn't been overwritten by another thread.
    */

    z = thread_id;     /* Set 'conflict' (z) checker */
    if
    :: (x == thread_id) -> skip
    :: else -> goto again     /* Abort if another thread overwrites 'intent' (x) */
    fi;

    /* PHASE 3: COMMITMENT
    * Finalize the 'turn' (y) and verify the 'conflict' (z) register.
    */

    y = thread_id;     /* Confirm thread is safe to enter CRITICAL SECTION*/
    if
    :: (z == thread_id) -> skip
    :: else -> goto again     /* ABORT if 'conflict' (z) checker is not the acting thread */
    fi;

    /* ENTER CRITICAL SECTION */
    count++;
    assert(count == 1); 
    count--;

    /* LEAVE CRITICAL SECTION */
    y = 0;     /* Adding this helps resets the state for the loop */
    goto again
}