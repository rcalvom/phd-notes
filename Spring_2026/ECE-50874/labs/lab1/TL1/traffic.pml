/*  ================================================================
    Traffic Light Controller (Automaton-Style Promela Model)


    Notes:
    - This model is intentionally small and automaton-based, to focus on LTL part.
    ================================================================ */


/* Enumerated control states (phases) */
mtype = { NS_G, NS_Y, ALL_R, EW_G, EW_Y, BOTH_Y };

/* Current phase (the automaton state) */
mtype phase = ALL_R;

/* Predicates (LTL can reference these macros) */
#define ns_green   (phase == NS_G)
#define ns_yellow  (phase == NS_Y || phase == BOTH_Y)
#define ns_red     (!(ns_green || ns_yellow))

#define ew_green   (phase == EW_G)
#define ew_yellow  (phase == EW_Y || phase == BOTH_Y)
#define ew_red     (!(ew_green || ew_yellow))

ltl T_L1 {([] <> ns_green) && ([] <> ew_green)}

/* One-process automaton controller */
active proctype controller()
{
  do
  :: (phase == ALL_R) ->
        /* Choose which direction to service next, or enter a questionable state */
        if
        :: phase = NS_G
        :: phase = EW_G
        :: phase = BOTH_Y   /* questionable design: both yellow simultaneously */
        fi

  :: (phase == NS_G) ->
        /* Either progress normally, or (nondeterministically) stay green forever.
           This makes some liveness properties fail (e.g., "EW eventually green"). */
        if
        :: phase = NS_Y
        :: phase = NS_G   /* stutter/self-loop: may break liveness expectations */
        fi

  :: (phase == NS_Y) ->
        phase = ALL_R

  :: (phase == EW_G) ->
        /* Symmetric choice: progress, or stay green forever */
        if
        :: phase = EW_Y
        :: phase = EW_G   /* stutter/self-loop */
        fi

  :: (phase == EW_Y) ->
        phase = ALL_R

  :: (phase == BOTH_Y) ->
        /* Exit the questionable state */
        phase = ALL_R
  od
}
