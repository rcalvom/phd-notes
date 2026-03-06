/* * Lab Model 2: The Atomic Verification
 * Goal: Prove safety using uninterruptible blocks
 * IEC 61508 Concept: Atomic operations and Safe State transitions
 */

byte count; 

active [2] proctype thread() {
    
    byte thread_id = _pid + 1; 

again:
    /* ENTER CRITICAL SECTION */
   
    atomic {
        count++;
        assert(count == 1); 
        count--;
    }

    /* LEAVE CRITICAL SECTION */
    goto again
}