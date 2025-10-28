add_library(InstrumentPass MODULE
  src/Instrument.cpp
  )
  
add_library(runtime MODULE
  lib/runtime.c
  )

include_directories(include)

target_compile_features(InstrumentPass PRIVATE cxx_range_for cxx_auto_type)

set_target_properties(InstrumentPass PROPERTIES
        COMPILE_FLAGS "-g"
        )

if(APPLE)
    set_target_properties(InstrumentPass PROPERTIES
            LINK_FLAGS "-undefined dynamic_lookup"
            )
endif(APPLE)
