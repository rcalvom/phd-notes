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
        :: atomic {
            if
                :: (mag_on == 0) -> door_open = 1
            fi
        }
        :: /* user closes door   */ door_open = 0
    od
}

proctype Magnetron()
{
    do
    :: atomic {
        if
            :: (cooking == 1 && door_open == 0) -> mag_on = 1
            :: (cooking == 0 || door_open == 1) -> mag_on = 0
        fi
    }
    od
}

ltl STRICT { [] ( (DOOR_OPEN) -> (!MAG_ON) ) }

init
{
    atomic {
        run UI();
        run Magnetron();
    }
}
