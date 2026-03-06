/*
microwave_bad.pml
Two-thread microwave model:
- UI thread: user presses start/stop and opens/closes the door.
- Magnetron controller thread: turns magnetron on/off based on UI state.

Task for students:
1: Add an LTL safety property that says the door is never open while the magnetron is on.
2: Show SPIN finds a counterexample.
3: Fix the model to enforce an interlock.
*/

byte door_open = 0;   /* 0 = closed, 1 = open */
byte cooking   = 0;   /* 0 = not cooking, 1 = cooking requested */
byte mag_on    = 0;   /* 0 = off, 1 = on */

#define DOOR_OPEN (door_open == 1)
#define MAG_ON    (mag_on == 1)

proctype UI()
{
    do
    :: /* user presses START */ cooking = 1
    :: /* user presses STOP  */ cooking = 0
    :: /* user opens door    */ door_open = 1
    :: /* user closes door   */ door_open = 0
    od
}

proctype Magnetron()
{
    do
    :: (cooking == 1 && door_open == 0) -> mag_on = 1
    :: (cooking == 0 || door_open == 1) -> mag_on = 0
    od
}

/*
TODO: Add an LTL property here that says the door is never open while the magnetron is on. Then check with SPIN.
If there are any errors, fix the model to enforce an interlock that prevents the magnetron from turning on when the door is open.
*/
//ltl STRICT { [] ( (DOOR_OPEN) -> (!MAG_ON) ) }
ltl WEAK { (DOOR_OPEN) -> <> !MAG_ON }


init
{
    atomic {
        run UI();
        run Magnetron();
    }
}
